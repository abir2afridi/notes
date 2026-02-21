import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/constants/app_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConstants.firebaseSyncEnabled) {
    return AuthRepositoryImpl();
  }
  // Return a mock repository when Firebase is disabled
  return MockAuthRepository();
});

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Mock Auth Repository for when Firebase is disabled
class MockAuthRepository implements AuthRepository {
  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(null);

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) async =>
      null;

  @override
  Future<UserEntity?> signUpWithEmail(String email, String password) async =>
      null;

  @override
  Future<UserEntity?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}

  @override
  UserEntity? get currentUser => null;

  @override
  Future<void> resetPassword(String email) async {}
}
