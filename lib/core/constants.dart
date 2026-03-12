/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appTitle = 'Daily Rates India';

  // ── API Endpoints ────────────────────────────────────────
  static const String goldApiUrl =
      'https://api.metals.live/v1/spot/gold';
  static const String silverApiUrl =
      'https://api.metals.live/v1/spot/silver';
  static const String bitcoinApiUrl =
      'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=inr&include_last_updated_at=true';
  static const String usdInrApiUrl =
      'https://open.er-api.com/v6/latest/USD';
  // Petrol / Diesel – no reliable free API; returns curated fallback.

  // ── Refresh ──────────────────────────────────────────────
  static const Duration refreshInterval = Duration(minutes: 5);
  static const Duration httpTimeout = Duration(seconds: 12);

  // ── Conversion helpers ───────────────────────────────────
  /// Approximate USD → INR rate used only when the exchange-rate API itself
  /// hasn't returned yet (for gold conversion).  Updated at build time.
  static const double fallbackUsdInr = 83.50;

  /// Troy-ounce → grams conversion factor.
  static const double troyOunceInGrams = 31.1035;
}

