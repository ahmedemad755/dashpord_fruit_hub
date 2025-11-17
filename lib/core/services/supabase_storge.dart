import 'dart:io';

import 'package:fruitesdashboard/core/const/const.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:path/path.dart' as b;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorgeService implements StorgeService {
  static Future<void> initSupabase() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  Future<void> ensureBucketExists(String bucketName) async {
    final client = Supabase.instance.client;

    try {
      // هات كل البوكيتات
      final buckets = await client.storage.listBuckets();

      // شوف إذا البوكيت موجود
      final exists = buckets.any((bucket) => bucket.name == bucketName);

      if (!exists) {
        await client.storage.createBucket(bucketName);
        print('✅ Bucket $bucketName created successfully');
      } else {
        print('ℹ️ Bucket $bucketName already exists, skipping creation');
      }
    } catch (e) {
      print('❌ Error checking/creating bucket: $e');
    }
  }

  @override
  Future<String?> uploadImage(File file, String path) async {
    try {
      final fileName = b.basename(file.path);
      final filePath = '$path/$fileName';

      await Supabase.instance.client.storage
          .from(supabaseBucketName)
          .upload(filePath, file);

      final publicUrl = Supabase.instance.client.storage
          .from(supabaseBucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } on StorageException catch (e) {
      print('Storage Error: ${e.message}');
      return null;
    } catch (e) {
      print('Unexpected Error: $e');
      return null;
    }
  }
}
