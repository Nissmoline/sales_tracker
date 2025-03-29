import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../providers/products_provider.dart';
import '../models/sale.dart';
import '../models/product.dart';

class SalesScreen extends StatefulWidget {
  static const routeName = '/sales_screen';

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TextEditingController _autoController;
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _autoController = TextEditingController();
  }

  @override
  void dispose() {
    _productController.dispose();
    _amountController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is DateTime) {
      _selectedDate = args;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);

    final salesForThisDate = salesProvider.getSalesByDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verkäufe hinzufügen / anzeigen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Sales for: \${_selectedDate.toLocal()}'.split(' ')[0],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Autocomplete<Product>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final query = textEditingValue.text.toLowerCase();
                      if (query.isEmpty) {
                        return productsProvider.products;
                      }
                      return productsProvider.products.where((product) {
                        return product.name.toLowerCase().contains(query);
                      });
                    },
                    displayStringForOption: (Product option) => option.name,
                    onSelected: (Product selection) {
                      _autoController.text = selection.name;
                      _productController.text = selection.name;
                    },
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      _autoController = textEditingController;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Produkt / Dienstleistung (durchsuchbar)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Geben Sie den Namen eines Produkts oder einer Dienstleistung ein';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  TextFormField(
                    controller: _productController,
                    decoration: const InputDecoration(
                      labelText: 'Ausgewähltes Produkt',
                    ),
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Betrag'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || double.tryParse(value) == null) {
                        return 'Geben Sie einen gültigen Betrag ein';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _commentsController,
                    decoration: const InputDecoration(labelText: 'Kommentare'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final newSale = Sale(
                              product: _productController.text,
                              amount: double.tryParse(_amountController.text) ??
                                  0.0,
                              comments: _commentsController.text,
                              date: _selectedDate,
                            );
                            salesProvider.addSale(newSale);
                            _autoController.clear();
                            _productController.clear();
                            _amountController.clear();
                            _commentsController.clear();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Verkaufsinformationen gespeichert!'),
                              ),
                            );
                          }
                        },
                        child: const Text('Speichern'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          _autoController.clear();
                          _productController.clear();
                          _amountController.clear();
                          _commentsController.clear();
                        },
                        child: const Text('Löschen'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Startseite'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: salesForThisDate.isEmpty
                  ? const Center(
                      child:
                          Text('Keine Verkäufe für dieses Datum verzeichnet.'),
                    )
                  : ListView.builder(
                      itemCount: salesForThisDate.length,
                      itemBuilder: (ctx, index) {
                        final sale = salesForThisDate[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('${sale.product} - €${sale.amount}'),
                            subtitle: Text(
                              sale.comments.isEmpty
                                  ? 'Keine Kommentare'
                                  : sale.comments,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showEditDialog(context, sale);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    final allSales = Provider.of<SalesProvider>(
                                            context,
                                            listen: false)
                                        .salesList;
                                    final realIndex = allSales.indexOf(sale);
                                    if (realIndex != -1) {
                                      Provider.of<SalesProvider>(context,
                                              listen: false)
                                          .deleteSale(realIndex);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Sale sale) {
    final editingProductController = TextEditingController(text: sale.product);
    final editingAmountController =
        TextEditingController(text: sale.amount.toString());
    final editingCommentsController =
        TextEditingController(text: sale.comments);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Verkauf bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editingProductController,
                  decoration: const InputDecoration(
                      labelText: 'Produkt / Dienstleistung'),
                ),
                TextField(
                  controller: editingAmountController,
                  decoration: const InputDecoration(labelText: 'Betrag'),
                ),
                TextField(
                  controller: editingCommentsController,
                  decoration: const InputDecoration(labelText: 'Kommentare'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Speichern'),
              onPressed: () {
                final updatedSale = Sale(
                  product: editingProductController.text,
                  amount: double.tryParse(editingAmountController.text) ?? 0.0,
                  comments: editingCommentsController.text,
                  date: sale.date,
                );
                final allSales =
                    Provider.of<SalesProvider>(context, listen: false)
                        .salesList;
                final realIndex = allSales.indexOf(sale);
                if (realIndex != -1) {
                  Provider.of<SalesProvider>(context, listen: false)
                      .updateSale(realIndex, updatedSale);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
