import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sale.dart';

class SalesProvider with ChangeNotifier {
  final List<Sale> _salesList = [];

  List<Sale> get salesList => List.unmodifiable(_salesList);

  void addSale(Sale sale) {
    _salesList.add(sale);
    Hive.box<Sale>('salesBox').add(sale);
    notifyListeners();
  }

  void updateSale(int index, Sale updatedSale) {
    _salesList[index] = updatedSale;
    Hive.box<Sale>('salesBox').putAt(index, updatedSale);
    notifyListeners();
  }

  void deleteSale(int index) {
    _salesList.removeAt(index);
    Hive.box<Sale>('salesBox').deleteAt(index);
    notifyListeners();
  }

  List<Sale> getSalesByDate(DateTime date) {
    return _salesList
        .where(
          (sale) =>
              sale.date.year == date.year &&
              sale.date.month == date.month &&
              sale.date.day == date.day,
        )
        .toList();
  }

  void loadSales() {
    final box = Hive.box<Sale>('salesBox');
    _salesList.clear();
    _salesList.addAll(box.values);
    notifyListeners();
  }
}
