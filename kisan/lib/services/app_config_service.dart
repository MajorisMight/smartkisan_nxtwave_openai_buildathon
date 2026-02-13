import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfigService {
  // Single switch for both login and language selection gates.
  static bool isAuthFlowEnabled() {
    final rawValue = dotenv.env['AUTH_FLOW_ENABLED'];
    if (rawValue == null) return true;
    return rawValue.toLowerCase() == 'true';
  }

  /// If true, clears all local persisted data at startup.
  static bool shouldResetAppDataOnStartup() {
    final rawValue = dotenv.env['RESET_APP_DATA_ON_STARTUP'];
    if (rawValue == null) return false;
    const truthy = {'1', 'true', 'yes', 'y', 'on'};
    return truthy.contains(rawValue.trim().toLowerCase());
  }
}
