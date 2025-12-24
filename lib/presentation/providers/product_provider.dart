import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shop_management_app/data/models/product_model.dart';
import 'package:shop_management_app/data/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'product_provider.g.dart';

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  // Ensure Supabase is initialized before accessing instance.client
  return ProductRepository(Supabase.instance.client);
}

@riverpod
Future<List<Product>> products(ProductsRef ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
}
