// Main User Model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/models/user/user_preference.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final UserPreferences preferences;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.preferences,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AppUser(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'].toDate(),
      preferences: UserPreferences.fromMap(data['preferences']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toMap(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] is String 
          ? DateTime.parse(map['createdAt']) 
          : (map['createdAt'] as Timestamp).toDate(),
      preferences: map['preferences'] is Map 
          ? UserPreferences.fromMap(map['preferences'])
          : UserPreferences(),
    );
  }
}