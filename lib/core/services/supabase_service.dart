import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static const String _bucketName = 'images';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://wpkhueqjfnyzfdouboza.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indwa2h1ZXFqZm55emZkb3Vib3phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwOTM3NDQsImV4cCI6MjA4MTY2OTc0NH0.lortoaYZwwwrsb4199ZdNPIOpJcpwIp52ZBrcAvAoPg',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<String?> uploadImage(File file, String fileName) async {
    try {
      final String path = 'foods/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      
      await client.storage.from(_bucketName).upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
      
      final String publicUrl = client.storage.from(_bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image to Supabase: $e');
      return null;
    }
  }
}
