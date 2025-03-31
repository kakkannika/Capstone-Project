import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Handles environment configuration and API keys
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  
  factory EnvConfig() => _instance;
  
  EnvConfig._internal();
  
  /// Initialize the configuration
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Could not load .env file: $e");
    }
  }
  
  /// Get Google Maps API key
  static String get googleMapsApiKey {
    // First check the .env file
    final envKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    
    // Fallback to const value only in debug mode (not recommended for production)
    if (kDebugMode) {
      return const String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
        defaultValue: '',
      );
    }
    
    throw Exception('Google Maps API key not found. Please set it in your .env file');
  }
} 