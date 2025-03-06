class UserPreferences {
  final String currency;
  final bool darkMode;
  final int dailyActivityLimit;

  UserPreferences({
    this.currency = 'USD',
    this.darkMode = false,
    this.dailyActivityLimit = 5,
  });

  factory UserPreferences.fromMap(Map data) {
    return UserPreferences(
      currency: data['currency'] ?? 'USD',
      darkMode: data['darkMode'] ?? false,
      dailyActivityLimit: data['dailyActivityLimit'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'darkMode': darkMode,
      'dailyActivityLimit': dailyActivityLimit,
    };
  }
}