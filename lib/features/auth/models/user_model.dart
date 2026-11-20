import 'package:firebase_auth/firebase_auth.dart' as fb;

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final String? providerId;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isEmailVerified = false,
    this.providerId,
    this.createdAt,
    this.lastSignInTime,
  });

  /// Factory constructor to map from Firebase's [User] object.
  factory UserModel.fromFirebaseUser(fb.User user) {
    String? provider;
    if (user.providerData.isNotEmpty) {
      provider = user.providerData.first.providerId;
    }

    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
      providerId: provider,
      createdAt: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
    );
  }

  /// Create a [UserModel] from a key-value Map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      isEmailVerified: (map['isEmailVerified'] as bool?) ?? false,
      providerId: map['providerId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      lastSignInTime: map['lastSignInTime'] != null
          ? DateTime.tryParse(map['lastSignInTime'] as String)
          : null,
    );
  }

  /// Convert model instance to a JSON Map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'providerId': providerId,
      'createdAt': createdAt?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isEmailVerified,
    String? providerId,
    DateTime? createdAt,
    DateTime? lastSignInTime,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          isEmailVerified == other.isEmailVerified &&
          providerId == other.providerId;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      isEmailVerified.hashCode ^
      providerId.hashCode;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, providerId: $providerId)';
  }
}

