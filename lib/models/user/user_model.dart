import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  final List<UserInfo>? providerData;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.phoneNumber,
    this.providerData,
  });

  factory UserModel.fromFirebaseUser(User user) {    
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? 'User',
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
      providerData: user.providerData,
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    String? phoneNumber,
    List<UserInfo>? providerData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      providerData: providerData ?? this.providerData,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'uid': uid,
      'email': email,
      'displayName': displayName ?? 'User',
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'providerData': providerData?.map((provider) => {
        'providerId': provider.providerId,
        'email': provider.email,
        'displayName': provider.displayName,
      }).toList() ?? [],
    };
    print('UserModel - Converting to Map: $map'); // Debug log
    return map;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    print('UserModel - Creating from Map: $map'); // Debug log
    
    if (map['uid'] == null || map['uid'].toString().isEmpty) {
      print('UserModel - Error: Invalid map data (missing or empty UID)'); // Debug log
      throw Exception('Invalid map data: Missing or empty UID');
    }

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'] ?? 'User',
      photoURL: map['photoURL'],
      emailVerified: map['emailVerified'] ?? false,
      phoneNumber: map['phoneNumber'],
      providerData: null,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
  }
}