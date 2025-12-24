import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_management_app/data/models/sale_model.dart';
import 'package:shop_management_app/data/repositories/sale_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepository(Supabase.instance.client);
});

final salesProvider = FutureProvider<List<Sale>>((ref) async {
  final repository = ref.watch(saleRepositoryProvider);
  return repository.getSales();
});

final todaySalesTotalProvider = Provider<double>((ref) {
  final salesAsync = ref.watch(salesProvider);
  return salesAsync.when(
    data: (sales) {
      final now = DateTime.now();
      final todaySales = sales.where((sale) =>
          sale.createdAt.year == now.year &&
          sale.createdAt.month == now.month &&
          sale.createdAt.day == now.day);
      return todaySales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
