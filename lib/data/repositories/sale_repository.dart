import 'package:shop_management_app/data/models/sale_model.dart';
import 'package:shop_management_app/data/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleRepository {
  final SupabaseClient _supabase;
  final DatabaseService _db = DatabaseService();

  SaleRepository(this._supabase);

  Future<void> addSale(Sale sale) async {
    // 1. Save to local DB
    await _db.insertSale(sale);

    // 2. Try to sync to Supabase immediately
    await _syncSaleToRemote(sale);
  }

  Future<void> _syncSaleToRemote(Sale sale) async {
    try {
      // Insert Sale
      await _supabase.from('sales').insert(sale.toMap());
      
      // Insert Sale Items
      final itemsMap = sale.items.map((item) => item.toMap()).toList();
      await _supabase.from('sale_items').insert(itemsMap);
      
      // Update local sync status
      await _db.updateSaleSyncStatus(sale.id, true);
    } catch (e) {
      print('Sale sync to remote failed: $e');
    }
  }

  Future<void> syncUnsyncedSales() async {
    try {
      final unsynced = await _db.getUnsyncedSales();
      for (var sale in unsynced) {
        await _syncSaleToRemote(sale);
      }
    } catch (e) {
      print('Sync unsynced sales failed: $e');
    }
  }

  Future<List<Sale>> getSales() async {
    return _db.getSales();
  }
}
