import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/expense_provider.dart';
import '../models/transaction_model.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final transactions = provider.transactions;
        
        if (transactions.isEmpty) {
          return const Center(
            child: Text('No transactions yet. Add one by tapping the + button!'),
          );
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final category = provider.categories
                .firstWhere((cat) => cat.id == transaction.category);

            return Dismissible(
              key: Key(transaction.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                provider.deleteTransaction(transaction);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Transaction deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        provider.addTransaction(transaction);
                      },
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(category.colorValue),
                  child: Icon(
                    IconData(category.iconData, fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction.title),
                subtitle: Text(
                  '${DateFormat('MMM dd, yyyy').format(transaction.date)}\n'
                  '${transaction.note ?? ""}',
                ),
                trailing: Text(
                  '\₹${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transaction.isExpense ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionFormScreen(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
