import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/remote_data_source.dart';

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource();
});
