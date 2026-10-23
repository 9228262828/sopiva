enum ProcedureCategory {
  operations,
  admin,
  client,
  quality,
  finance,
  safety,
  other,
}

enum RunStepStatus { pending, completed, skipped }

String procedureCategoryLabel(ProcedureCategory value) {
  switch (value) {
    case ProcedureCategory.operations:
      return 'Operations';
    case ProcedureCategory.admin:
      return 'Admin';
    case ProcedureCategory.client:
      return 'Client';
    case ProcedureCategory.quality:
      return 'Quality';
    case ProcedureCategory.finance:
      return 'Finance';
    case ProcedureCategory.safety:
      return 'Safety';
    case ProcedureCategory.other:
      return 'Other';
  }
}

String runStepStatusLabel(RunStepStatus value) {
  switch (value) {
    case RunStepStatus.pending:
      return 'Pending';
    case RunStepStatus.completed:
      return 'Completed';
    case RunStepStatus.skipped:
      return 'Skipped';
  }
}

class ProcedureStep {
  final String id;
  final String title;
  final String note;

  const ProcedureStep({
    required this.id,
    required this.title,
    required this.note,
  });

  ProcedureStep copyWith({
    String? id,
    String? title,
    String? note,
  }) {
    return ProcedureStep(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
      };

  factory ProcedureStep.fromMap(Map<String, dynamic> map) {
    return ProcedureStep(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      note: map['note'] as String? ?? '',
    );
  }
}

class ProcedureItem {
  final String id;
  final String title;
  final String description;
  final ProcedureCategory category;
  final bool favorite;
  final DateTime createdAt;
  final List<ProcedureStep> steps;

  const ProcedureItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.favorite,
    required this.createdAt,
    required this.steps,
  });

  ProcedureItem copyWith({
    String? id,
    String? title,
    String? description,
    ProcedureCategory? category,
    bool? favorite,
    DateTime? createdAt,
    List<ProcedureStep>? steps,
  }) {
    return ProcedureItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'favorite': favorite,
        'createdAt': createdAt.toIso8601String(),
        'steps': steps.map((e) => e.toMap()).toList(),
      };

  factory ProcedureItem.fromMap(Map<String, dynamic> map) {
    final rawSteps = map['steps'] as List<dynamic>? ?? const [];
    final rawCategory =
        map['category'] as String? ?? ProcedureCategory.other.name;

    return ProcedureItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: ProcedureCategory.values.firstWhere(
        (e) => e.name == rawCategory,
        orElse: () => ProcedureCategory.other,
      ),
      favorite: map['favorite'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      steps: rawSteps
          .map(
            (e) => ProcedureStep.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class RunStepResult {
  final String stepId;
  final String title;
  final RunStepStatus status;

  const RunStepResult({
    required this.stepId,
    required this.title,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'stepId': stepId,
        'title': title,
        'status': status.name,
      };

  factory RunStepResult.fromMap(Map<String, dynamic> map) {
    final rawStatus =
        map['status'] as String? ?? RunStepStatus.pending.name;

    return RunStepResult(
      stepId: map['stepId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      status: RunStepStatus.values.firstWhere(
        (e) => e.name == rawStatus,
        orElse: () => RunStepStatus.pending,
      ),
    );
  }
}

class ProcedureRun {
  final String id;
  final String procedureId;
  final String procedureTitle;
  final ProcedureCategory category;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int durationSeconds;
  final String note;
  final List<RunStepResult> steps;

  const ProcedureRun({
    required this.id,
    required this.procedureId,
    required this.procedureTitle,
    required this.category,
    required this.startedAt,
    required this.finishedAt,
    required this.durationSeconds,
    required this.note,
    required this.steps,
  });

  int get completedCount =>
      steps.where((e) => e.status == RunStepStatus.completed).length;

  int get skippedCount =>
      steps.where((e) => e.status == RunStepStatus.skipped).length;

  int get totalCount => steps.length;

  double get completionRate {
    if (steps.isEmpty) return 0;
    return completedCount / steps.length;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'procedureId': procedureId,
        'procedureTitle': procedureTitle,
        'category': category.name,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'note': note,
        'steps': steps.map((e) => e.toMap()).toList(),
      };

  factory ProcedureRun.fromMap(Map<String, dynamic> map) {
    final rawSteps = map['steps'] as List<dynamic>? ?? const [];
    final rawCategory =
        map['category'] as String? ?? ProcedureCategory.other.name;

    return ProcedureRun(
      id: map['id'] as String? ?? '',
      procedureId: map['procedureId'] as String? ?? '',
      procedureTitle: map['procedureTitle'] as String? ?? '',
      category: ProcedureCategory.values.firstWhere(
        (e) => e.name == rawCategory,
        orElse: () => ProcedureCategory.other,
      ),
      startedAt:
          DateTime.tryParse(map['startedAt'] as String? ?? '') ?? DateTime.now(),
      finishedAt:
          DateTime.tryParse(map['finishedAt'] as String? ?? '') ?? DateTime.now(),
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      note: map['note'] as String? ?? '',
      steps: rawSteps
          .map(
            (e) => RunStepResult.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}
