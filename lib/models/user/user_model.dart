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
  final UserRole role;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.preferences,
    required this.role,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
      role: data['role'] != null
          ? UserRole.values[data['role'] as int]
          : UserRole.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences.toMap(),
      'role': role.index,
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

enum UserRole {
  admin,
  user,
}
