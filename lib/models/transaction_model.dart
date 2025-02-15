import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? note;

  @HiveField(6)
  bool isExpense;

  TransactionModel({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
    required this.isExpense,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'note': note,
      'isExpense': isExpense,
    };
  }
}
