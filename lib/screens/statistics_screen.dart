import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Box<Transaction> transactionBox;
  int touchedExpenseIndex = -1;
  int touchedIncomeIndex = -1;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<Transaction>('transactionsBox');
  }

  List<Transaction> get transactions => transactionBox.values.toList();

  Map<String, double> getExpensesByCategory() {
    final Map<String, double> data = {};
    for (var tx in transactions.where((t) => t.isExpense)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }
    return data;
  }

  Map<String, double> getIncomesByCategory() {
    final Map<String, double> data = {};
    for (var tx in transactions.where((t) => !t.isExpense)) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }
    return data;
  }

  double get totalExpenses =>
      transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

  double get totalIncomes =>
      transactions.where((t) => !t.isExpense).fold(0.0, (sum, t) => sum + t.amount);

  List<PieChartSectionData> buildPieData(
    Map<String, double> data,
    bool isExpense,
    int touchedIndex,
  ) {
    final total = data.values.fold(0.0, (sum, v) => sum + v);
    final colors = [
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
    ];

    int colorIndex = 0;
    int index = 0;
    return data.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final percentage = ((entry.value / total) * 100).toStringAsFixed(1);
      final radius = isTouched ? 100.0 : 80.0; // se agranda al tocar
      final fontSize = isTouched ? 14.0 : 12.0;
      final section = PieChartSectionData(
        color: colors[colorIndex++ % colors.length],
        value: entry.value,
        title: '${entry.key}\n$percentage%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      );
      index++;
      return section;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expensesData = getExpensesByCategory();
    final incomesData = getIncomesByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No hay transacciones para mostrar.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🧠 Animación de entrada
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    child: Column(
                      children: [
                        const Text(
                          'Gastos por Categoría',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: buildPieData(
                                  expensesData, true, touchedExpenseIndex),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      touchedExpenseIndex = -1;
                                      return;
                                    }
                                    touchedExpenseIndex = response
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                            swapAnimationDuration:
                                const Duration(milliseconds: 500),
                            swapAnimationCurve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      children: [
                        const Text(
                          'Ingresos por Categoría',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: buildPieData(
                                  incomesData, false, touchedIncomeIndex),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      touchedIncomeIndex = -1;
                                      return;
                                    }
                                    touchedIncomeIndex = response
                                        .touchedSection!
                                        .touchedSectionIndex;
                                  });
                                },
                              ),
                            ),
                            swapAnimationDuration:
                                const Duration(milliseconds: 500),
                            swapAnimationCurve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Total de Gastos: \$${totalExpenses.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
                          ),
                          Text(
                            'Total de Ingresos: \$${totalIncomes.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.green, fontSize: 16),
                          ),
                          const Divider(),
                          Text(
                            'Balance: \$${(totalIncomes - totalExpenses).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: (totalIncomes - totalExpenses) >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
