import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/shared_app_bar.dart';

/// EMI Calculator — computes monthly EMI, total interest & total payment.
class EmiCalculatorPage extends StatefulWidget {
  const EmiCalculatorPage({super.key});

  @override
  State<EmiCalculatorPage> createState() => _EmiCalculatorPageState();
}

class _EmiCalculatorPageState extends State<EmiCalculatorPage> {
  final _loanAmountController = TextEditingController(text: '1000000');
  final _interestRateController = TextEditingController(text: '8.5');
  final _tenureController = TextEditingController(text: '20');
  bool _tenureInYears = true;

  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final principal = double.tryParse(
            _loanAmountController.text.replaceAll(',', '')) ??
        0;
    final annualRate =
        double.tryParse(_interestRateController.text) ?? 0;
    final tenureInput =
        double.tryParse(_tenureController.text) ?? 0;

    if (principal <= 0 || annualRate <= 0 || tenureInput <= 0) {
      setState(() {
        _emi = 0;
        _totalInterest = 0;
        _totalPayment = 0;
        _hasCalculated = false;
      });
      return;
    }

    final months = _tenureInYears ? tenureInput * 12 : tenureInput;
    final monthlyRate = annualRate / 12 / 100;

    // EMI = P × r × (1+r)^n / ((1+r)^n - 1)
    final powFactor = pow(1 + monthlyRate, months);
    final emi = principal * monthlyRate * powFactor / (powFactor - 1);

    setState(() {
      _emi = emi;
      _totalPayment = emi * months;
      _totalInterest = _totalPayment - principal;
      _hasCalculated = true;
    });
  }

  String _formatCurrency(double value) {
    if (value <= 0) return '₹ 0';
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '₹ ${formatter.format(value.round())}';
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const SharedAppBar(
            title: 'EMI Calculator',
            subtitle: 'Calculate your loan EMI instantly',
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
                                      color: const Color(0xFFE65100)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_rounded,
                                      color: Color(0xFFE65100),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loan Details',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Loan Amount
                              Text('Loan Amount (₹)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _loanAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  prefixText: '₹ ',
                                  hintText: 'e.g. 10,00,000',
                                ),
                                onChanged: (_) => _calculate(),
                              ),
                              const SizedBox(height: 20),

                              // Interest Rate
                              Text('Annual Interest Rate (%)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.textTheme.titleMedium?.color)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _interestRateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  suffixText: '%',
                                  hintText: 'e.g. 8.5',
                                ),
                                onChanged: (_) => _calculate(),
                              ),
                              const SizedBox(height: 20),

                              // Tenure
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Loan Tenure',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.color),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _tenureController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: _tenureInYears
                                                ? 'e.g. 20'
                                                : 'e.g. 240',
                                          ),
                                          onChanged: (_) => _calculate(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    children: [
                                      const SizedBox(height: 22),
                                      SegmentedButton<bool>(
                                        segments: const [
                                          ButtonSegment(
                                              value: true, label: Text('Yr')),
                                          ButtonSegment(
                                              value: false, label: Text('Mo')),
                                        ],
                                        selected: {_tenureInYears},
                                        onSelectionChanged: (val) {
                                          setState(() =>
                                              _tenureInYears = val.first);
                                          _calculate();
                                        },
                                        style: ButtonStyle(
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Results Card ──
                      if (_hasCalculated)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // EMI highlight
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE65100),
                                        Color(0xFFFF8F00)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Monthly EMI',
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
                                          _formatCurrency(_emi),
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

                                // Breakdown
                                _ResultRow(
                                  label: 'Principal Amount',
                                  value: _formatCurrency(double.tryParse(
                                          _loanAmountController.text
                                              .replaceAll(',', '')) ??
                                      0),
                                  color: const Color(0xFF1565C0),
                                ),
                                const Divider(height: 20),
                                _ResultRow(
                                  label: 'Total Interest',
                                  value: _formatCurrency(_totalInterest),
                                  color: const Color(0xFFC62828),
                                ),
                                const Divider(height: 20),
                                _ResultRow(
                                  label: 'Total Payment',
                                  value: _formatCurrency(_totalPayment),
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({
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

