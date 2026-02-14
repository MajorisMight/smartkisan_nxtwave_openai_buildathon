import 'package:kisan/models/crop_action.dart';
import 'package:postgrest/postgrest.dart';


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

  static fromMap(PostgrestMap map) {
    return Crop(
      id: map['farm_crop_id']?.toString() ?? 0.toString(),
      name: map['crop_name'] as String? ?? "Unnamed crop",
      sowDate: DateTime.parse(map['sowing_date'] as String? ?? DateTime.now().toIso8601String()),
      stage: map['field_status'] as String? ?? "Unnamed Stage",
      areaAcres: (map['area_in_acres'] as num? ?? 0).toDouble(),
      location: map['location'] as String? ?? 'Not provided',
      actionsHistory: (map['actions_history'] as List<dynamic>?)
              ?.map((actionMap) => CropAction(
                    id: actionMap['id'] is int ? actionMap['id'] as int : int.parse(actionMap['id'].toString()),
                    farmCropId: actionMap['farm_crop_id'] is int
                        ? actionMap['farm_crop_id'] as int
                        : int.parse(actionMap['farm_crop_id'].toString()),
                    date: DateTime.parse(actionMap['date'] as String),
                    action: actionMap['action'] as String,
                    notes: actionMap['notes'] as String? ?? '',
                  ))
              .toList() ??
          [],
    );
  }
}

