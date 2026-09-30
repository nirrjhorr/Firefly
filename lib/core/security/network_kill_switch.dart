import 'dart:io';

/// A global HTTP override that explicitly throws an exception if any network
/// request is attempted. This enforces the zero-network policy.
class FireflyHttpOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw UnsupportedError(
      'NETWORK_KILL_SWITCH_ACTIVE: Firefly is a strictly offline-only '
      'application. Outbound network connections are explicitly forbidden '
      'by architecture policy.',
    );
  }
}
