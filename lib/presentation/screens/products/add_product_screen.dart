import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_management_app/data/models/product_model.dart';
import 'package:shop_management_app/presentation/providers/product_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _skuController = TextEditingController();
  final _hsnController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockController = TextEditingController(text: '5');
  File? _imageFile;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  String _selectedUnit = 'Pcs';
  double _selectedGst = 0;

  final List<String> _units = ['Pcs', 'Kg', 'Ltr', 'Box', 'Mtr', 'Dozen'];
  final List<double> _gstRates = [0, 5, 12, 18, 28];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),

              // Barcode and HSN
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(
                        labelText: 'SKU',
                        prefixIcon: Icon(Icons.tag),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _hsnController,
                      decoration: const InputDecoration(
                        labelText: 'HSN',
                        prefixIcon: Icon(Icons.code),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Unit and GST
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      value: _selectedGst,
                      decoration: const InputDecoration(
                        labelText: 'GST %',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      items: _gstRates.map((rate) {
                        return DropdownMenuItem(
                          value: rate,
                          child: Text('$rate%'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGst = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sale Price and Purchase Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sale Price *',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Price',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock and Low Stock Alert
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Opening Stock',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lowStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Low Stock Alert',
                        prefixIcon: Icon(Icons.warning),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final user = Supabase.instance.client.auth.currentUser;
      
      // If user is not logged in, we try anonymous sign in or throw error
      // For now, let's assume they might need an ID. 
      // If RLS is off, we can use a placeholder.
      final userId = user?.id ?? '00000000-0000-0000-0000-000000000000';

      String? imageUrl;
      if (_imageFile != null) {
        final fileName = '${const Uuid().v4()}.jpg';
        imageUrl = await repository.uploadImage(_imageFile!.path, fileName);
      }

      final product = Product(
        id: const Uuid().v4(),
        userId: userId,
        name: _nameController.text,
        description: _descriptionController.text,
        barcode: _barcodeController.text,
        sku: _skuController.text,
        hsnCode: _hsnController.text,
        unit: _selectedUnit,
        salePrice: double.parse(_salePriceController.text),
        purchasePrice: double.tryParse(_purchasePriceController.text),
        gstRate: _selectedGst,
        stockQuantity: double.tryParse(_stockController.text) ?? 0,
        lowStockAlert: double.tryParse(_lowStockController.text) ?? 5,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.addProduct(product);

      if (mounted) {
        // Refresh products list
        ref.invalidate(productsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _skuController.dispose();
    _hsnController.dispose();
    _salePriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }
}
