import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/rates_provider.dart';
import '../../widgets/shared_app_bar.dart';

/// Gold Value Calculator — uses live gold rate to compute gold value.
class GoldValueCalculatorPage extends StatefulWidget {
  const GoldValueCalculatorPage({super.key});

  @override
  State<GoldValueCalculatorPage> createState() =>
      _GoldValueCalculatorPageState();
}

class _GoldValueCalculatorPageState extends State<GoldValueCalculatorPage> {
  final _weightController = TextEditingController(text: '10');
  int _selectedKarat = 24;

  static const List<int> karats = [24, 22, 18, 14];
  static const Map<int, String> karatDescriptions = {
    24: '99.9% Pure Gold',
    22: '91.6% Pure (Jewellery)',
    18: '75.0% Pure',
    14: '58.5% Pure',
  };

  double get _weight =>
      double.tryParse(_weightController.text.replaceAll(',', '')) ?? 0;

  double _getGoldPricePerGram(RatesProvider provider) {
    // Try to get from the cached gold rate
    final goldRate = provider.rates.where(
      (r) => r.title.toLowerCase().contains('gold'),
    );
    if (goldRate.isNotEmpty && goldRate.first.numericValue != null) {
      final val = goldRate.first.numericValue!;
      // If value contains "/ g" in the rate, it's per gram
      // If value contains "/ 10 g" it's per 10g
      final rateValue = goldRate.first.value.toLowerCase();
      if (rateValue.contains('10')) {
        return val / 10;
      }
      return val;
    }
    // Fallback: approx gold rate per gram in INR
    return 7200;
  }

  String _formatCurrency(double value) {
    if (value <= 0) return '₹ 0';
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '₹ ${formatter.format(value.round())}';
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<RatesProvider>();
    final pricePerGram24K = _getGoldPricePerGram(provider);
    final pricePerGramKarat = pricePerGram24K * _selectedKarat / 24;
    final totalValue = _weight * pricePerGramKarat;

    return Scaffold(
      body: Column(
        children: [
          const SharedAppBar(
            title: 'Gold Value Calculator',
            subtitle: 'Calculate gold value at live rates',
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Live Rate Banner ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8F00), Color(0xFFFFC107)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded,
                                color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Live Gold Rate (24K)',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_formatCurrency(pricePerGram24K)} / gram',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Input Card ──
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF8F00)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.scale_rounded,
                                      color: Color(0xFFFF8F00),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Gold Details',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Weight
                              Text('Weight (grams)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme
                                          .textTheme.titleMedium?.color)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  suffixText: 'grams',
                                  hintText: 'e.g. 10',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 20),

                              // Karat
                              Text('Gold Purity (Karat)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme
                                          .textTheme.titleMedium?.color)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: karats.map((k) {
                                  final isSelected = _selectedKarat == k;
                                  return ChoiceChip(
                                    label: Text('${k}K'),
                                    selected: isSelected,
                                    onSelected: (_) =>
                                        setState(() => _selectedKarat = k),
                                    selectedColor: const Color(0xFFFF8F00),
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme
                                              .textTheme.titleMedium?.color,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    checkmarkColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  );
                                }).toList(),
                              ),
                              if (karatDescriptions[_selectedKarat] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    karatDescriptions[_selectedKarat]!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFFFF8F00),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Results Card ──
                      if (_weight > 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Value highlight
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF8F00),
                                        Color(0xFFFFC107),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Gold Value (${_selectedKarat}K)',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _formatCurrency(totalValue),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _GoldResultRow(
                                  label: 'Weight',
                                  value: '${_weight.toStringAsFixed(2)} grams',
                                  color: const Color(0xFF37474F),
                                ),
                                const Divider(height: 20),
                                _GoldResultRow(
                                  label: 'Purity',
                                  value:
                                      '${_selectedKarat}K (${(_selectedKarat / 24 * 100).toStringAsFixed(1)}%)',
                                  color: const Color(0xFFFF8F00),
                                ),
                                const Divider(height: 20),
                                _GoldResultRow(
                                  label: 'Rate per gram (${_selectedKarat}K)',
                                  value: _formatCurrency(pricePerGramKarat),
                                  color: const Color(0xFF1565C0),
                                ),
                                const Divider(height: 20),
                                _GoldResultRow(
                                  label: 'Total Value',
                                  value: _formatCurrency(totalValue),
                                  color: const Color(0xFF2E7D32),
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
}

class _GoldResultRow extends StatelessWidget {
  const _GoldResultRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

