import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class SopivaStore extends ChangeNotifier {
  static const _proceduresKey = 'sopiva_procedures_v1';
  static const _runsKey = 'sopiva_runs_v1';
  static const _darkKey = 'sopiva_dark_v1';

  bool ready = false;
  bool darkMode = false;

  final List<ProcedureItem> _procedures = [];
  final List<ProcedureRun> _runs = [];

  List<ProcedureItem> get procedures => List.unmodifiable(_procedures);

  List<ProcedureRun> get runs {
    final copy = [..._runs]..sort(
        (a, b) => b.finishedAt.compareTo(a.finishedAt),
      );
    return List.unmodifiable(copy);
  }

  int get totalRuns => _runs.length;

  int get totalCompletedSteps => _runs.fold(
        0,
        (sum, run) => sum + run.completedCount,
      );

  int get totalSkippedSteps => _runs.fold(
        0,
        (sum, run) => sum + run.skippedCount,
      );

  double get averageCompletionRate {
    if (_runs.isEmpty) return 0;
    final total = _runs.fold<double>(
      0,
      (sum, run) => sum + run.completionRate,
    );
    return total / _runs.length;
  }

  int get averageDurationSeconds {
    if (_runs.isEmpty) return 0;
    final total =
        _runs.fold<int>(0, (sum, run) => sum + run.durationSeconds);
    return (total / _runs.length).round();
  }

  ProcedureItem? procedureById(String id) {
    for (final item in _procedures) {
      if (item.id == id) return item;
    }
    return null;
  }

  int usageCount(String procedureId) {
    return _runs.where((run) => run.procedureId == procedureId).length;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    darkMode = prefs.getBool(_darkKey) ?? false;

    _procedures.clear();
    _runs.clear();

    final rawProcedures = prefs.getString(_proceduresKey);
    final rawRuns = prefs.getString(_runsKey);

    if (rawProcedures != null && rawProcedures.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawProcedures) as List<dynamic>;
        _procedures.addAll(
          decoded.map(
            (e) => ProcedureItem.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
      } catch (_) {}
    }

    if (rawRuns != null && rawRuns.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawRuns) as List<dynamic>;
        _runs.addAll(
          decoded.map(
            (e) => ProcedureRun.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          ),
        );
      } catch (_) {}
    }

    ready = true;
    notifyListeners();
  }

  Future<void> addProcedure(ProcedureItem item) async {
    _procedures.add(item);
    await _saveProcedures();
    notifyListeners();
  }

  Future<void> updateProcedure(ProcedureItem item) async {
    final index = _procedures.indexWhere((e) => e.id == item.id);
    if (index == -1) return;

    _procedures[index] = item;
    await _saveProcedures();
    notifyListeners();
  }

  Future<void> deleteProcedure(String id) async {
    _procedures.removeWhere((e) => e.id == id);
    await _saveProcedures();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final item = procedureById(id);
    if (item == null) return;

    await updateProcedure(
      item.copyWith(favorite: !item.favorite),
    );
  }

  Future<void> addStep({
    required String procedureId,
    required String title,
    required String note,
  }) async {
    final item = procedureById(procedureId);
    if (item == null || title.trim().isEmpty) return;

    final step = ProcedureStep(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      note: note.trim(),
    );

    await updateProcedure(
      item.copyWith(steps: [...item.steps, step]),
    );
  }

  Future<void> updateStep({
    required String procedureId,
    required ProcedureStep step,
  }) async {
    final item = procedureById(procedureId);
    if (item == null) return;

    final steps = item.steps.map((e) {
      if (e.id == step.id) return step;
      return e;
    }).toList();

    await updateProcedure(item.copyWith(steps: steps));
  }

  Future<void> deleteStep({
    required String procedureId,
    required String stepId,
  }) async {
    final item = procedureById(procedureId);
    if (item == null) return;

    final steps = item.steps.where((e) => e.id != stepId).toList();
    await updateProcedure(item.copyWith(steps: steps));
  }

  Future<void> reorderSteps({
    required String procedureId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final item = procedureById(procedureId);
    if (item == null) return;

    final steps = [...item.steps];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = steps.removeAt(oldIndex);
    steps.insert(newIndex, moved);

    await updateProcedure(item.copyWith(steps: steps));
  }

  Future<void> addRun(ProcedureRun run) async {
    _runs.add(run);
    await _saveRuns();
    notifyListeners();
  }

  Future<void> deleteRun(String id) async {
    _runs.removeWhere((e) => e.id == id);
    await _saveRuns();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _procedures.clear();
    _runs.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_proceduresKey);
    await prefs.remove(_runsKey);

    notifyListeners();
  }

  Future<void> _saveProcedures() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _proceduresKey,
      jsonEncode(
        _procedures.map((e) => e.toMap()).toList(),
      ),
    );
  }

  Future<void> _saveRuns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _runsKey,
      jsonEncode(
        _runs.map((e) => e.toMap()).toList(),
      ),
    );
  }
}
