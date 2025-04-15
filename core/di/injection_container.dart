import 'package:get_it/get_it.dart';

import '../../features/history/data/datasources/local_history_datasource.dart';
import '../../features/history/data/repositories/favorites_repository_impl.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/domain/repositories/favorites_repository.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/usecases/add_favorite_usecase.dart';
import '../../features/history/domain/usecases/add_scan_history_usecase.dart';
import '../../features/history/domain/usecases/clear_history_usecase.dart';
import '../../features/history/domain/usecases/get_favorites_usecase.dart';
import '../../features/history/domain/usecases/get_history_usecase.dart';
import '../../features/history/domain/usecases/remove_favorite_usecase.dart';
import '../../features/history/domain/usecases/update_scan_note_usecase.dart';
import '../../features/history/presentation/cubit/favorites_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';

/// Service Locator Instance
final sl = GetIt.instance;

/// Initialize the dependency injection container
Future<void> init() async {
  // Register instances

  // Core

  // Features - History
  // BLoC/Cubit
  sl.registerFactory(
    () => HistoryCubit(
      getHistoryUseCase: sl(),
      addScanHistoryUseCase: sl(),
      clearHistoryUseCase: sl(),
      updateScanNoteUseCase: sl(),
      addFavoriteUseCase: sl(),
      removeFavoriteUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FavoritesCubit(
      getFavoritesUseCase: sl(),
      addFavoriteUseCase: sl(),
      removeFavoriteUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddScanHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => ClearHistoryUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateScanNoteUseCase(repository: sl()));
  
  sl.registerLazySingleton(() => GetFavoritesUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddFavoriteUseCase(repository: sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUseCase(repository: sl()));

  // Repositories
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(localDataSource: sl()),
  );
  
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<LocalHistoryDataSource>(
    () => LocalHistoryDataSourceImpl(),
  );
}