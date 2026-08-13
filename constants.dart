/// App-wide constants and defaults.
///
/// To change the *default* SearXNG instance baked into fresh installs,
/// edit [defaultSearxngUrl] below and rebuild. Existing installs can also
/// change it at runtime from Settings without rebuilding the app.
class AppConstants {
  AppConstants._();

  static const String appName = 'Privacy Browser';

  /// Default search endpoint used to resolve non-URL input typed into the
  /// address bar. Must be a full URL ending right at the query parameter.
  /// Replace with your own self-hosted SearXNG instance, e.g.
  /// "https://searx.mydomain.com/search?q="
  static const String defaultSearxngUrl = 'https://searx.be/search?q=';

  static const String defaultHomePage = 'https://searx.be';

  /// DNS-over-HTTPS providers offered in Settings. Each must accept
  /// `?name=<host>&type=A` and return JSON (the "DoH JSON API" format
  /// supported by Cloudflare, Google, and most public resolvers).
  static const List<Map<String, String>> dohProviders = [
    {'name': 'Cloudflare', 'url': 'https://cloudflare-dns.com/dns-query'},
    {'name': 'Google', 'url': 'https://dns.google/resolve'},
    {'name': 'Quad9', 'url': 'https://dns.quad9.net:5053/dns-query'},
  ];

  static const String prefsSearxngUrl = 'pref_searxng_url';
  static const String prefsHomePage = 'pref_home_page';
  static const String prefsDohProvider = 'pref_doh_provider';
  static const String prefsDohEnabled = 'pref_doh_enabled';
  static const String prefsAdBlockEnabled = 'pref_adblock_enabled';
  static const String prefsTrackerBlockEnabled = 'pref_trackerblock_enabled';
  static const String prefsJsEnabled = 'pref_js_enabled';
  static const String prefsDesktopMode = 'pref_desktop_mode';
}
