import 'dart:convert';

class LandPlot {
  final String id;
  final String name;
  final double area;
  final String unit; // acre | hectare
  final String? soilType; // Loam, Sandy, etc.
  final String? irrigationType; // Drip, Sprinkler, Flood, None
  final String? cropStage; // Preparation, Sowing, Growth, Harvest, Fallow
  final String? primaryCrop;

  LandPlot({
    required this.id,
    required this.name,
    required this.area,
    required this.unit,
    this.soilType,
    this.irrigationType,
    this.cropStage,
    this.primaryCrop,
  });

  factory LandPlot.fromJson(Map<String, dynamic> json) => LandPlot(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        area: (json['area'] ?? 0).toDouble(),
        unit: json['unit'] ?? 'acre',
        soilType: json['soil_type'],
        irrigationType: json['irrigation_type'],
        cropStage: json['crop_stage'],
        primaryCrop: json['primary_crop'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'area': area,
        'unit': unit,
        'soil_type': soilType,
        'irrigation_type': irrigationType,
        'crop_stage': cropStage,
        'primary_crop': primaryCrop,
      };
}

class CropPlan {
  final String cropId; // e.g., Wheat
  final String? fieldStatus; // Preparing, Sowing, Growing, Harvesting
  final double? expectedArea;
  final String? previousCrop;
  final String? plannedCrop; // for this year

  CropPlan({
    required this.cropId,
    this.fieldStatus,
    this.expectedArea,
    this.previousCrop,
    this.plannedCrop,
  });

  factory CropPlan.fromJson(Map<String, dynamic> json) => CropPlan(
        cropId: json['crop_id'] ?? '',
        fieldStatus: json['field_status'],
        expectedArea: (json['expected_area'] is num)
            ? (json['expected_area'] as num).toDouble()
            : null,
        previousCrop: json['previous_crop'],
        plannedCrop: json['planned_crop'],
      );

  Map<String, dynamic> toJson() => {
        'crop_id': cropId,
        'field_status': fieldStatus,
        'expected_area': expectedArea,
        'previous_crop': previousCrop,
        'planned_crop': plannedCrop,
      };
}

class SoilTest {
  final double? n;
  final double? p;
  final double? k;
  final double? ph;
  final double? organicMatter;
  final String? date; // YYYY-MM-DD

  const SoilTest({this.n, this.p, this.k, this.ph, this.organicMatter, this.date});

  factory SoilTest.fromJson(Map<String, dynamic>? json) {
    if (json == null) return SoilTest();
    return SoilTest(
      n: (json['N'] is num) ? (json['N'] as num).toDouble() : null,
      p: (json['P'] is num) ? (json['P'] as num).toDouble() : null,
      k: (json['K'] is num) ? (json['K'] as num).toDouble() : null,
      ph: (json['pH'] is num) ? (json['pH'] as num).toDouble() : null,
      organicMatter: (json['organic_matter'] is num)
          ? (json['organic_matter'] as num).toDouble()
          : null,
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() => {
        'N': n,
        'P': p,
        'K': k,
        'pH': ph,
        'organic_matter': organicMatter,
        'date': date,
      };
}

class FarmerProfile {
  // Basic
  final String? name;
  final String? ageRange;
  final String? language;
  final String? experienceLevel;
  final String? socialCategory;

  // Location
  final double? gpsLat;
  final double? gpsLon;
  final String? village;
  final String? district;
  final String? state;
  final double? totalArea;
  final String areaUnit;
  final List<String> waterSources;
  final bool? isMember;
  final String? groupName;

  // Fields and crops
  final List<LandPlot> fields;
  final List<CropPlan> crops;

  // Soil & water
  final SoilTest soilTest;
  final Map<String, dynamic> waterQuality;

  // History
  final Map<String, double> lastSeasonYields;
  final Map<String, String> yieldUnit;
  final List<String> pastInputs;
  final List<String> historicalImpacts;
  final bool? usedSchemes;
  final List<String> participatedSchemes;

  // Finance & prefs
  final bool? hasBankAccount;
  final String? bankName;
  final bool? hasInsurance;
  final String? insuranceProvider;
  final String? incomeBracket;
  final String? preferredPayment;
  final bool consentAnalytics;

  const FarmerProfile({
    this.name,
    this.ageRange,
    this.language,
    this.experienceLevel,
    this.socialCategory,
    this.gpsLat,
    this.gpsLon,
    this.village,
    this.district,
    this.state,
    this.totalArea,
    this.areaUnit = 'acre',
    this.waterSources = const [],
    this.isMember,
    this.groupName,
    this.fields = const [],
    this.crops = const [],
  this.soilTest = const SoilTest(),
    this.waterQuality = const {},
    this.lastSeasonYields = const {},
    this.yieldUnit = const {},
    this.pastInputs = const [],
    this.historicalImpacts = const [],
    this.usedSchemes,
    this.participatedSchemes = const [],
    this.hasBankAccount,
    this.bankName,
    this.hasInsurance,
    this.insuranceProvider,
    this.incomeBracket,
    this.preferredPayment,
    this.consentAnalytics = false,
  });

  FarmerProfile copyWith({
    String? name,
    String? ageRange,
    String? language,
    String? experienceLevel,
    String? socialCategory,
    double? gpsLat,
    double? gpsLon,
    String? village,
    String? district,
    String? state,
    double? totalArea,
    String? areaUnit,
    List<String>? waterSources,
    bool? isMember,
    String? groupName,
    List<LandPlot>? fields,
    List<CropPlan>? crops,
    SoilTest? soilTest,
    Map<String, dynamic>? waterQuality,
    Map<String, double>? lastSeasonYields,
    Map<String, String>? yieldUnit,
    List<String>? pastInputs,
    List<String>? historicalImpacts,
    bool? usedSchemes,
    List<String>? participatedSchemes,
    bool? hasBankAccount,
    String? bankName,
    bool? hasInsurance,
    String? insuranceProvider,
    String? incomeBracket,
    String? preferredPayment,
    bool? consentAnalytics,
  }) {
    return FarmerProfile(
      name: name ?? this.name,
      ageRange: ageRange ?? this.ageRange,
      language: language ?? this.language,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      socialCategory: socialCategory ?? this.socialCategory,
      gpsLat: gpsLat ?? this.gpsLat,
      gpsLon: gpsLon ?? this.gpsLon,
      village: village ?? this.village,
      district: district ?? this.district,
      state: state ?? this.state,
      totalArea: totalArea ?? this.totalArea,
      areaUnit: areaUnit ?? this.areaUnit,
      waterSources: waterSources ?? this.waterSources,
      isMember: isMember ?? this.isMember,
      groupName: groupName ?? this.groupName,
      fields: fields ?? this.fields,
      crops: crops ?? this.crops,
      soilTest: soilTest ?? this.soilTest,
      waterQuality: waterQuality ?? this.waterQuality,
      lastSeasonYields: lastSeasonYields ?? this.lastSeasonYields,
      yieldUnit: yieldUnit ?? this.yieldUnit,
      pastInputs: pastInputs ?? this.pastInputs,
      historicalImpacts: historicalImpacts ?? this.historicalImpacts,
      usedSchemes: usedSchemes ?? this.usedSchemes,
      participatedSchemes: participatedSchemes ?? this.participatedSchemes,
      hasBankAccount: hasBankAccount ?? this.hasBankAccount,
      bankName: bankName ?? this.bankName,
      hasInsurance: hasInsurance ?? this.hasInsurance,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      incomeBracket: incomeBracket ?? this.incomeBracket,
      preferredPayment: preferredPayment ?? this.preferredPayment,
      consentAnalytics: consentAnalytics ?? this.consentAnalytics,
    );
  }

  factory FarmerProfile.fromDraft(Map<String, dynamic> draft) {
    // Convert from existing onboarding draft map saved in SessionService
    final fields = List<Map<String, dynamic>>.from(draft['fields'] ?? [])
        .map(LandPlot.fromJson)
        .toList();
    final crops = List<Map<String, dynamic>>.from(draft['crops'] ?? [])
        .map(CropPlan.fromJson)
        .toList();
    final soil = SoilTest.fromJson(
      Map<String, dynamic>.from(draft['soilTest'] ?? {}),
    );
    final lastYieldsRaw = Map<String, dynamic>.from(
      draft['lastSeasonYields'] ?? {},
    );
    final lastYields = lastYieldsRaw.map((k, v) => MapEntry(
          k,
          (v is num) ? v.toDouble() : 0.0,
        ));
    final yieldUnit = Map<String, String>.from(draft['yieldUnit'] ?? {});
    return FarmerProfile(
      name: draft['name'],
      ageRange: draft['ageRange'],
      language: draft['language'],
      experienceLevel: draft['experienceLevel'],
      socialCategory: draft['socialCategory'],
      gpsLat: (draft['gpsLat'] is num) ? (draft['gpsLat'] as num).toDouble() : null,
      gpsLon: (draft['gpsLon'] is num) ? (draft['gpsLon'] as num).toDouble() : null,
      village: draft['village'],
      district: draft['district'],
      state: draft['state'],
      totalArea: (draft['totalArea'] is num)
          ? (draft['totalArea'] as num).toDouble()
          : null,
      areaUnit: draft['areaUnit'] ?? 'acre',
      waterSources: List<String>.from(draft['waterSources'] ?? []),
      isMember: draft['isMember'],
      groupName: draft['groupName'],
      fields: fields,
      crops: crops,
      soilTest: soil,
      waterQuality: Map<String, dynamic>.from(draft['waterQuality'] ?? {}),
      lastSeasonYields: lastYields,
      yieldUnit: yieldUnit,
      pastInputs: List<String>.from(draft['pastInputs'] ?? []),
      historicalImpacts: List<String>.from(draft['historicalImpacts'] ?? []),
      usedSchemes: draft['usedSchemes'],
      participatedSchemes:
          List<String>.from(draft['participatedSchemes'] ?? []),
      hasBankAccount: draft['hasBankAccount'],
      bankName: draft['bankName'],
      hasInsurance: draft['hasInsurance'],
      insuranceProvider: draft['insuranceProvider'],
      incomeBracket: draft['incomeBracket'],
      preferredPayment: draft['preferredPayment'],
      consentAnalytics: draft['consentAnalytics'] ?? false,
    );
  }

  factory FarmerProfile.fromJson(Map<String, dynamic> json) {
    return FarmerProfile(
      name: json['name'],
      ageRange: json['ageRange'],
      language: json['language'],
      experienceLevel: json['experienceLevel'],
      socialCategory: json['socialCategory'],
      gpsLat: (json['gpsLat'] is num) ? (json['gpsLat'] as num).toDouble() : null,
      gpsLon: (json['gpsLon'] is num) ? (json['gpsLon'] as num).toDouble() : null,
      village: json['village'],
      district: json['district'],
      state: json['state'],
      totalArea:
          (json['totalArea'] is num) ? (json['totalArea'] as num).toDouble() : null,
      areaUnit: json['areaUnit'] ?? 'acre',
      waterSources: List<String>.from(json['waterSources'] ?? []),
      isMember: json['isMember'],
      groupName: json['groupName'],
      fields: (json['fields'] as List? ?? [])
          .map((e) => LandPlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      crops: (json['crops'] as List? ?? [])
          .map((e) => CropPlan.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      soilTest: SoilTest.fromJson(
        Map<String, dynamic>.from(json['soilTest'] ?? {}),
      ),
      waterQuality: Map<String, dynamic>.from(json['waterQuality'] ?? {}),
      lastSeasonYields: Map<String, dynamic>.from(json['lastSeasonYields'] ?? {})
          .map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0)),
      yieldUnit: Map<String, String>.from(json['yieldUnit'] ?? {}),
      pastInputs: List<String>.from(json['pastInputs'] ?? []),
      historicalImpacts: List<String>.from(json['historicalImpacts'] ?? []),
      usedSchemes: json['usedSchemes'],
      participatedSchemes:
          List<String>.from(json['participatedSchemes'] ?? []),
      hasBankAccount: json['hasBankAccount'],
      bankName: json['bankName'],
      hasInsurance: json['hasInsurance'],
      insuranceProvider: json['insuranceProvider'],
      incomeBracket: json['incomeBracket'],
      preferredPayment: json['preferredPayment'],
      consentAnalytics: json['consentAnalytics'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'ageRange': ageRange,
        'language': language,
        'experienceLevel': experienceLevel,
        'socialCategory': socialCategory,
        'gpsLat': gpsLat,
        'gpsLon': gpsLon,
        'village': village,
        'district': district,
        'state': state,
        'totalArea': totalArea,
        'areaUnit': areaUnit,
        'waterSources': waterSources,
        'isMember': isMember,
        'groupName': groupName,
        'fields': fields.map((e) => e.toJson()).toList(),
        'crops': crops.map((e) => e.toJson()).toList(),
        'soilTest': soilTest.toJson(),
        'waterQuality': waterQuality,
        'lastSeasonYields': lastSeasonYields,
        'yieldUnit': yieldUnit,
        'pastInputs': pastInputs,
        'historicalImpacts': historicalImpacts,
        'usedSchemes': usedSchemes,
        'participatedSchemes': participatedSchemes,
        'hasBankAccount': hasBankAccount,
        'bankName': bankName,
        'hasInsurance': hasInsurance,
        'insuranceProvider': insuranceProvider,
        'incomeBracket': incomeBracket,
        'preferredPayment': preferredPayment,
        'consentAnalytics': consentAnalytics,
      };

  String toJsonString() => jsonEncode(toJson());
}
