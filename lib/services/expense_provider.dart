import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import 'transaction_service.dart';
import 'category_service.dart';

class ExpenseProvider with ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  final CategoryService _categoryService = CategoryService();
  
  DateTime _selectedMonth = DateTime.now();
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  
  ExpenseProvider() {
    _init();
  }

  DateTime get selectedMonth => _selectedMonth;
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;

  Future<void> _init() async {
    await _transactionService.init();
    await _categoryService.init();
    _loadData();
  }

  void _loadData() {
    _transactions = _transactionService.getTransactionsByMonth(_selectedMonth);
    _categories = _categoryService.getAllCategories();
    notifyListeners();
  }

  void changeMonth(DateTime month) {
    _selectedMonth = month;
    _loadData();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionService.addTransaction(transaction);
    _loadData();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionService.updateTransaction(transaction);
    _loadData();
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    await _transactionService.deleteTransaction(transaction);
    _loadData();
  }

  double get totalExpenses => 
      _transactionService.getTotalExpensesByMonth(_selectedMonth);

  double get totalIncome => 
      _transactionService.getTotalIncomeByMonth(_selectedMonth);

  double get balance => totalIncome - totalExpenses;

  Map<String, double> get categoryTotals =>
      _transactionService.getCategoryTotalsByMonth(_selectedMonth);

  Future<void> addCategory(CategoryModel category) async {
    await _categoryService.addCategory(category);
    _loadData();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoryService.updateCategory(category);
    _loadData();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryService.deleteCategory(id);
    _loadData();
  }

  Future<String> exportToCSV() async {
    return await _transactionService.exportToCSV();
  }

  Future<String> exportToPDF() async {
    return await _transactionService.exportToPDF();
  }
}
