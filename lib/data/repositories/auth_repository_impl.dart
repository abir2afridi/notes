import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

import '../datasources/remote/remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final RemoteDataSource _remoteDataSource = RemoteDataSource();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '555017411804-smeb60af0frhpdrcl7rpsi2n5ur15qha.apps.googleusercontent.com',
  );

  @override
  Stream<UserEntity?> get authStateChanges => _firebaseAuth
      .authStateChanges()
      .map((user) => user != null ? UserEntity.fromFirebaseUser(user) : null);

  @override
  UserEntity? get currentUser => _firebaseAuth.currentUser != null
      ? UserEntity.fromFirebaseUser(_firebaseAuth.currentUser!)
      : null;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final entity = UserEntity.fromFirebaseUser(userCredential.user!);
        // Save/Update profile in Firestore
        await _remoteDataSource.saveUserProfile({
          'uid': entity.id,
          'email': entity.email,
          'displayName': entity.displayName,
          'photoUrl': entity.photoUrl,
          'lastLogin': FieldValue.serverTimestamp(),
        });
        return entity;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return UserEntity.fromFirebaseUser(credential.user!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final entity = UserEntity.fromFirebaseUser(credential.user!);
        // Save profile to Firestore
        await _remoteDataSource.saveUserProfile({
          'uid': entity.id,
          'email': entity.email,
          'displayName': entity.displayName,
          'photoUrl': entity.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return entity;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
