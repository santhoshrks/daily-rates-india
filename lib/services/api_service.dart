import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/rate_model.dart';

/// Handles all HTTP calls and returns structured [RateModel] objects.
///
/// Every method catches exceptions internally and returns a sensible
/// fallback so the UI layer never receives an unhandled error from here.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ── Cache ────────────────────────────────────────────────
  final Map<String, RateModel> _cache = {};
  RateModel? getCached(String key) => _cache[key];

  // Cached exchange-rate response (used by both USD & EUR methods).
  Map<String, dynamic>? _lastExchangeRates;

  // ── Gold ─────────────────────────────────────────────────
  Future<RateModel> getGoldPrice() async {
    const key = 'gold';
    final prev = _cache[key]?.numericValue;

    // ── Strategy 1: CoinGecko tether-gold (XAUT = 1 troy ounce of gold) ──
    try {
      final uri = Uri.parse(AppConstants.goldApiUrl);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        // Format: {"tether-gold": {"inr": 2500000, "usd": 3000}}
        if (decoded.containsKey('tether-gold') &&
            decoded['tether-gold'] is Map) {
          final data = decoded['tether-gold'] as Map<String, dynamic>;
          if (data.containsKey('inr')) {
            // XAUT price is per troy ounce → convert to per gram
            final inrPerOz = (data['inr'] as num).toDouble();
            final inrPerGram = inrPerOz / AppConstants.troyOunceInGrams;

            final model = RateModel(
              title: 'Gold Rate',
              value: '${_formatINR(inrPerGram)} / g',
              updatedAt: DateTime.now(),
              icon: Icons.monetization_on_rounded,
              iconBgColor: const Color(0xFFFFF8E1),
              iconFgColor: const Color(0xFFFF8F00),
              numericValue: inrPerGram,
              previousNumericValue: prev,
            );
            _cache[key] = model;
            return model;
          }
        }
      }
    } catch (_) {}

    // ── Strategy 2: Exchange rate API (XAU base → INR) ──
    try {
      final uri = Uri.parse(AppConstants.goldExchangeApiUrl);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final rates = decoded['rates'] as Map<String, dynamic>?;
        if (rates != null && rates.containsKey('INR')) {
          // XAU base: 1 XAU = X INR (1 troy ounce of gold in INR)
          final inrPerOz = (rates['INR'] as num).toDouble();
          final inrPerGram = inrPerOz / AppConstants.troyOunceInGrams;

          final model = RateModel(
            title: 'Gold Rate',
            value: '${_formatINR(inrPerGram)} / g',
            updatedAt: DateTime.now(),
            icon: Icons.monetization_on_rounded,
            iconBgColor: const Color(0xFFFFF8E1),
            iconFgColor: const Color(0xFFFF8F00),
            numericValue: inrPerGram,
            previousNumericValue: prev,
          );
          _cache[key] = model;
          return model;
        }
      }
    } catch (_) {}

    // ── Strategy 3: metals.live (backup) ──
    try {
      final uri = Uri.parse(AppConstants.goldApiUrlBackup);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List && decoded.isNotEmpty) {
          final usdPerOz = (decoded.first['gold'] as num).toDouble();

          // Get live INR rate if available, else use fallback
          double usdInr = AppConstants.fallbackUsdInr;
          try {
            final exRates = await _fetchExchangeRates();
            if (exRates != null && exRates['INR'] != null) {
              usdInr = (exRates['INR'] as num).toDouble();
            }
          } catch (_) {}

          final inrPerGram =
              usdPerOz * usdInr / AppConstants.troyOunceInGrams;

          final model = RateModel(
            title: 'Gold Rate',
            value: '${_formatINR(inrPerGram)} / g',
            updatedAt: DateTime.now(),
            icon: Icons.monetization_on_rounded,
            iconBgColor: const Color(0xFFFFF8E1),
            iconFgColor: const Color(0xFFFF8F00),
            numericValue: inrPerGram,
            previousNumericValue: prev,
          );
          _cache[key] = model;
          return model;
        }
      }
    } catch (_) {}

    // ── Fallback: estimated current gold rate per gram ──
    return _cache[key] ??
        RateModel(
          title: 'Gold Rate',
          value: '7,200 / g',
          updatedAt: DateTime.now(),
          icon: Icons.monetization_on_rounded,
          iconBgColor: const Color(0xFFFFF8E1),
          iconFgColor: const Color(0xFFFF8F00),
          numericValue: 7200,
        );
  }

  // ── Silver ───────────────────────────────────────────────
  Future<RateModel> getSilverPrice() async {
    const key = 'silver';
    final prev = _cache[key]?.numericValue;

    // ── Strategy 1: Exchange rate API (XAG base → INR) ──
    try {
      final uri = Uri.parse(AppConstants.silverExchangeApiUrl);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final rates = decoded['rates'] as Map<String, dynamic>?;
        if (rates != null && rates.containsKey('INR')) {
          // 1 XAG (troy ounce) = X INR → convert to per kg
          final inrPerOz = (rates['INR'] as num).toDouble();
          final inrPerKg = inrPerOz * 1000 / AppConstants.troyOunceInGrams;
          final model = RateModel(
            title: 'Silver Rate',
            value: '${_formatINR(inrPerKg)} / kg',
            updatedAt: DateTime.now(),
            icon: Icons.diamond_rounded,
            iconBgColor: const Color(0xFFECEFF1),
            iconFgColor: const Color(0xFF546E7A),
            numericValue: inrPerKg,
            previousNumericValue: prev,
          );
          _cache[key] = model;
          return model;
        }
      }
    } catch (_) {}

    // ── Strategy 2: metals.live (backup) ──
    try {
      final uri = Uri.parse(AppConstants.silverApiUrl);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List && decoded.isNotEmpty) {
          final usdPerOz = (decoded.first['silver'] as num).toDouble();
          double usdInr = AppConstants.fallbackUsdInr;
          try {
            final exRates = await _fetchExchangeRates();
            if (exRates != null && exRates['INR'] != null) {
              usdInr = (exRates['INR'] as num).toDouble();
            }
          } catch (_) {}
          final inrPerKg =
              usdPerOz * usdInr * 1000 / AppConstants.troyOunceInGrams;
          final model = RateModel(
            title: 'Silver Rate',
            value: '${_formatINR(inrPerKg)} / kg',
            updatedAt: DateTime.now(),
            icon: Icons.diamond_rounded,
            iconBgColor: const Color(0xFFECEFF1),
            iconFgColor: const Color(0xFF546E7A),
            numericValue: inrPerKg,
            previousNumericValue: prev,
          );
          _cache[key] = model;
          return model;
        }
      }
    } catch (_) {}

    return _cache[key] ??
        RateModel(
          title: 'Silver Rate',
          value: '85,200 / kg',
          updatedAt: DateTime.now(),
          icon: Icons.diamond_rounded,
          iconBgColor: const Color(0xFFECEFF1),
          iconFgColor: const Color(0xFF546E7A),
          numericValue: 85200,
        );
  }

  // ── Bitcoin ──────────────────────────────────────────────
  Future<RateModel> getBitcoinPrice() async {
    const key = 'btc';
    final prev = _cache[key]?.numericValue;
    try {
      final uri = Uri.parse(AppConstants.bitcoinApiUrl);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final btc = decoded['bitcoin'] as Map<String, dynamic>;
        final inr = (btc['inr'] as num).toDouble();
        final model = RateModel(
          title: 'Bitcoin',
          value: _formatINR(inr),
          updatedAt: DateTime.now(),
          icon: Icons.currency_bitcoin_rounded,
          iconBgColor: const Color(0xFFFFF3E0),
          iconFgColor: const Color(0xFFE65100),
          numericValue: inr,
          previousNumericValue: prev,
        );
        _cache[key] = model;
        return model;
      }
    } catch (_) {}
    return _cache[key] ??
        RateModel(
          title: 'Bitcoin',
          value: '56,40,000',
          updatedAt: DateTime.now(),
          icon: Icons.currency_bitcoin_rounded,
          iconBgColor: const Color(0xFFFFF3E0),
          iconFgColor: const Color(0xFFE65100),
        );
  }

  // ── Exchange rates (shared fetch) ────────────────────────
  Future<Map<String, dynamic>?> _fetchExchangeRates() async {
    if (_lastExchangeRates != null) return _lastExchangeRates;
    try {
      final uri = Uri.parse(AppConstants.usdInrApiUrl);
      final res = await _client.get(uri).timeout(AppConstants.httpTimeout);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        _lastExchangeRates = decoded['rates'] as Map<String, dynamic>?;
        return _lastExchangeRates;
      }
    } catch (_) {}
    return null;
  }

  void clearExchangeCache() => _lastExchangeRates = null;

  /// Public method to get all exchange rates (used by Currency Converter).
  Future<Map<String, dynamic>?> getExchangeRates() async {
    // Clear cache to get fresh rates
    _lastExchangeRates = null;
    return _fetchExchangeRates();
  }

  // ── USD → INR ────────────────────────────────────────────
  Future<RateModel> getUsdInrRate() async {
    const key = 'usdinr';
    final prev = _cache[key]?.numericValue;
    final rates = await _fetchExchangeRates();
    if (rates != null) {
      final inr = (rates['INR'] as num).toDouble();
      final model = RateModel(
        title: 'USD to INR',
        value: inr.toStringAsFixed(2),
        updatedAt: DateTime.now(),
        icon: Icons.currency_exchange_rounded,
        iconBgColor: const Color(0xFFE0F2F1),
        iconFgColor: const Color(0xFF00695C),
        numericValue: inr,
        previousNumericValue: prev,
      );
      _cache[key] = model;
      return model;
    }
    return _cache[key] ??
        RateModel(
          title: 'USD to INR',
          value: '83.50',
          updatedAt: DateTime.now(),
          icon: Icons.currency_exchange_rounded,
          iconBgColor: const Color(0xFFE0F2F1),
          iconFgColor: const Color(0xFF00695C),
        );
  }

  // ── EUR → INR ────────────────────────────────────────────
  Future<RateModel> getEurInrRate() async {
    const key = 'eurinr';
    final prev = _cache[key]?.numericValue;
    final rates = await _fetchExchangeRates();
    if (rates != null && rates['INR'] != null && rates['EUR'] != null) {
      final inr = (rates['INR'] as num).toDouble();
      final eur = (rates['EUR'] as num).toDouble();
      // EUR/INR = INR per USD / EUR per USD
      final eurInr = inr / eur;
      final model = RateModel(
        title: 'EUR to INR',
        value: eurInr.toStringAsFixed(2),
        updatedAt: DateTime.now(),
        icon: Icons.euro_rounded,
        iconBgColor: const Color(0xFFE3F2FD),
        iconFgColor: const Color(0xFF1565C0),
        numericValue: eurInr,
        previousNumericValue: prev,
      );
      _cache[key] = model;
      return model;
    }
    return _cache[key] ??
        RateModel(
          title: 'EUR to INR',
          value: '90.40',
          updatedAt: DateTime.now(),
          icon: Icons.euro_rounded,
          iconBgColor: const Color(0xFFE3F2FD),
          iconFgColor: const Color(0xFF1565C0),
        );
  }

  // ── Petrol ───────────────────────────────────────────────
  Future<RateModel> getPetrolPrice() async {
    const key = 'petrol';
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final model = _cache[key] ??
        RateModel(
          title: 'Petrol Price',
          value: '104.95 / L',
          updatedAt: DateTime.now(),
          icon: Icons.local_gas_station_rounded,
          iconBgColor: const Color(0xFFFFEBEE),
          iconFgColor: const Color(0xFFC62828),
          numericValue: 104.95,
        );
    _cache[key] = model;
    return model;
  }

  // ── Diesel ───────────────────────────────────────────────
  Future<RateModel> getDieselPrice() async {
    const key = 'diesel';
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final model = _cache[key] ??
        RateModel(
          title: 'Diesel Price',
          value: '92.27 / L',
          updatedAt: DateTime.now(),
          icon: Icons.oil_barrel_rounded,
          iconBgColor: const Color(0xFFFCE4EC),
          iconFgColor: const Color(0xFFAD1457),
          numericValue: 92.27,
        );
    _cache[key] = model;
    return model;
  }

  // ── Nifty 50 ─────────────────────────────────────────────
  Future<RateModel> getNifty50() async {
    const key = 'nifty';
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final model = _cache[key] ??
        RateModel(
          title: 'Nifty 50',
          value: '22,480',
          updatedAt: DateTime.now(),
          icon: Icons.show_chart_rounded,
          prefix: '',
          iconBgColor: const Color(0xFFE8EAF6),
          iconFgColor: const Color(0xFF283593),
          numericValue: 22480,
        );
    _cache[key] = model;
    return model;
  }

  // ── Helpers ──────────────────────────────────────────────
  String _formatINR(double n) {
    final intPart = n.truncate();
    final s = intPart.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    var remaining = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    while (remaining.length > 2) {
      buf.write('${remaining.substring(remaining.length - 2)},');
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) buf.write('$remaining,');
    final reversed =
        buf.toString().split('').reversed.join().replaceFirst(',', '');
    return '$reversed,$last3';
  }

  void dispose() => _client.close();
}
