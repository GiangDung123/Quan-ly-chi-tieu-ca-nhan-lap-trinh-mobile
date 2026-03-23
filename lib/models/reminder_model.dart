class ReminderModel {
  final int? id;
  final String title;
  final String date;
  final String note;

  ReminderModel({
    this.id,
    required this.title,
    required this.date,
    required this.note,
  });
}
