class CropAction {
  final DateTime date;
  final String action;
  final String notes;

  CropAction({required this.date, required this.action, this.notes = ''});
}

class Crop {
  final String id;
  final String name;
  final String? type;
  final DateTime sowDate;
  final String stage; // sowing, growth, fertilizer, irrigation, harvest, selling
  final double? areaAcres;
  final String location;
  final List<CropAction> actionsHistory;

  Crop({
    required this.location,
    required this.id,
    required this.name,
    this.type,
    required this.sowDate,
    required this.stage,
    this.areaAcres,
    this.actionsHistory = const [],
  });
}

