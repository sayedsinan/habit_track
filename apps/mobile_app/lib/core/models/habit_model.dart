class Habit {
  final String id;
  final String title;
  final String description;
  final String timeOfDay;
  int totalTimes;
  int completedTimes;
  List<int> pastDaysCompletion;

  bool get isCompleted => completedTimes >= totalTimes;

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.timeOfDay,
    this.totalTimes = 1,
    this.completedTimes = 0,
    List<int>? pastDaysCompletion,
  }) : pastDaysCompletion = pastDaysCompletion ?? List.filled(6, 0);

  factory Habit.fromJson(Map<String, dynamic> json) {
    final int totalTimes = (json['total_times'] as int?) ?? 1;
    List<int> parsedPastDays;
    if (json['past_days'] != null) {
      parsedPastDays = (json['past_days'] as List).map<int>((e) {
        if (e == true) return totalTimes;
        if (e is int) return e;
        return 0;
      }).toList();
    } else {
      parsedPastDays = List.filled(6, 0);
    }

    return Habit(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      timeOfDay: json['time_of_day'] ?? 'Morning',
      totalTimes: totalTimes,
      completedTimes: json['completed_times'] ?? 0,
      pastDaysCompletion: parsedPastDays,
    );
  }
}
