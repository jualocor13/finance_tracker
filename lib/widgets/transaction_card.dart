import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          transaction.isExpense ? Icons.arrow_downward_outlined : Icons.arrow_upward_outlined,
          color: transaction.isExpense ? Colors.red : Colors.green,
        ),
        title: Text(transaction.title),
        subtitle: Text(transaction.category),
        trailing: Text(
          '\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
              color: transaction.isExpense ? Colors.red : Colors.green),
        ),
      ),
    );
  }
}
