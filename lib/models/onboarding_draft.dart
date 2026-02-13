// Onboarding draft model
class OnboardingDraft {
  // Profile
  String? name;
  String? ageRange;
  String language = 'English';
  String? phoneNumber;
  bool phoneVerified = false;
  String? experienceLevel;
  String? socialCategory;

  // Location
  double? gpsLat;
  double? gpsLon;
  String? village;
  String? district;
  String? state;
  double? totalArea;
  String areaUnit = 'acre';
  List<String> waterSources = [];
  List<String> equipment = [];
  bool? isMember;
  String? groupName;

  // Fields
  List<Map<String, dynamic>> fields = [];

  // Crops
  List<Map<String, dynamic>> crops = [];

  // Soil/water
  bool manualSoilEntry = false;
  final Map<String, dynamic> soilTest = {};
  final Map<String, dynamic> waterQuality = {};
  bool? wantSoilKit;

  // History
  final Map<String, double> lastSeasonYields = {};
  final Map<String, String> yieldUnit = {};
  List<String> pastInputs = [];
  List<String> historicalImpacts = [];
  bool? usedSchemes;
  List<String> participatedSchemes = [];

  // Finance
  bool? hasBankAccount;
  String? bankName;
  bool? hasInsurance;
  String? insuranceProvider;
  String? incomeBracket;
  String? preferredPayment;
  bool consentAnalytics = false;

  // Consent
  bool termsAccepted = false;

  OnboardingDraft copyWith({
    String? name,
    String? ageRange,
    String? language,
    String? phoneNumber,
    bool? phoneVerified,
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
    List<String>? equipment,
    bool? isMember,
    String? groupName,
    List<Map<String, dynamic>>? fields,
    List<Map<String, dynamic>>? crops,
    bool? manualSoilEntry,
    bool? wantSoilKit,
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
    bool? termsAccepted,
  }) {
    return OnboardingDraft()
      ..name = name ?? this.name
      ..ageRange = ageRange ?? this.ageRange
      ..language = language ?? this.language
      ..phoneNumber = phoneNumber ?? this.phoneNumber
      ..phoneVerified = phoneVerified ?? this.phoneVerified
      ..experienceLevel = experienceLevel ?? this.experienceLevel
      ..socialCategory = socialCategory ?? this.socialCategory
      ..gpsLat = gpsLat ?? this.gpsLat
      ..gpsLon = gpsLon ?? this.gpsLon
      ..village = village ?? this.village
      ..district = district ?? this.district
      ..state = state ?? this.state
      ..totalArea = totalArea ?? this.totalArea
      ..areaUnit = areaUnit ?? this.areaUnit
      ..waterSources = waterSources ?? this.waterSources
      ..equipment = equipment ?? this.equipment
      ..isMember = isMember ?? this.isMember
      ..groupName = groupName ?? this.groupName
      ..fields = fields ?? this.fields
      ..crops = crops ?? this.crops
      ..manualSoilEntry = manualSoilEntry ?? this.manualSoilEntry
      ..wantSoilKit = wantSoilKit ?? this.wantSoilKit
      ..pastInputs = pastInputs ?? this.pastInputs
      ..historicalImpacts = historicalImpacts ?? this.historicalImpacts
      ..usedSchemes = usedSchemes ?? this.usedSchemes
      ..participatedSchemes = participatedSchemes ?? this.participatedSchemes
      ..hasBankAccount = hasBankAccount ?? this.hasBankAccount
      ..bankName = bankName ?? this.bankName
      ..hasInsurance = hasInsurance ?? this.hasInsurance
      ..insuranceProvider = insuranceProvider ?? this.insuranceProvider
      ..incomeBracket = incomeBracket ?? this.incomeBracket
      ..preferredPayment = preferredPayment ?? this.preferredPayment
      ..consentAnalytics = consentAnalytics ?? this.consentAnalytics
      ..termsAccepted = termsAccepted ?? this.termsAccepted;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ageRange': ageRange,
      'language': language,
      'phoneNumber': phoneNumber,
      'phoneVerified': phoneVerified,
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
      'equipment': equipment,
      'isMember': isMember,
      'groupName': groupName,
      'fields': fields,
      'crops': crops,
      'manualSoilEntry': manualSoilEntry,
      'soilTest': soilTest,
      'waterQuality': waterQuality,
      'wantSoilKit': wantSoilKit,
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
      'termsAccepted': termsAccepted,
    };
  }

  void applyFromMap(Map<String, dynamic> m) {
    try {
      name = m['name'] as String?;
      ageRange = m['ageRange'] as String?;
      language = m['language'] as String? ?? language;
      phoneNumber = m['phoneNumber'] as String?;
      phoneVerified = m['phoneVerified'] as bool? ?? false;
      experienceLevel = m['experienceLevel'] as String?;
      socialCategory = m['socialCategory'] as String?;
      gpsLat = (m['gpsLat'] is num) ? (m['gpsLat'] as num).toDouble() : null;
      gpsLon = (m['gpsLon'] is num) ? (m['gpsLon'] as num).toDouble() : null;
      village = m['village'] as String?;
      district = m['district'] as String?;
      state = m['state'] as String?;
      totalArea = (m['totalArea'] is num) ? (m['totalArea'] as num).toDouble() : null;
      areaUnit = m['areaUnit'] as String? ?? areaUnit;
      waterSources = List<String>.from(m['waterSources'] ?? []);
      equipment = List<String>.from(m['equipment'] ?? []);
      isMember = m['isMember'] as bool?;
      groupName = m['groupName'] as String?;
      fields = List<Map<String, dynamic>>.from(m['fields'] ?? []);
      crops = List<Map<String, dynamic>>.from(m['crops'] ?? []);
      manualSoilEntry = m['manualSoilEntry'] as bool? ?? manualSoilEntry;
      (soilTest..clear()).addAll(Map<String, dynamic>.from(m['soilTest'] ?? {}));
      (waterQuality..clear()).addAll(Map<String, dynamic>.from(m['waterQuality'] ?? {}));
      wantSoilKit = m['wantSoilKit'] as bool?;
      (lastSeasonYields..clear()).addAll(
        Map<String, dynamic>.from(m['lastSeasonYields'] ?? {})
            .map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : 0.0)),
      );
      (yieldUnit..clear()).addAll(
        Map<String, String>.from((m['yieldUnit'] ?? {}).map((k, v) => MapEntry(k.toString(), v.toString()))),
      );
      pastInputs = List<String>.from(m['pastInputs'] ?? []);
      historicalImpacts = List<String>.from(m['historicalImpacts'] ?? []);
      usedSchemes = m['usedSchemes'] as bool?;
      participatedSchemes = List<String>.from(m['participatedSchemes'] ?? []);
      hasBankAccount = m['hasBankAccount'] as bool?;
      bankName = m['bankName'] as String?;
      hasInsurance = m['hasInsurance'] as bool?;
      insuranceProvider = m['insuranceProvider'] as String?;
      incomeBracket = m['incomeBracket'] as String?;
      preferredPayment = m['preferredPayment'] as String?;
      consentAnalytics = m['consentAnalytics'] as bool? ?? false;
      termsAccepted = m['termsAccepted'] as bool? ?? false;
    } catch (_) {
      // if parsing fails, keep defaults
    }
  }

  bool isStepValid(int step) {
  switch (step) {
    case 0: // Basic Info
      return ageRange != null && language.isNotEmpty && experienceLevel != null;
    case 1: // Location
      return totalArea != null && totalArea! > 0;
    case 2: // Crops
      return crops.isNotEmpty;
    case 4: // Past Yields
      if (crops.isEmpty) return true;
      return crops.every((crop) {
        final id = crop['crop_id'] as String;
        return lastSeasonYields.containsKey(id) && lastSeasonYields[id]! > 0;
      });
    case 5: // Finance & Finish
      return termsAccepted;
    default:
      return true;
  }
}
}