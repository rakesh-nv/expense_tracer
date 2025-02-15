import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/expense_provider.dart';
import '../themes/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ExpenseProvider>(
      builder: (context, themeProvider, expenseProvider, child) {
        return ListView(
          children: [
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Theme Color'),
              trailing: _buildColorPicker(context, themeProvider),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export to CSV'),
              onTap: () async {
                await _exportToCSV(context, expenseProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export to PDF'),
              onTap: () async {
                await _exportToPDF(context, expenseProvider);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorPicker(BuildContext context, ThemeProvider themeProvider) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((color) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            onTap: () => themeProvider.updatePrimaryColor(color),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeProvider.primaryColor == color
                      ? Colors.white
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _exportToCSV(
      BuildContext context, ExpenseProvider provider) async {
    try {
      final path = await provider.exportToCSV();
      if (path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await Share.shareXFiles([XFile(path)],
              subject: 'Expense Report (CSV)');
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to export CSV: ${e.toString()}');
    }
  }

  Future<void> _exportToPDF(
      BuildContext context, ExpenseProvider provider) async {
    try {
      final path = await provider.exportToPDF();
      if (path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await Share.shareXFiles([XFile(path)],
              subject: 'Expense Report (PDF)');
        }
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to export PDF: ${e.toString()}');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
