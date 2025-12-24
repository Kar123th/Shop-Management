import 'dart:io';
import 'package:shop_management_app/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shop_management_app/data/services/database_service.dart';

class ProductRepository {
  final SupabaseClient _supabase;
  final DatabaseService _db = DatabaseService();

  ProductRepository(this._supabase);

  Future<List<Product>> getProducts() async {
    // 1. Get from local database (Fast & Offline)
    final localProducts = await _db.getProducts();
    
    // 2. Try to sync unsynced products in background
    _syncProcesses();
    
    return localProducts;
  }

  Future<void> _syncProcesses() async {
    await _syncUnsyncedProducts();
    await _syncFromRemote();
  }

  Future<void> _syncUnsyncedProducts() async {
    try {
      final unsynced = await _db.getUnsyncedProducts();
      for (var product in unsynced) {
        await _supabase.from('products').insert(product.toMap());
        await _db.updateSyncStatus(product.id, true);
      }
    } catch (e) {
      print('Sync unsynced products failed: $e');
    }
  }

  Future<void> _syncFromRemote() async {
    try {
      final response = await _supabase.from('products').select().order('updated_at', ascending: false);
      final remoteProducts = (response as List).map((e) => Product.fromMap(e)).toList();
      
      for (var product in remoteProducts) {
        await _db.insertProduct(product);
        await _db.updateSyncStatus(product.id, true);
      }
    } catch (e) {
      print('Sync from remote failed: $e');
    }
  }

  Future<Product?> getProduct(String id) async {
    // Try local first
    final localProducts = await _db.getProducts();
    try {
      return localProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      final response = await _supabase.from('products').select().eq('id', id).single();
      return Product.fromMap(response);
    }
  }

  Future<void> addProduct(Product product) async {
    // 1. Save to local DB immediately (Works offline)
    await _db.insertProduct(product);

    // 2. Try to save to Supabase
    try {
      await _supabase.from('products').insert(product.toMap());
      await _db.updateSyncStatus(product.id, true);
    } catch (e) {
      print('Failed to sync product to remote: $e');
      // It stays in local DB with is_synced = 0
    }
  }

  Future<String?> uploadImage(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final path = 'product_images/$fileName';
      await _supabase.storage.from('products').upload(path, file);
      final url = _supabase.storage.from('products').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Error uploading image to Supabase: $e');
      // For images, we might want to store local path if offline
      // but typical offline-first for images is more complex.
      // For now, we return null if upload fails.
      return null;
    }
  }

  Future<void> updateProduct(Product product) async {
    await _db.insertProduct(product);
    try {
      await _supabase.from('products').update(product.toMap()).eq('id', product.id);
      await _db.updateSyncStatus(product.id, true);
    } catch (e) {
      print('Update sync failed: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    // Implementation for delete sync...
    await _supabase.from('products').delete().eq('id', id);
  }
}

