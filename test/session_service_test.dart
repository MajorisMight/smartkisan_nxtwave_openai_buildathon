import 'package:flutter_test/flutter_test.dart';
import 'package:kisan/services/session_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SessionService save/get profile JSON', () async {
    final sample = {
      'name': 'Test',
      'state': 'Rajasthan',
      'district': 'Jaipur',
      'fields': [],
      'crops': [],
      'soilTest': {},
    };

    await SessionService.saveProfile(sample);
    final loaded = await SessionService.getStoredProfile();
    expect(loaded, isNotNull);
    expect(loaded!['name'], equals('Test'));
    expect(loaded['state'], equals('Rajasthan'));
  });
}
