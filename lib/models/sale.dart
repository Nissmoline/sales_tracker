import 'package:hive/hive.dart';

part 'sale.g.dart';

@HiveType(typeId: 0)
class Sale {
  @HiveField(0)
  final String product;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String comments;

  @HiveField(3)
  final DateTime date;

  Sale({
    required this.product,
    required this.amount,
    required this.comments,
    required this.date,
  });
}
