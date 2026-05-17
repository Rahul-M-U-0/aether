import 'package:aether/core/time/server_time_service.dart';
import 'package:aether/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:aether/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:aether/features/chat/domain/repositories/chat_repository.dart';
import 'package:aether/features/chat/domain/usecases/chat_usecases.dart';
import 'package:aether/features/chat/presentation/cubit/chat_cubit.dart';
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

  // CHAT
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  sl.registerLazySingleton(() => StreamMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetOlderMessagesUseCase(sl()));

  sl.registerFactory(
    () => ChatCubit(
      streamMessages: sl(),
      sendMessage: sl(),
      getOlderMessages: sl(),
    ),
  );
}
