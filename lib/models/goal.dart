import 'dart:convert';

class Goal {
  final String id;
  final String title;
  final String description;
  final Map<String, double> targets;
  final DateTime targetDate;
  final DateTime createdAt;
  final bool isPercentageMode;
  final Map<String, double>? percentages;
  final Map<String, double>? startingAmounts;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.targets,
    required this.targetDate,
    required this.createdAt,
    this.isPercentageMode = false,
    this.percentages,
    this.startingAmounts,
  });

  double get targetAmount => targets.values.fold(0.0, (sum, v) => sum + v);

  double currentAmount(Map<String, double> portfolioByType) {
    double total = 0;
    for (final type in targets.keys) {
      total += portfolioByType[type] ?? 0;
    }
    return total;
  }

  double progress(Map<String, double> portfolioByType) {
    final target = targetAmount;
    if (target <= 0) return 0;
    return (currentAmount(portfolioByType) / target) * 100;
  }

  double remaining(Map<String, double> portfolioByType) =>
      targetAmount - currentAmount(portfolioByType);

  bool isCompleted(Map<String, double> portfolioByType) =>
      currentAmount(portfolioByType) >= targetAmount;

  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targets': targets,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isPercentageMode': isPercentageMode,
      if (percentages != null) 'percentages': percentages,
      if (startingAmounts != null) 'startingAmounts': startingAmounts,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    Map<String, double> targets;
    if (json['targets'] != null) {
      targets = (json['targets'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    } else {
      final amount = (json['targetAmount'] as num?)?.toDouble() ?? 0;
      targets = {'Cash': amount};
    }

    Map<String, double>? percentages;
    if (json['percentages'] != null) {
      percentages = (json['percentages'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    Map<String, double>? startingAmounts;
    if (json['startingAmounts'] != null) {
      startingAmounts = (json['startingAmounts'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    }

    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      targets: targets,
      targetDate: DateTime.parse(json['targetDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isPercentageMode: json['isPercentageMode'] ?? false,
      percentages: percentages,
      startingAmounts: startingAmounts,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Goal.fromJsonString(String jsonString) {
    return Goal.fromJson(jsonDecode(jsonString));
  }

  List<DateTime> yearlyMilestones() {
    final startYear = createdAt.year + 1;
    final milestones = <DateTime>[];
    for (var year = startYear; year <= targetDate.year; year++) {
      final milestone = DateTime(year, targetDate.month, targetDate.day);
      if (!milestone.isAfter(targetDate)) {
        milestones.add(milestone);
      }
    }
    if (milestones.isEmpty ||
        milestones.last.year != targetDate.year ||
        milestones.last.month != targetDate.month) {
      milestones.add(targetDate);
    }
    return milestones;
  }

  double milestoneTargetAmount(DateTime milestone, Map<String, double> portfolioByType) {
    final start = createdAt;
    final totalDuration = targetDate.difference(start).inDays;
    if (totalDuration <= 0) return targetAmount;
    final elapsed = milestone.difference(start).inDays.clamp(0, totalDuration);
    final ratio = elapsed / totalDuration;
    final starting = startingAmounts ?? portfolioByType;
    double startTotal = 0;
    for (final type in targets.keys) {
      startTotal += starting[type] ?? 0;
    }
    return startTotal + (targetAmount - startTotal) * ratio;
  }

  Map<String, double> milestoneTargets(DateTime milestone, Map<String, double> portfolioByType) {
    final start = createdAt;
    final totalDuration = targetDate.difference(start).inDays;
    if (totalDuration <= 0) return Map.of(targets);
    final elapsed = milestone.difference(start).inDays.clamp(0, totalDuration);
    final ratio = elapsed / totalDuration;
    final starting = startingAmounts ?? portfolioByType;
    return targets.map((k, v) {
      final s = starting[k] ?? 0;
      return MapEntry(k, s + (v - s) * ratio);
    });
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    Map<String, double>? targets,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isPercentageMode,
    Map<String, double>? percentages,
    Map<String, double>? startingAmounts,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targets: targets ?? this.targets,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isPercentageMode: isPercentageMode ?? this.isPercentageMode,
      percentages: percentages ?? this.percentages,
      startingAmounts: startingAmounts ?? this.startingAmounts,
    );
  }
}
