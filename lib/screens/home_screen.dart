import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/sales_provider.dart';
import 'sales_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Sales Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).pushNamed(StatisticsScreen.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'de_DE',
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Monat',
              CalendarFormat.twoWeeks: '2 Wochen',
              CalendarFormat.week: 'Woche',
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return salesProvider.getSalesByDate(day);
            },
          ),

          // Static for selcted day
          if (_selectedDay != null) _buildSelectedDateStats(salesProvider),

          // List of sales
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text(
                        'Wählen Sie ein Datum, um die Verkäufe anzuzeigen.'),
                  )
                : _buildSalesList(context, salesProvider, _selectedDay!),
          ),
        ],
      ),
      floatingActionButton: _selectedDay == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  SalesScreen.routeName,
                  arguments: _selectedDay,
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildSelectedDateStats(SalesProvider salesProvider) {
    final day = _selectedDay!;
    // Sales for the selected day
    final salesForDay = salesProvider.getSalesByDate(day);
    final dayCount = salesForDay.length;
    final daySum = salesForDay.fold(0.0, (sum, sale) => sum + sale.amount);

    // Sales for the selected month
    final salesForMonth = salesProvider.salesList.where((sale) {
      return sale.date.year == day.year && sale.date.month == day.month;
    }).toList();
    final monthCount = salesForMonth.length;
    final monthSum = salesForMonth.fold(0.0, (sum, sale) => sum + sale.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics for the day
          Text(
            'Ausgewählter Tag: Verträge = $dayCount, Betrag = €$daySum',
            style: const TextStyle(fontSize: 12),
          ),
          // Monthly statistics
          Text(
            'Gleicher Monat: Verträge = $monthCount, Betrag = €$monthSum',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList(
    BuildContext context,
    SalesProvider salesProvider,
    DateTime date,
  ) {
    final salesForDate = salesProvider.getSalesByDate(date);

    if (salesForDate.isEmpty) {
      return const Center(
        child: Text('Keine Verkäufe für das ausgewählte Datum gefunden.'),
      );
    }

    return ListView.builder(
      itemCount: salesForDate.length,
      itemBuilder: (context, index) {
        final sale = salesForDate[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text('${sale.product} - \€${sale.amount}'),
            subtitle: Text(
              sale.comments.isEmpty ? 'Kein Kommentar' : sale.comments,
            ),
          ),
        );
      },
    );
  }
}
