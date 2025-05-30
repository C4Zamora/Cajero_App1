import 'package:flutter/material.dart';
import '../models/transaction.dart';

class RecentTransactions extends StatelessWidget {
  final Future<List<Transaction>> transactionsFuture;

  const RecentTransactions({
    Key? key,
    required this.transactionsFuture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Transaction>>(
      future: transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final transactions = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: transactions.map((tx) {
            return ListTile(
              leading: Icon(tx.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward),
              title: Text(tx.description),
              subtitle: Text('${tx.date.toLocal()}'.split(' ')[0]),
              trailing: Text('\$${tx.amount.toStringAsFixed(2)}'),
            );
          }).toList(),
        );
      },
    );
  }
}
