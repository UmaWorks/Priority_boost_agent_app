class Task {
  final String id;
  final String title;
  final String? description;
  final int priority;
  final int estimatedMinutes;
  final DateTime? deadline;
  final int? difficulty;
  DateTime? completedAt;
  
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.estimatedMinutes,
    this.deadline,
    this.difficulty,
    this.completedAt,
  });
  
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      estimatedMinutes: json['timeEstimate'],
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      difficulty: json['difficulty'],
    );
  }
}