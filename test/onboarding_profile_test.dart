import 'package:flutter_test/flutter_test.dart';
import 'package:kisan/models/onboarding_profile.dart';

void main() {
  test('FarmerProfile toJson/fromJson roundtrip', () {
    final profile = FarmerProfile(
      name: 'Ravi',
      ageRange: '26-35',
      language: 'hi',
      experienceLevel: 'intermediate',
      socialCategory: 'OBC',
      gpsLat: 28.6,
      gpsLon: 77.2,
      village: 'Rampur',
      district: 'Jaipur',
      state: 'Rajasthan',
      totalArea: 4.5,
      areaUnit: 'acre',
      waterSources: const ['Tubewell'],
      isMember: true,
      groupName: 'FPO Rampur',
      fields: [
        LandPlot(
          id: 'p1',
          name: 'North Field',
          area: 2.0,
          unit: 'acre',
          soilType: 'Loam',
          irrigationType: 'Drip',
          cropStage: 'Growth',
          primaryCrop: 'Wheat',
        ),
      ],
      crops: [
        CropPlan(
          cropId: 'Wheat',
          fieldStatus: 'Growing',
          expectedArea: 2.0,
          previousCrop: 'Mustard',
          plannedCrop: 'Wheat',
        ),
      ],
      soilTest: SoilTest(n: 100, p: 25, k: 60, ph: 7.1, organicMatter: 1.5, date: '2025-09-01'),
      waterQuality: const {'ec': 0.6},
      lastSeasonYields: const {'Wheat': 18.2},
      yieldUnit: const {'Wheat': 'qtl'},
      pastInputs: const ['DAP', 'Urea'],
      historicalImpacts: const ['Drought 2023'],
      usedSchemes: true,
      participatedSchemes: const ['PM-KUSUM'],
      hasBankAccount: true,
      bankName: 'SBI',
      hasInsurance: false,
      insuranceProvider: null,
      incomeBracket: '2-5L',
      preferredPayment: 'UPI',
      consentAnalytics: true,
    );

    final json = profile.toJson();
    final copy = FarmerProfile.fromJson(json);

    expect(copy.name, equals('Ravi'));
    expect(copy.fields.first.name, equals('North Field'));
    expect(copy.crops.first.cropId, equals('Wheat'));
    expect(copy.soilTest.ph, equals(7.1));
    expect(copy.lastSeasonYields['Wheat'], closeTo(18.2, 0.0001));
    expect(copy.yieldUnit['Wheat'], equals('qtl'));
    expect(copy.consentAnalytics, isTrue);
  });
}
