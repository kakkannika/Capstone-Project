class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl, required bool isAnonymous,
  });

  
}
