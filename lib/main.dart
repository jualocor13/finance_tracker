import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Inicializa Hive
  await Hive.initFlutter();

  // Registra el adaptador de Transaction
  Hive.registerAdapter(TransactionAdapter());

  // Abre la caja (base de datos local)
  await Hive.openBox<Transaction>('transactionsBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleTransactions = [
      Transaction(
          id: 't1',
          title: 'Café',
          amount: 3.5,
          date: DateTime.now(),
          category: 'Alimentación',
          isExpense: true),
      Transaction(
          id: 't2',
          title: 'Salario',
          amount: 1200,
          date: DateTime.now(),
          category: 'Ingresos',
          isExpense: false),
    ];

    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DashboardScreen(),
    );
  }
}
