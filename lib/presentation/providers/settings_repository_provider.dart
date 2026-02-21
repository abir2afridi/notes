import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import 'remote_provider.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource);
});
