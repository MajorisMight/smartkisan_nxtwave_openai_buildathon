class CropAction {
  final int id;
  final int farmCropId;
  final String action;
  final String notes;
  final DateTime date;
  final DateTime? createdAt;

  CropAction({
    required this.id,
    required this.farmCropId,
    required this.action,
    required this.notes,
    required this.date,
    this.createdAt,
  });

  // A factory constructor to create a CropAction from a map (the format from Supabase)
  factory CropAction.fromMap(Map<String, dynamic> map) {
    final rawDetails = map['details'];
    String notes = '';

    if (rawDetails is String) {
      notes = rawDetails;
    } else if (rawDetails is Map) {
      final detailsMap = Map<String, dynamic>.from(rawDetails);
      notes = detailsMap['notes']?.toString() ?? '';
    }

    final action = map['title']?.toString() ?? map['activity_type']?.toString() ?? 'Activity';
    final createdRaw = map['created_at'];
    DateTime? createdAt;
    if (createdRaw != null) {
      createdAt = DateTime.tryParse(createdRaw.toString());
    }

    return CropAction(
      id: map['activity_id'] as int,
      farmCropId: map['farm_id'] as int,
      action: action,
      notes: notes,
      date: DateTime.parse(
        (map['activity_date'] ?? map['created_at'] ?? '').toString(),
      ),
      createdAt: createdAt,
    );
  }
}
