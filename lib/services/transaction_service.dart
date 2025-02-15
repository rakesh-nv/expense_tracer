import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static const String _boxName = 'transactions';
  late Box<TransactionModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<TransactionModel>(_boxName);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _box.add(transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await transaction.save();
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    await transaction.delete();
  }

  List<TransactionModel> getAllTransactions() {
    return _box.values.toList();
  }

  List<TransactionModel> getTransactionsByMonth(DateTime date) {
    return _box.values
        .where((transaction) =>
            transaction.date.year == date.year &&
            transaction.date.month == date.month)
        .toList();
  }

  double getTotalExpensesByMonth(DateTime date) {
    return _box.values
        .where((transaction) =>
            transaction.date.year == date.year &&
            transaction.date.month == date.month &&
            transaction.isExpense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getTotalIncomeByMonth(DateTime date) {
    return _box.values
        .where((transaction) =>
            transaction.date.year == date.year &&
            transaction.date.month == date.month &&
            !transaction.isExpense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  Map<String, double> getCategoryTotalsByMonth(DateTime date) {
    final transactions = getTransactionsByMonth(date);
    final Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return categoryTotals;
  }

  Future<String> exportToCSV() async {
    final transactions = getAllTransactions();
    final csv = [
      ['Date', 'Category', 'Note', 'Amount', 'Type'],
      ...transactions.map((transaction) => [
            transaction.date.toIso8601String(),
            transaction.category,
            transaction.note ?? '',
            '₹${transaction.amount.toStringAsFixed(2)}',
            transaction.isExpense ? 'Expense' : 'Income',
          ]),
    ];

    final String csvData = const ListToCsvConverter().convert(csv);
    final directory = await getApplicationDocumentsDirectory();
    final String path =
        '${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv';

    final File file = File(path);
    await file.writeAsString(csvData);

    return path;
  }

  Future<String> exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Expense Tracker - Transactions Report'),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Date',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Category',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Note',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Amount',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('Type',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...getAllTransactions().map(
                    (transaction) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              transaction.date.toString().split(' ')[0]),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(transaction.category),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(transaction.note ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            '${transaction.amount.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              color: transaction.isExpense
                                  ? PdfColors.red
                                  : PdfColors.green,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              transaction.isExpense ? 'Expense' : 'Income'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1]}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final String path =
        '${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    return path;
  }
}
