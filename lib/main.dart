import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'models/sale.dart';
import 'providers/sales_provider.dart';
import 'providers/products_provider.dart';
import 'screens/home_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/statistics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(SaleAdapter());
  await Hive.openBox<Sale>('salesBox');

  final productsProvider = ProductsProvider();
  await productsProvider.loadProducts();

  final salesProvider = SalesProvider();
  salesProvider.loadSales();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => salesProvider),
        ChangeNotifierProvider(create: (_) => productsProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales App',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', 'DE'),
      ],
      locale: const Locale('de', 'DE'),
      home: HomeScreen(),
      routes: {
        SalesScreen.routeName: (ctx) => SalesScreen(),
        StatisticsScreen.routeName: (ctx) => StatisticsScreen(),
      },
    );
  }
}
