import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/providers/profile_provider.dart';
import '../models/crop_action.dart'; // Assuming you have a model for CropAction

// Provider 1: Fetches the activity logs for a specific farm_crop_id
final activityLogsProvider = StreamProvider.autoDispose.family<List<CropAction>, String>((ref, farmCropId) {
  final supabase =  ref.watch(supabaseClientProvider);

  //convert the string id from the model to an int for the database query
  final intId = int.tryParse(farmCropId) ?? 0;
  
  // Use a StreamProvider to listen for real-time changes.
  // When you add a new log, the list will update automatically.
  final stream = supabase
      .from('activity_logs')
      .stream(primaryKey: ['activity_id'])
      .eq('farm_crop_id', intId) // Assuming you add a 'farm_crop_id' to your logs table
      .order('activity_date', ascending: false);

  return stream.map((maps) => maps.map((map) => CropAction.fromMap(map)).toList());
});

// Provider 2: A Notifier to handle adding new logs
class ActivityLogNotifier extends AutoDisposeFamilyNotifier<void, String> {
  @override
  void build(String arg) {
    // No initial state needed
  }
  
  Future<void> addLog({
    required String actionType,
    required String details,
  }) async {
    final supabase = ref.read(supabaseClientProvider); // Reuse your Supabase provider
    final farmCropId = int.tryParse(arg) ?? 0;

    try {
      await supabase.from('activity_logs').insert({
        'farm_crop_id': farmCropId,
        'activity_type': actionType,
        'activity_date': DateTime.now().toIso8601String(),
        'details': {'notes': details}, // Store details in the JSONB column
      });
      // No need to invalidate, the StreamProvider will update automatically!
    } catch (e) {
      print('Error adding activity log: $e');
    }
  }
}

final activityLogNotifierProvider = NotifierProvider.autoDispose.family<ActivityLogNotifier, void, String>(
  ActivityLogNotifier.new,
);