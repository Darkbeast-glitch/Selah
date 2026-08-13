/// Build-time configuration.
///
/// The AI base URL is a `--dart-define` rather than a committed constant so the
/// same source builds against a local Worker, a staging deploy, and production
/// without an edit. There is no secret here — the API key lives only in the
/// Worker (PRD §22/§23); this is just where to find it.
///
/// Local development against `wrangler dev`:
///
/// ```
/// # iOS simulator (shares the Mac's network stack)
/// fvm flutter run --dart-define=SELAH_AI_BASE_URL=http://localhost:8787
///
/// # Android emulator (10.0.2.2 is the host machine from inside the emulator)
/// fvm flutter run --dart-define=SELAH_AI_BASE_URL=http://10.0.2.2:8787
///
/// # Physical device — your Mac's LAN IP, and wrangler must listen beyond
/// # loopback: `npx wrangler dev --ip 0.0.0.0`
/// fvm flutter run --dart-define=SELAH_AI_BASE_URL=http://192.168.1.42:8787
/// ```
///
/// Deployed:
/// ```
/// fvm flutter run --dart-define=SELAH_AI_BASE_URL=https://selah-backend.<you>.workers.dev
/// ```
abstract final class AppConfig {
  static const String aiBaseUrl = String.fromEnvironment('SELAH_AI_BASE_URL');

  /// False when no backend was configured for this build.
  ///
  /// The app is designed to be useful without it — Scripture search, the
  /// reader, saving, and reflections are all local (§37). When this is false
  /// the AI sections are simply absent rather than broken, so a build with no
  /// backend is a valid build, not a crippled one.
  static bool get isAiConfigured => aiBaseUrl.isNotEmpty;

  /// Generous: a cold Worker plus a slow model can legitimately take a while,
  /// and the UI shows a loading state throughout.
  static const Duration aiTimeout = Duration(seconds: 45);
}
