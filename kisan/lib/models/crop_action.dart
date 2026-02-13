class CropAction {
  final int id;
  final int farmCropId;
  final String action;
  final String notes;
  final DateTime date;

  CropAction({
    required this.id,
    required this.farmCropId,
    required this.action,
    required this.notes,
    required this.date,
  });

  // A factory constructor to create a CropAction from a map (the format from Supabase)
  factory CropAction.fromMap(Map<String, dynamic> map) {
    // Safely extract the 'notes' from the 'details' JSONB column
    final details = map['details'] as Map<String, dynamic>? ?? {};
    final notes = details['notes'] as String? ?? '';

    return CropAction(
      id: map['activity_id'] as int,
      farmCropId: map['farm_crop_id'] as int,
      action: map['activity_type'] as String? ?? 'Unknown Action',
      notes: notes,
      date: DateTime.parse(map['activity_date'] as String),
    );
  }
}