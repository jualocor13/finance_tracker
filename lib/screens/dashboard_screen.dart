import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
  late Box<Transaction> transactionBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<Transaction>('transactionsBox');
  }

  List<Transaction> get transactions => transactionBox.values.toList();

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
    transactionBox.add(newTx);
    setState(() {});
  }

  void _deleteTransaction(int index) {
    transactionBox.deleteAt(index);
    setState(() {});
  }

  void _editTransaction(Transaction tx, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final titleController = TextEditingController(text: tx.title);
        final amountController = TextEditingController(
          text: tx.amount.toString(),
        );
        String category = tx.category;
        bool isExpense = tx.isExpense;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Transacción',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: category,
                items:
                    ['General', 'Alimentación', 'Transporte', 'Ocio', 'Salario']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (val) => category = val!,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              SwitchListTile(
                title: const Text('¿Es gasto?'),
                value: isExpense,
                onChanged: (val) => setState(() => isExpense = val),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final updatedTx = Transaction(
                    id: tx.id,
                    title: titleController.text,
                    amount: double.tryParse(amountController.text) ?? tx.amount,
                    date: tx.date,
                    category: category,
                    isExpense: isExpense,
                  );
                  transactionBox.putAt(index, updatedTx);
                  Navigator.pop(ctx);
                  setState(() {});
                },
                child: const Text('Guardar cambios'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _openAddTransactionScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddTransactionScreen(onAddTransaction: _addNewTransaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
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
                        return Dismissible(
                          key: Key(tx.id),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) => _deleteTransaction(index),
                          child: GestureDetector(
                            onTap: () => _editTransaction(tx, index),
                            child: TransactionCard(transaction: tx),
                          ),
                        );
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
