import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final categoryTotals = provider.categoryTotals;
        final totalExpenses = provider.totalExpenses;

        if (totalExpenses == 0) {
          return const Center(
            child: Text('No expenses to analyze yet!'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _createPieSections(
                                categoryTotals, totalExpenses),
                            sectionsSpace: 2,
                            centerSpaceRadius: 10,
                            startDegreeOffset: -90,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...categoryTotals.entries.map((entry) {
                        final category = provider.categories
                            .firstWhere((cat) => cat.id == entry.key);
                        final percentage = (entry.value / totalExpenses) * 100;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Color(category.colorValue),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(category.name),
                              ),
                              Text(
                                '\₹${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow(
                          'Total Income', provider.totalIncome, Colors.green),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                          'Total Expenses', provider.totalExpenses, Colors.red),
                      const Divider(),
                      _buildSummaryRow('Net Balance', provider.balance,
                          provider.balance >= 0 ? Colors.green : Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _createPieSections(
    Map<String, double> categoryTotals,
    double totalExpenses,
  ) {
    final List<PieChartSectionData> sections = [];
    final colors = [
      const Color(0xFF2196F3), // Blue
      const Color(0xFFF44336), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF795548), // Brown
      const Color(0xFF009688), // Teal
      const Color(0xFFE91E63), // Pink
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
    ];

    int colorIndex = 0;
    categoryTotals.forEach((categoryId, amount) {
      final percentage = (amount / totalExpenses) * 100;
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: colors[colorIndex % colors.length],
        ),
      );
      colorIndex++;
    });

    return sections;
  }

  Widget _buildSummaryRow(String title, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          '\₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
