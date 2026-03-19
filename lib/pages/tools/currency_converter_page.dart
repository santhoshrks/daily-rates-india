import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../widgets/shared_app_bar.dart';

/// Currency Converter — convert between currencies using live exchange rates.
class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final _amountController = TextEditingController(text: '1');
  final ApiService _apiService = ApiService();

  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';
  Map<String, double> _rates = {};
  bool _isLoading = true;
  String? _error;

  // Popular currencies for India & nearby countries
  static const List<String> popularCurrencies = [
    'INR', 'USD', 'EUR', 'GBP', 'AED', 'SAR', 'SGD', 'JPY',
    'AUD', 'CAD', 'CHF', 'CNY', 'BDT', 'LKR', 'NPR', 'PKR',
    'MYR', 'THB', 'KWD', 'QAR', 'OMR', 'BHD', 'HKD', 'NZD',
  ];

  static const Map<String, String> currencyNames = {
    'INR': '🇮🇳 Indian Rupee',
    'USD': '🇺🇸 US Dollar',
    'EUR': '🇪🇺 Euro',
    'GBP': '🇬🇧 British Pound',
    'AED': '🇦🇪 UAE Dirham',
    'SAR': '🇸🇦 Saudi Riyal',
    'SGD': '🇸🇬 Singapore Dollar',
    'JPY': '🇯🇵 Japanese Yen',
    'AUD': '🇦🇺 Australian Dollar',
    'CAD': '🇨🇦 Canadian Dollar',
    'CHF': '🇨🇭 Swiss Franc',
    'CNY': '🇨🇳 Chinese Yuan',
    'BDT': '🇧🇩 Bangladeshi Taka',
    'LKR': '🇱🇰 Sri Lankan Rupee',
    'NPR': '🇳🇵 Nepalese Rupee',
    'PKR': '🇵🇰 Pakistani Rupee',
    'MYR': '🇲🇾 Malaysian Ringgit',
    'THB': '🇹🇭 Thai Baht',
    'KWD': '🇰🇼 Kuwaiti Dinar',
    'QAR': '🇶🇦 Qatari Riyal',
    'OMR': '🇴🇲 Omani Rial',
    'BHD': '🇧🇭 Bahraini Dinar',
    'HKD': '🇭🇰 Hong Kong Dollar',
    'NZD': '🇳🇿 New Zealand Dollar',
  };

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final ratesMap = await _apiService.getExchangeRates();
      if (ratesMap != null) {
        setState(() {
          _rates = ratesMap.map(
              (key, value) => MapEntry(key, (value as num).toDouble()));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Could not load exchange rates. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load rates: $e';
        _isLoading = false;
      });
    }
  }

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  double get _convertedAmount {
    if (_rates.isEmpty || _amount <= 0) return 0;
    // All rates are relative to USD
    final fromRate = _rates[_fromCurrency] ?? 1;
    final toRate = _rates[_toCurrency] ?? 1;
    return _amount * toRate / fromRate;
  }

  double get _exchangeRate {
    if (_rates.isEmpty) return 0;
    final fromRate = _rates[_fromCurrency] ?? 1;
    final toRate = _rates[_toCurrency] ?? 1;
    return toRate / fromRate;
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  String _formatNumber(double value) {
    if (value <= 0) return '0';
    if (value >= 1) {
      final formatter = NumberFormat('#,##,##0.00', 'en_IN');
      return formatter.format(value);
    }
    return value.toStringAsFixed(4);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const SharedAppBar(
            title: 'Currency Converter',
            subtitle: 'Live exchange rates',
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: Color(0xFFE65100)),
                        SizedBox(height: 16),
                        Text('Loading exchange rates...'),
                      ],
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _loadRates,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Converter Card ──
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00695C)
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .currency_exchange_rounded,
                                                color: Color(0xFF00695C),
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Convert Currency',
                                              style: theme
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Amount
                                        Text('Amount',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.color)),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _amountController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                              decimal: true),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter amount',
                                          ),
                                          onChanged: (_) =>
                                              setState(() {}),
                                        ),
                                        const SizedBox(height: 20),

                                        // From / Swap / To
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  _buildCurrencyDropdown(
                                                label: 'From',
                                                value: _fromCurrency,
                                                onChanged: (val) =>
                                                    setState(() =>
                                                        _fromCurrency =
                                                            val ?? 'USD'),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                      top: 20),
                                              child: IconButton.filled(
                                                onPressed: _swapCurrencies,
                                                icon: const Icon(Icons
                                                    .swap_horiz_rounded),
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(
                                                          0xFFE65100),
                                                  foregroundColor:
                                                      Colors.white,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child:
                                                  _buildCurrencyDropdown(
                                                label: 'To',
                                                value: _toCurrency,
                                                onChanged: (val) =>
                                                    setState(() =>
                                                        _toCurrency =
                                                            val ?? 'INR'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // ── Result Card ──
                                if (_amount > 0)
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          // Converted amount highlight
                                          Container(
                                            width: double.infinity,
                                            padding:
                                                const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              gradient:
                                                  const LinearGradient(
                                                colors: [
                                                  Color(0xFF00695C),
                                                  Color(0xFF26A69A),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      14),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${_formatNumber(_amount)} $_fromCurrency =',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '${_formatNumber(_convertedAmount)} $_toCurrency',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),

                                          // Exchange rate info
                                          Container(
                                            padding: const EdgeInsets.all(
                                                12),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                const Icon(
                                                    Icons.info_outline,
                                                    size: 16,
                                                    color:
                                                        Color(0xFF00695C)),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '1 $_fromCurrency = ${_exchangeRate.toStringAsFixed(4)} $_toCurrency',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color:
                                                        Color(0xFF00695C),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final availableCurrencies = popularCurrencies
        .where((c) => _rates.containsKey(c))
        .toList();
    // Ensure current value is in the list
    if (!availableCurrencies.contains(value)) {
      availableCurrencies.insert(0, value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleMedium?.color)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: availableCurrencies.map((currency) {
            final name = currencyNames[currency] ?? currency;
            return DropdownMenuItem(
              value: currency,
              child: Text(
                name,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}


