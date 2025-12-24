import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shop_management_app/data/models/product_model.dart';
import 'package:shop_management_app/data/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(Supabase.instance.client);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts();
});
