// Main User Model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/domain/models/user/user_preference.dart';

enum UserRole {
  admin,
  user,
}

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final UserPreferences preferences;
  final UserRole? role;

  AppUser(
      {required this.uid,
      required this.email,
      this.displayName,
      this.photoUrl,
      required this.createdAt,
      required this.preferences,
      this.role});

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
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'preferences': preferences.toMap(),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    UserPreferences? preferences,
    UserRole? role,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      role: role ?? this.role,
    );
  }
}
