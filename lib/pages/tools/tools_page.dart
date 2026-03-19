import 'package:flutter/material.dart';

import '../../widgets/shared_app_bar.dart';
import '../../widgets/tool_card.dart';
import 'emi_calculator_page.dart';
import 'gst_calculator_page.dart';
import 'gold_value_calculator_page.dart';
import 'currency_converter_page.dart';

/// Tools tab — shows all 4 financial calculator tools.
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedAppBar(
            title: 'Financial Tools',
            subtitle: 'Calculators & converters for India',
            showRefresh: false,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = width >= 600 ? 2 : 1;
                    final childAspectRatio = width >= 600 ? 1.8 : 2.4;

                    return GridView.count(
                      padding: const EdgeInsets.all(20),
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: childAspectRatio,
                      children: [
                        ToolCard(
                          title: 'EMI Calculator',
                          subtitle:
                              'Calculate monthly EMI for home, car & personal loans',
                          icon: Icons.account_balance_rounded,
                          gradientColors: const [
                            Color(0xFFE65100),
                            Color(0xFFFF8F00),
                          ],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EmiCalculatorPage()),
                          ),
                        ),
                        ToolCard(
                          title: 'GST Calculator',
                          subtitle:
                              'Calculate CGST, SGST & total GST for any amount',
                          icon: Icons.receipt_long_rounded,
                          gradientColors: const [
                            Color(0xFF1565C0),
                            Color(0xFF42A5F5),
                          ],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GstCalculatorPage()),
                          ),
                        ),
                        ToolCard(
                          title: 'Gold Value Calculator',
                          subtitle:
                              'Calculate gold value based on live market rates',
                          icon: Icons.monetization_on_rounded,
                          gradientColors: const [
                            Color(0xFFFF8F00),
                            Color(0xFFFFC107),
                          ],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const GoldValueCalculatorPage()),
                          ),
                        ),
                        ToolCard(
                          title: 'Currency Converter',
                          subtitle:
                              'Convert between 24+ currencies with live rates',
                          icon: Icons.currency_exchange_rounded,
                          gradientColors: const [
                            Color(0xFF00695C),
                            Color(0xFF26A69A),
                          ],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const CurrencyConverterPage()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

