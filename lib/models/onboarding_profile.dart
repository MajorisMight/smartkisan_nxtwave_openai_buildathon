class FarmerProfile {
  final String? name;
  final String? phone;
  final String? village;
  final String? district;
  final String? state;
  final String? language;
  final int totalDurationDays;
  final int harvestStartBufferDays;
  final int harvestEndBufferDays;

  FarmerProfile({
    this.name,
    this.phone,
    this.village,
    this.district,
    this.state,
    this.language,
    this.totalDurationDays = 110,
    this.harvestStartBufferDays = -5,
    this.harvestEndBufferDays = 10,
  });

  factory FarmerProfile.fromDraft(Map<String, dynamic> draft) {
    return FarmerProfile(
      name: draft['name']?.toString(),
      phone: draft['phone']?.toString(),
      village: draft['village']?.toString(),
      district: draft['district']?.toString(),
      state: draft['state']?.toString(),
      language: draft['language']?.toString(),
      totalDurationDays: _toInt(draft['totalDurationDays'], fallback: 110),
      harvestStartBufferDays: _toInt(draft['harvestStartBufferDays'], fallback: -5),
      harvestEndBufferDays: _toInt(draft['harvestEndBufferDays'], fallback: 10),
    );
  }

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile.fromDraft(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'village': village,
      'district': district,
      'state': state,
      'language': language,
      'address': {
        'village': village,
        'district': district,
        'state': state,
      },
      'totalDurationDays': totalDurationDays,
      'harvestStartBufferDays': harvestStartBufferDays,
      'harvestEndBufferDays': harvestEndBufferDays,
    };
  }

  static int _toInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }
}
