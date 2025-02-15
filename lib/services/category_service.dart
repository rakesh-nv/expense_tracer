import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  static const String _boxName = 'categories';
  late Box<CategoryModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<CategoryModel>(_boxName);
    if (_box.isEmpty) {
      await _addDefaultCategories();
    }
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'food',
        name: 'Food',
        colorValue: Colors.red.value,
        iconData: Icons.restaurant.codePoint,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transport',
        colorValue: Colors.blue.value,
        iconData: Icons.directions_car.codePoint,
      ),
      CategoryModel(
        id: 'bills',
        name: 'Bills',
        colorValue: Colors.orange.value,
        iconData: Icons.receipt.codePoint,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        colorValue: Colors.purple.value,
        iconData: Icons.movie.codePoint,
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        colorValue: Colors.green.value,
        iconData: Icons.shopping_bag.codePoint,
      ),
    ];

    for (var category in defaultCategories) {
      await _box.put(category.id, category);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  List<CategoryModel> getAllCategories() {
    return _box.values.toList();
  }

  CategoryModel? getCategoryById(String id) {
    return _box.get(id);
  }
}
