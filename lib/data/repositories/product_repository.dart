import 'package:shop_management_app/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRepository {
  final SupabaseClient _supabase;

  ProductRepository(this._supabase);

  Future<List<Product>> getProducts() async {
    final response = await _supabase.from('products').select();
    return (response as List).map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getProduct(String id) async {
    final response = await _supabase.from('products').select().eq('id', id).single();
    return Product.fromMap(response);
  }

  Future<void> addProduct(Product product) async {
    await _supabase.from('products').insert(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _supabase.from('products').update(product.toMap()).eq('id', product.id);
  }

  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }
}
