import 'package:aether/core/time/server_time_service.dart';
import 'package:aether/features/raid/data/datasources/raid_remote_datasource.dart';
import 'package:aether/features/raid/data/repositories/raid_repository_impl.dart';
import 'package:aether/features/raid/domain/repositories/raid_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<ServerTimeService>(() => ServerTimeService(sl()));

  await sl<ServerTimeService>().sync();

  sl.registerLazySingleton<RaidRemoteDataSource>(
    () => RaidRemoteDataSource(sl(), sl()),
  );

  sl.registerLazySingleton<RaidRepository>(() => RaidRepositoryImpl(sl()));
}
