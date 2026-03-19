import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/shared_app_bar.dart';

/// GST Calculator — compute CGST, SGST, IGST and total with GST.
class GstCalculatorPage extends StatefulWidget {
  const GstCalculatorPage({super.key});

  @override
  State<GstCalculatorPage> createState() => _GstCalculatorPageState();
}

class _GstCalculatorPageState extends State<GstCalculatorPage> {
  final _amountController = TextEditingController(text: '10000');
  double _selectedRate = 18;
  bool _isInclusive = false; // false = exclusive (add GST), true = inclusive (extract GST)

  static const List<double> gstSlabs = [5, 12, 18, 28];

  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  // Exclusive: GST on top of amount
  double get _gstAmount {
    if (_isInclusive) {
      return _amount - (_amount * 100 / (100 + _selectedRate));
    }
    return _amount * _selectedRate / 100;
  }

  double get _cgst => _gstAmount / 2;
  double get _sgst => _gstAmount / 2;

  double get _totalAmount {
    if (_isInclusive) return _amount;
    return _amount + _gstAmount;
  }

  double get _baseAmount {
    if (_isInclusive) return _amount - _gstAmount;
    return _amount;
  }

  String _formatCurrency(double value) {
    if (value <= 0) return '₹ 0';
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹ ${formatter.format(value)}';
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
            title: 'GST Calculator',
            subtitle: 'Calculate GST for any amount',
            showRefresh: false,
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
                                      color: const Color(0xFF1565C0)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      color: Color(0xFF1565C0),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'GST Details',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Amount
                              Text('Amount (₹)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme
                                          .textTheme.titleMedium?.color)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixText: '₹ ',
                                  hintText: 'e.g. 10,000',
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 20),

                              // GST Type toggle
                              Text('GST Type',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme
                                          .textTheme.titleMedium?.color)),
                              const SizedBox(height: 8),
                              SegmentedButton<bool>(
                                segments: const [
                                  ButtonSegment(
                                    value: false,
                                    label: Text('GST Exclusive'),
                                    icon: Icon(Icons.add_circle_outline,
                                        size: 18),
                                  ),
                                  ButtonSegment(
                                    value: true,
                                    label: Text('GST Inclusive'),
                                    icon: Icon(Icons.remove_circle_outline,
                                        size: 18),
                                  ),
                                ],
                                selected: {_isInclusive},
                                onSelectionChanged: (val) =>
                                    setState(() => _isInclusive = val.first),
                              ),
                              const SizedBox(height: 20),

                              // GST Rate
                              Text('GST Rate',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme
                                          .textTheme.titleMedium?.color)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: gstSlabs.map((rate) {
                                  final isSelected = _selectedRate == rate;
                                  return ChoiceChip(
                                    label: Text('${rate.toInt()}%'),
                                    selected: isSelected,
                                    onSelected: (_) =>
                                        setState(() => _selectedRate = rate),
                                    selectedColor: const Color(0xFFE65100),
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Results Card ──
                      if (_amount > 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Total highlight
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF42A5F5),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Total Amount (with GST)',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _formatCurrency(_totalAmount),
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

                                _GstResultRow(
                                  label: 'Base Amount',
                                  value: _formatCurrency(_baseAmount),
                                  color: const Color(0xFF37474F),
                                ),
                                const Divider(height: 20),
                                _GstResultRow(
                                  label:
                                      'CGST (${(_selectedRate / 2).toStringAsFixed(1)}%)',
                                  value: _formatCurrency(_cgst),
                                  color: const Color(0xFF1565C0),
                                ),
                                const Divider(height: 20),
                                _GstResultRow(
                                  label:
                                      'SGST (${(_selectedRate / 2).toStringAsFixed(1)}%)',
                                  value: _formatCurrency(_sgst),
                                  color: const Color(0xFF1565C0),
                                ),
                                const Divider(height: 20),
                                _GstResultRow(
                                  label:
                                      'Total GST (${_selectedRate.toInt()}%)',
                                  value: _formatCurrency(_gstAmount),
                                  color: const Color(0xFFE65100),
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

class _GstResultRow extends StatelessWidget {
  const _GstResultRow({
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

