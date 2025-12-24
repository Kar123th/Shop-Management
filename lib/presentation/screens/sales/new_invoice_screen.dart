import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_management_app/data/models/product_model.dart';
import 'package:shop_management_app/data/models/sale_model.dart';
import 'package:shop_management_app/data/services/database_service.dart';
import 'package:shop_management_app/presentation/providers/product_provider.dart';
import 'package:shop_management_app/data/services/invoice_service.dart';
import 'package:shop_management_app/presentation/providers/sale_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class NewInvoiceScreen extends ConsumerStatefulWidget {
  const NewInvoiceScreen({super.key});

  @override
  ConsumerState<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends ConsumerState<NewInvoiceScreen> {
  final List<SaleItem> _cartItems = [];
  final _customerNameController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isLoading = false;

  double get _subTotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  double get _taxTotal => _cartItems.fold(0, (sum, item) => sum + (item.total * item.gstRate / 100));
  double get _totalAmount => _subTotal + _taxTotal;

  void _addProductToCart(Product product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
      if (existingIndex != -1) {
        final existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = SaleItem(
          id: existingItem.id,
          saleId: '',
          productId: product.id,
          productName: product.name,
          quantity: existingItem.quantity + 1,
          unitPrice: product.salePrice,
          gstRate: product.gstRate,
          total: (existingItem.quantity + 1) * product.salePrice,
        );
      } else {
        _cartItems.add(SaleItem(
          id: const Uuid().v4(),
          saleId: '',
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.salePrice,
          gstRate: product.gstRate,
          total: product.salePrice,
        ));
      }
    });
    _searchController.clear();
  }

  void _updateQuantity(int index, double newQuantity) {
    if (newQuantity <= 0) {
      setState(() => _cartItems.removeAt(index));
      return;
    }
    setState(() {
      final item = _cartItems[index];
      _cartItems[index] = SaleItem(
        id: item.id,
        saleId: item.saleId,
        productId: item.productId,
        productName: item.productName,
        quantity: newQuantity,
        unitPrice: item.unitPrice,
        gstRate: item.gstRate,
        total: newQuantity * item.unitPrice,
      );
    });
  }

  Future<void> _processBill() async {
    if (_cartItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final saleId = const Uuid().v4();
      
      final sale = Sale(
        id: saleId,
        userId: user?.id ?? '00000000-0000-0000-0000-000000000000',
        customerName: _customerNameController.text.isEmpty ? 'Counter Sale' : _customerNameController.text,
        items: _cartItems.map((item) => SaleItem(
          id: const Uuid().v4(),
          saleId: saleId,
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          gstRate: item.gstRate,
          total: item.total,
        )).toList(),
        subTotal: _subTotal,
        taxAmount: _taxTotal,
        totalAmount: _totalAmount,
        paymentMethod: 'Cash',
        createdAt: DateTime.now(),
      );

      // Use SaleRepository for local save + supabase sync
      await ref.read(saleRepositoryProvider).addSale(sale);
      
      // Refresh providers to show updated stock and sales
      ref.invalidate(productsProvider);
      ref.invalidate(salesProvider);

      if (mounted) {
        // Show success and Generate PDF
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: Text('Total Amount: ₹${_totalAmount.toStringAsFixed(2)}\nStock updated and Bill generated.'),
            actions: [
              TextButton(
                onPressed: () async {
                  await InvoiceService.generateAndShareInvoice(sale);
                  if (mounted) {
                    Navigator.pop(context);
                    context.pop();
                  }
                },
                child: const Text('Share PDF Bill'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
      ),
      body: Column(
        children: [
          // Customer & Search Row
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name (Optional)',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                productsAsync.when(
                  data: (products) => Autocomplete<Product>(
                    displayStringForOption: (Product p) => p.name,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') return const Iterable<Product>.empty();
                      return products.where((p) => p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: _addProductToCart,
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search Product (e.g. Milk, Bread)',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading products'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Cart Items List
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(child: Text('Add products to the bill'))
                : ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return ListTile(
                        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Price: ₹${item.unitPrice} | GST: ${item.gstRate}%'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _updateQuantity(index, item.quantity - 1),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _updateQuantity(index, item.quantity + 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Billing Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 4, spreadRadius: 1)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                    Text('₹${_subTotal.toStringAsFixed(2)}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax (GST):', style: TextStyle(fontSize: 16)),
                    Text('₹${_taxTotal.toStringAsFixed(2)}'),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('₹${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processBill,
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GENERATE BILL', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
