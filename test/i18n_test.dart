import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scorpus/catalog/exercise_catalog.dart';
import 'package:scorpus/l10n/l10n.dart';
import 'package:scorpus/models/exercise.dart';
import 'package:scorpus/services/local_store.dart';
import 'package:scorpus/state/fit_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() => setAppLanguage('en'));

  test('every ARB file in lib/l10n ships as a language of the app', () {
    final arbs = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.startsWith('app_') && n.endsWith('.arb'))
        .map((n) => n.substring(4, n.length - 4))
        .toList()
      ..sort();
    expect(appLanguages.toList()..sort(), arbs);
    for (final code in appLanguages) {
      expect(languageNameOf(code).trim(), isNotEmpty);
    }
  });

  test('an unknown language falls back to English instead of crashing', () {
    setAppLanguage('xx');
    expect(appLanguage, 'en');
    SharedPreferences.setMockInitialValues({});
    Store.instance.init().then((_) {
      fit.loadFromStore();
      expect(fit.language, 'en');
    });
  });

  test('plurals and dates agree in English', () {
    setAppLanguage('en');
    expect(t.exerciseCount(1), '1 exercise');
    expect(t.exerciseCount(4), '4 exercises');
    expect(t.sessionsLogged(1), '1 session logged');
    expect(t.streakDays(1), '1-day streak');
    final d = DateTime(2026, 7, 16);
    expect(t.longDate(d), 'Thursday, Jul 16');
    expect(t.shortDate(d), 'Jul 16');
    expect([for (var w = 1; w <= 7; w++) t.weekdayInitial(w)], ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
  });

  test('catalogue vocabulary and custom exercises work cleanly', () {
    setAppLanguage('en');
    expect(muscleLabel('chest'), 'Chest');
    final mine = Exercise(
      id: 'c123',
      name: 'My Custom Lift',
      primary: 'chest',
      secondary: const [],
      equipment: 'Other',
      difficulty: 'Beginner',
      art: '',
      steps: const ['Step 1'],
    );
    expect(exerciseName(mine), 'My Custom Lift');
    expect(exerciseSteps(mine), const ['Step 1']);
    final bad = kExercises.where((e) => e.name.contains('Â') || e.name.contains('\uFFFD'));
    expect(bad.map((e) => e.name), isEmpty);
  });

  test('no English strings left hard-coded in the widgets', () {
    final pattern = RegExp(
      r"""(?:Text\(\s*|label:\s*|hintText:\s*|ScreenTitle\(\s*|title:\s*)'([^']{2,})'""",
    );

    bool looksLikeUi(String text) => RegExp(r'^[A-Z]').hasMatch(text) || text.contains(' ');

    const allowed = {'Scorpus', 'SCORPUS', 'M', 'F', 'kg', 'lb', 'cm', 'EN'};

    final offenders = <String>[];
    final ui = [Directory('lib/screens'), Directory('lib/widgets'), Directory('lib/app')];
    for (final f in ui.expand((d) => d.listSync(recursive: true)).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final m in pattern.allMatches(src)) {
        final text = m.group(1)!;
        if (text.contains(r'$')) continue;
        if (!RegExp(r'[A-Za-z]{2}').hasMatch(text)) continue;
        if (!looksLikeUi(text)) continue;
        if (allowed.contains(text)) continue;
        offenders.add('${f.uri.pathSegments.last}: "$text"');
      }
    }
    expect(offenders, isEmpty);
  });

  test('no screen keeps its own English calendar', () {
    final offenders = <String>[];
    final ui = [Directory('lib/screens'), Directory('lib/widgets'), Directory('lib/app')];
    for (final f in ui.expand((d) => d.listSync(recursive: true)).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final word in const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Jan', 'Feb', 'Dec']) {
        if (src.contains("'$word'")) offenders.add('${f.uri.pathSegments.last}: "$word"');
      }
    }
    expect(offenders, isEmpty);
  });
}
