import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../models/sale.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = '/statistics_screen';

  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Default: current month and year
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final allSales = salesProvider.salesList;

    //today, this month, this year
    final now = DateTime.now();
    final currentDay = DateTime(now.year, now.month, now.day);

    // for TODAY
    final todaySales = allSales.where((sale) {
      final sDay = DateTime(sale.date.year, sale.date.month, sale.date.day);
      return sDay == currentDay;
    }).toList();
    final todayCount = todaySales.length;
    final todaySum = todaySales.fold(0.0, (sum, sale) => sum + sale.amount);

    // this MONTH
    final monthSales = allSales.where((sale) {
      return sale.date.year == now.year && sale.date.month == now.month;
    }).toList();
    final monthCount = monthSales.length;
    final monthSum = monthSales.fold(0.0, (sum, sale) => sum + sale.amount);

    // this Year
    final yearSales = allSales.where((sale) {
      return sale.date.year == now.year;
    }).toList();
    final yearCount = yearSales.length;
    final yearSum = yearSales.fold(0.0, (sum, sale) => sum + sale.amount);

    // static "selected" month and year
    final selectedMonthSales = allSales.where((sale) {
      return sale.date.year == _selectedYear &&
          sale.date.month == _selectedMonth;
    }).toList();
    final selectedMonthCount = selectedMonthSales.length;
    final selectedMonthSum =
        selectedMonthSales.fold(0.0, (sum, sale) => sum + sale.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verkaufsstatistiken'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Summary STATISTICS (day/month/year)
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  _buildStatsCard(
                    label: 'Heute.',
                    count: todayCount,
                    sum: todaySum,
                  ),
                  _buildStatsCard(
                    label: 'Aktueller Monat',
                    count: monthCount,
                    sum: monthSum,
                  ),
                  _buildStatsCard(
                    label: 'Laufendes Jahr',
                    count: yearCount,
                    sum: yearSum,
                  ),
                ],
              ),
            ),

            const Divider(),

            // SELECT month/year + statistics for that month
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wählen Sie den Monat und das Jahr für die Statistik:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Select Month
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedMonth,
                          items: _buildMonthDropdownItems(),
                          onChanged: (int? newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedMonth = newVal;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Choice of the Year
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedYear,
                          items: _buildYearDropdownItems(allSales),
                          onChanged: (int? newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedYear = newVal;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Result for the selected month/year
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        'Statistiken für ${_formatMonthYear(_selectedMonth, _selectedYear)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Verträge: $selectedMonthCount\nBetrag: €$selectedMonthSum',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String label,
    required int count,
    required double sum,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 16)),
        subtitle: Text('Verträge: $count\nBetrag: €$sum'),
      ),
    );
  }

  /// cList of months
  List<DropdownMenuItem<int>> _buildMonthDropdownItems() {
    final months = List.generate(12, (index) => index + 1); // [1..12]
    return months.map((month) {
      final monthName = DateFormat.MMMM().format(DateTime(0, month));
      // For example: 1 -> "January"
      return DropdownMenuItem<int>(
        value: month,
        child: Text(monthName),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _buildYearDropdownItems(List<Sale> allSales) {
    int minYear = allSales.isEmpty
        ? DateTime.now().year
        : allSales
            .map((sale) => sale.date.year)
            .reduce((a, b) => a < b ? a : b);
    int maxYear = allSales.isEmpty
        ? DateTime.now().year
        : allSales
            .map((sale) => sale.date.year)
            .reduce((a, b) => a > b ? a : b);

    // Just in case anyone wants to look to the future as well :)
    if (maxYear < DateTime.now().year) {
      maxYear = DateTime.now().year;
    }

    final years = List<int>.generate(
      (maxYear - minYear + 1),
      (index) => minYear + index,
    );

    return years.map((year) {
      return DropdownMenuItem<int>(
        value: year,
        child: Text(year.toString()),
      );
    }).toList();
  }

  // formatting "Month YYYYYY"
  String _formatMonthYear(int month, int year) {
    return DateFormat.MMMM().format(DateTime(0, month));
  }
}
