import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCache {
  static const String _profileImagePathKey = 'profile_image_path';
  static const String _userDataKey = 'user_data';
  
  // Save profile image to local storage
  static Future<String?> saveProfileImage(File imageFile) async {
    try {
      // Get the app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localPath = '${directory.path}/profile_$timestamp.jpg';
      
      // Copy the file to local storage
      final savedFile = await imageFile.copy(localPath);
      
      // Save the path in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImagePathKey, localPath);
      
      return localPath;
    } catch (e) {
      print('Error saving profile image locally: $e');
      return null;
    }
  }
  
  // Get the locally stored profile image
  static Future<File?> getProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_profileImagePathKey);
      
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          return file;
        }
      }
      return null;
    } catch (e) {
      print('Error getting local profile image: $e');
      return null;
    }
  }
  
  // Save user data to preferences
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userDataKey, jsonEncode(userData));
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }
  
  // Get user data from preferences
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userDataKey);
      
      if (userData != null) {
        return jsonDecode(userData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileImagePathKey);
      await prefs.remove(_userDataKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
} 