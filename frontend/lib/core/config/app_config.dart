/// Backend base URL. Defaults to localhost for development (Android
/// emulator needs 10.0.2.2 instead of localhost). Override at build time
/// without touching this file, e.g.:
///   flutter build web --dart-define=BACKEND_BASE_URL=https://crispydeskbackend-production.up.railway.app
const String backendBaseUrl = String.fromEnvironment(
  'BACKEND_BASE_URL',
  defaultValue: 'http://localhost:3000',
);
