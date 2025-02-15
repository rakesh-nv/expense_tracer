import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../services/expense_provider.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  String? _selectedCategory;
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction?.title ?? '');
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(text: widget.transaction?.note ?? '');
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _isExpense = widget.transaction?.isExpense ?? true;
    
    // Initialize category in initState
    if (widget.transaction != null) {
      _selectedCategory = widget.transaction!.category;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize category with the first available category if not already set
    if (_selectedCategory == null) {
      final categories = Provider.of<ExpenseProvider>(context, listen: false).categories;
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first.id;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
          // Update selected category if categories are loaded and none is selected
          if (_selectedCategory == null && expenseProvider.categories.isNotEmpty) {
            _selectedCategory = expenseProvider.categories.first.id;
          }

          if (expenseProvider.categories.isEmpty) {
            return const Center(
              child: Text('Please add some categories first!'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Type Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Income'),
                      Switch(
                        value: _isExpense,
                        onChanged: (value) {
                          setState(() => _isExpense = value);
                        },
                      ),
                      const Text('Expense'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixText: '\₹ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  if (_selectedCategory != null) // Only show dropdown if category is selected
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: expenseProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCategory = value);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Note Field
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: () => _saveTransaction(expenseProvider),
                    child: const Text('Save Transaction'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveTransaction(ExpenseProvider provider) {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final transaction = TransactionModel(
        id: widget.transaction?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory!,
        note: _noteController.text,
        isExpense: _isExpense,
      );
      
      if (widget.transaction == null) {
        provider.addTransaction(transaction);
      } else {
        provider.updateTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }
}
