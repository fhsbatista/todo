class Task {
  int id;
  String title;
  DateTime date;
  String priority;
  int status;

  Task({this.title, this.date, this.priority, this.status});
  Task.withId({this.id, this.title, this.date, this.priority, this.status});

  Map<String, dynamic> toMap() {
    final map = {
      'title': title,
      'date': date.toIso8601String(),
      'priority': priority,
      'status': status
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task.withId(
        id: map['id'],
        title: map['title'],
        date: DateTime.parse(map['date']),
        priority: map['priority'],
        status: map['status']);
  }
}
