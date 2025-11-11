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
      transactions.where((t) => t.isExpense).fold(0, (sum, t) => sum + t.amount);

  double get totalIncomes =>
      transactions.where((t) => !t.isExpense).fold(0, (sum, t) => sum + t.amount);

  List<PieChartSectionData> buildPieData(Map<String, double> data, bool isExpense) {
    final total = data.values.fold(0.0, (sum, v) => sum + v); // Cambiado a 0.0 para que sea un double
      final colors = [
        Colors.blueAccent,
        Colors.orangeAccent,
        Colors.greenAccent,
        Colors.purpleAccent,
        Colors.redAccent,
        Colors.tealAccent,
      ];

      int colorIndex = 0;
      return data.entries.map((entry) {
        final percentage = ((entry.value / total) * 100).toStringAsFixed(1);
        final section = PieChartSectionData(
          color: colors[colorIndex++ % colors.length],
          value: entry.value,
          title: '${entry.key}\n$percentage%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        );
        return section;
      }).toList();
    }

    @override
  Widget build(BuildContext context) {
    final expensesData = getExpensesByCategory();
    final incomesData = getIncomesByCategory();

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: transactions.isEmpty
            ? const Center(child: Text('No hay transacciones para mostrar.'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Gastos por Categoría',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: buildPieData(expensesData, true),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Ingresos por Categoría',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: buildPieData(incomesData, false),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
    );
  }
}
