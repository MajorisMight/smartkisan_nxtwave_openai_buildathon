// lib/models/farmer_profile.dart

class FarmerProfile {
  final String name;
  final String? phone;
  final String? experience;
  final String? language;
  final List<Farm> farms;

  FarmerProfile({
    required this.name,
    this.phone,
    this.experience,
    this.language,
    required this.farms,
  });

  factory FarmerProfile.fromMap(Map<String, dynamic> map) {
    return FarmerProfile(
      name: map['name'] as String? ?? 'Unnamed Farmer',
      phone: map['phone_number'] as String?,
      experience: map['experience_level'] as String?,
      language: map['language_pref'] as String?,
      farms: (map['farms'] as List<dynamic>? ?? [])
          .map((farmMap) => Farm.fromMap(farmMap))
          .toList(),
    );
  }
}

class Farm {
  final String village;
  final String district;
  final String state;
  final List<FarmCrop> crops;
  final double? size; // e.g., "5 acres"

  Farm({
    required this.size,
    required this.village,
    required this.district,
    required this.state,
    required this.crops,
  });

  factory Farm.fromMap(Map<String, dynamic> map) {
    return Farm(
      village: map['village'] as String? ?? 'N/A',
      district: map['district'] as String? ?? 'N/A',
      state: map['state'] as String? ?? 'N/A',
      crops: (map['farm_crops'] as List<dynamic>? ?? [])
          .map((cropMap) => FarmCrop.fromMap(cropMap))
          .toList(),
      size: map['area_in_acres'] as double? ?? 0,
    );
  }
}

class FarmCrop {
  final String cropName;

  FarmCrop({required this.cropName});

  factory FarmCrop.fromMap(Map<String, dynamic> map) {
    return FarmCrop(
      cropName: map['crop_name'] as String? ?? 'Unknown Crop',
    );
  }
}