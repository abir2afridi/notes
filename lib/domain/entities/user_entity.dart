import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory UserEntity.fromFirebaseUser(firebase_auth.User user) {
    return UserEntity(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
