import '../utils/validators.dart';

/// Resolves whatever the user types into the address bar into a navigable
/// URL — either the URL itself, or a search-results URL on the configured
/// SearXNG instance.
class SearchService {
  SearchService(this.searxngBaseUrl);

  /// Full search endpoint ending at the query parameter, e.g.
  /// "https://searx.be/search?q="
  final String searxngBaseUrl;

  String resolveInput(String rawInput) {
    final input = rawInput.trim();
    if (input.isEmpty) return '';

    if (UrlValidator.isLikelyUrl(input)) {
      return UrlValidator.normalize(input);
    }

    return buildSearchUrl(input);
  }

  String buildSearchUrl(String query) {
    final encoded = Uri.encodeQueryComponent(query);
    return '$searxngBaseUrl$encoded';
  }
}
