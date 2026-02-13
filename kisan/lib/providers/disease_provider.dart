
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisan/models/crop.dart';
import 'package:kisan/services/recommendation_service.dart';
import 'profile_provider.dart';

// 1. The state class now holds the specific crop for context.
class DiseaseState {
  final Crop crop;
  final XFile? imageFile;
  final AsyncValue<Map<String, dynamic>?> diagnosis;

  const DiseaseState({
    required this.crop,
    this.imageFile,
    this.diagnosis = const AsyncValue.data(null),
  });

  DiseaseState copyWith({
    XFile? imageFile,
    AsyncValue<Map<String, dynamic>?>? diagnosis,
  }) {
    return DiseaseState(
      crop: crop, // Always pass the original crop through
      imageFile: imageFile ?? this.imageFile,
      diagnosis: diagnosis ?? this.diagnosis,
    );
  }
}

// 2. The Notifier now receives the Crop object when it's created.
class DiseaseNotifier extends StateNotifier<DiseaseState> {
  final Ref ref;

  DiseaseNotifier(this.ref, Crop crop) : super(DiseaseState(crop: crop));

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 70);

    if (file != null) {
      state = state.copyWith(
        imageFile: file,
        diagnosis: const AsyncValue.data(null),
      );
      await diagnoseDisease();
    }
  }

  Future<void> diagnoseDisease() async {
    if (state.imageFile == null) return;

    state = state.copyWith(diagnosis: const AsyncValue.loading());

    try {
      final profileData = await ref.read(farmerProfileProvider.future);
      
      final result = await RecommendationService.diagnoseDisease(
        image: File(state.imageFile!.path),
        profile: profileData,
        crop: state.crop.name, // Use the crop name from the state
      );
      
      state = state.copyWith(diagnosis: AsyncValue.data(result));
    } catch (e, st) {
      state = state.copyWith(diagnosis: AsyncValue.error(e, st));
    }
  }

  void clear() {
    // Reset the state but keep the initial crop context
    state = DiseaseState(crop: state.crop);
  }
}

// 3. The provider is now a .family that accepts a Crop object.
final diseaseProvider = StateNotifierProvider.autoDispose.family<DiseaseNotifier, DiseaseState, Crop>(
  (ref, crop) {
    return DiseaseNotifier(ref, crop);
  },
);