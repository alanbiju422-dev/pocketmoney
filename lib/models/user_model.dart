/// User model representing an authenticated Google account in Pocket Money.
/// Stores per-user display preferences and onboarding completion status.
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? googleName;
  final String? photoUrl;
  final bool hasCompletedWelcome;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.googleName,
    this.photoUrl,
    this.hasCompletedWelcome = false,
    required this.createdAt,
  });

  bool get hasDisplayName => displayName != null && displayName!.trim().isNotEmpty;

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? googleName,
    String? photoUrl,
    bool? hasCompletedWelcome,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      googleName: googleName ?? this.googleName,
      photoUrl: photoUrl ?? this.photoUrl,
      hasCompletedWelcome: hasCompletedWelcome ?? this.hasCompletedWelcome,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'googleName': googleName,
      'photoUrl': photoUrl,
      'hasCompletedWelcome': hasCompletedWelcome,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      googleName: map['googleName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      hasCompletedWelcome: map['hasCompletedWelcome'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.googleName == googleName &&
        other.hasCompletedWelcome == hasCompletedWelcome;
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, googleName, hasCompletedWelcome);
}
