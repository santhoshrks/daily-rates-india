import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/rate_model.dart';
import '../services/api_service.dart';

/// Possible states of [RatesProvider].
enum RatesStatus { loading, loaded, error }

/// Provider that manages all rate-fetching logic, caching, auto-refresh,
/// loading / error states, search filtering, and exposes results to the UI.
class RatesProvider extends ChangeNotifier {
  RatesProvider({ApiService? apiService})
      : _api = apiService ?? ApiService() {
    fetchAll();
    _startAutoRefresh();
  }

  final ApiService _api;
  Timer? _refreshTimer;

  // ── State ────────────────────────────────────────────────
  RatesStatus _status = RatesStatus.loading;
  RatesStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<RateModel> _rates = [];
  List<RateModel> get rates => List.unmodifiable(_rates);

  // ── Search / filter ──────────────────────────────────────
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  List<RateModel> get filteredRates {
    if (_searchQuery.isEmpty) return rates;
    return _rates
        .where((r) => r.title.toLowerCase().contains(_searchQuery))
        .toList();
  }

  // ── Last refresh tracking ────────────────────────────────
  DateTime? _lastRefreshedAt;
  DateTime? get lastRefreshedAt => _lastRefreshedAt;

  // ── Fetch ────────────────────────────────────────────────
  Future<void> fetchAll() async {
    _status = RatesStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Clear shared exchange-rate cache so both USD & EUR get fresh data.
      _api.clearExchangeCache();

      final results = await Future.wait([
        _api.getGoldPrice(),
        _api.getSilverPrice(),
        _api.getPetrolPrice(),
        _api.getDieselPrice(),
        _api.getUsdInrRate(),
        _api.getEurInrRate(),
        _api.getBitcoinPrice(),
        _api.getNifty50(),
      ]);

      _rates = results;
      _lastRefreshedAt = DateTime.now();
      _status = RatesStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = RatesStatus.error;
    }
    notifyListeners();
  }

  // ── Auto-refresh ─────────────────────────────────────────
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      AppConstants.refreshInterval,
      (_) => fetchAll(),
    );
  }

  // ── Cleanup ──────────────────────────────────────────────
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _api.dispose();
    super.dispose();
  }
}
