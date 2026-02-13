class DiaryEntry {
  final String id;
  final String fieldId;
  final String activityType;
  final String productName;
  final double quantity;
  final String unit;
  final double cost;
  final DateTime date;
  final List<String> photos;
  final String notes;
  final bool synced;

  DiaryEntry({
    required this.id,
    required this.fieldId,
    required this.activityType,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.cost,
    required this.date,
    this.photos = const [],
    this.notes = '',
    required this.synced,
  });
}
