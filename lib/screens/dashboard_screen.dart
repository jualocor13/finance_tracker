import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Transaction> transactions = [
    Transaction(
      id: 't1',
      title: 'Café',
      amount: 3.5,
      date: DateTime.now(),
      category: 'Alimentación',
      isExpense: true,
    ),
    Transaction(
      id: 't2',
      title: 'Salario',
      amount: 1200,
      date: DateTime.now(),
      category: 'Ingresos',
      isExpense: false,
    ),
  ];

  double getTotalIncome() {
    return transactions
        .where((t) => !t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    return transactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  void _addNewTransaction(Transaction newTx) {
    setState(() {
      transactions.add(newTx);
    });
  }

  void _openAddTransactionScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          onAddTransaction: _addNewTransaction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BalanceCard(
              totalBalance: getTotalBalance(),
              totalIncome: getTotalIncome(),
              totalExpense: getTotalExpense(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transacciones Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('No hay transacciones aún'))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return TransactionCard(transaction: tx);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openAddTransactionScreen(context),
      ),
    );
  }
}
