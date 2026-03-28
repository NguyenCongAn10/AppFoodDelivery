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
      if (kDebugMode) {
        debugPrint('Error uploading image to Supabase: $e');
      }
      return null;
    }
  }



  static RealtimeChannel? _ordersChannel;

  static RealtimeChannel subscribeOrders({
    required void Function(Map<String, dynamic> payload) onPayload,
    String channelName = 'public',
  }) {
    _ordersChannel?.unsubscribe();

    _ordersChannel = client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (PostgresChangePayload payload) {
            if (payload.errors != null) {
              if (kDebugMode) {
                debugPrint('--- [ERROR] SUPABASE REALTIME BLOCKED ---');
                debugPrint('Error from Supabase: ${payload.errors}');
                debugPrint('---------------------------------------');
              }
            }

            onPayload({
              'eventType': payload.eventType.name,
              'new': payload.newRecord,
              'old': payload.oldRecord,
            });
          },
        )
        .subscribe((status, [error]) {
      if (kDebugMode) {
        debugPrint('[Supabase] orders channel: $status ${error ?? ''}');
      }
    });

    return _ordersChannel!;
  }

  static Future<void> unsubscribeOrders() async {
    await _ordersChannel?.unsubscribe();
    _ordersChannel = null;
  }
}
