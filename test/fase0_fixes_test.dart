import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scorpus/catalog/exercise_catalog.dart';
import 'package:scorpus/models/workout.dart';
import 'package:scorpus/services/alarm_store.dart';
import 'package:scorpus/services/backup_zip.dart';
import 'package:scorpus/services/local_store.dart';
import 'package:scorpus/services/media_store.dart';
import 'package:scorpus/services/progress_reminder.dart';
import 'package:scorpus/state/fit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final bench = kExercises.firstWhere((e) => e.equipment == 'Barbell');
  final png = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 1, 2, 3, 4]);

  late Directory tmp;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.instance.init();
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('scorpus_fase0');
    MediaStore.directory = tmp.path;
    ProgressReminder.instance.enabled = false;
    fit.resetAllData();
  });

  tearDown(() async {
    MediaStore.directory = null;
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  test('editing logged reps and weight preserves kind, rpe, sec, and km', () {
    final ex = LoggedExercise(bench.id, bench.name, bench.primary, [
      LoggedSet(8, 80, kind: SetKind.drop, rpe: 8.5, sec: 45, km: 1.5),
    ]);
    fit.sessions.add(LoggedSession(DateTime.now(), 1800, [ex]));

    fit.setLoggedReps(ex, 0, 10);
    fit.setLoggedWeight(ex, 0, 82.5);

    final updated = ex.sets.single;
    expect(updated.reps, 10);
    expect(updated.weight, 82.5);
    expect(updated.kind, SetKind.drop);
    expect(updated.rpe, 8.5);
    expect(updated.sec, 45);
    expect(updated.km, 1.5);
  });

  test('MediaStore and AlarmStore block path traversal tokens', () async {
    final saved = await MediaStore.saveBytes('../../escape', 'png/../../evil', png);
    expect(saved, isNotNull);
    expect(saved!.contains('/'), false);
    expect(saved.contains('..'), false);
    expect(File('${tmp.path}/$saved').existsSync(), true);
    expect(MediaStore.pathFor('../secret.png'), isNull);
    expect(AlarmStore.pathFor('../secret.mp3'), isNull);
  });

  test('malformed backup zip is rejected without wiping existing media', () async {
    final src = File('${tmp.path}/keep.png')..writeAsBytesSync(png);
    await fit.attachExerciseMedia(bench.id, src.path);
    final keptFile = fit.mediaFor(bench.id);
    expect(keptFile, isNotEmpty);

    final badArchive = Archive()
      ..addFile(ArchiveFile.string(
        kBackupJsonEntry,
        jsonEncode({
          'sessions': [
            {'d': 'not-a-valid-date', 'dur': 100, 'ex': []}
          ],
        }),
      ));
    final badZip = ZipEncoder().encodeBytes(badArchive);

    expect(await restoreBackupZip(badZip), false);
    expect(await MediaStore.readBytes(keptFile), png);

    // Ensure persistence still works (_loading was not stuck true).
    fit.updateProfile(name: 'StillSaving');
    fit.persistNow();
    expect(Store.instance.load()['profile']['name'], 'StillSaving');
  });

  test('corrupt Store.load preserves raw string under scorpus_v1_corrupt', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scorpus_v1', '{broken-json');

    expect(Store.instance.load(), isEmpty);
    expect(prefs.getString('scorpus_v1_corrupt'), '{broken-json');
  });
}
