/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────
  static const String appTitle = 'Daily Rates India';

  // ── API Endpoints ────────────────────────────────────────
  // Gold API endpoints (trying multiple sources for reliability)
  // CoinGecko tether-gold (XAUT) tracks real gold price per troy ounce
  static const String goldApiUrl =
      'https://api.coingecko.com/api/v3/simple/price?ids=tether-gold&vs_currencies=inr,usd';

  // Gold price via exchange rate API (XAU = gold per troy ounce in USD)
  static const String goldExchangeApiUrl =
      'https://open.er-api.com/v6/latest/XAU';

  static const String goldApiUrlBackup =
      'https://api.metals.live/v1/spot/gold';

  static const String silverApiUrl =
      'https://api.metals.live/v1/spot/silver';
  // Silver via exchange rate API (XAG = silver per troy ounce)
  static const String silverExchangeApiUrl =
      'https://open.er-api.com/v6/latest/XAG';
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
  static const double fallbackUsdInr = 85.50;

  /// Troy-ounce → grams conversion factor.
  static const double troyOunceInGrams = 31.1035;
}

