import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/manage_preferences.dart';
import 'settings_state.dart';

/// Settings cubit for managing settings state
class SettingsCubit extends Cubit<SettingsState> {
  /// Manage preferences use case
  final ManagePreferences managePreferencesUseCase;
  
  /// Current user preferences
  UserPreferences? _currentPreferences;
  
  /// Current app settings
  AppSettings? _currentAppSettings;
  
  /// Get current user preferences
  UserPreferences? get currentPreferences => _currentPreferences;
  
  /// Get current app settings
  AppSettings? get currentAppSettings => _currentAppSettings;
  
  /// Create settings cubit
  SettingsCubit({
    required this.managePreferencesUseCase,
  }) : super(SettingsInitial());
  
  /// Load settings
  Future<void> loadSettings({
    required UserPreferences preferences,
    required AppSettings appSettings,
  }) async {
    emit(SettingsLoading());
    try {
      _currentPreferences = preferences;
      _currentAppSettings = appSettings;
      emit(SettingsLoaded(
        preferences: preferences,
        appSettings: appSettings,
      ));
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }
  
  /// Toggle theme mode
  Future<void> toggleThemeMode({
    required String userId,
    required bool useDarkTheme,
    required bool useSystemTheme,
  }) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await managePreferencesUseCase.toggleThemeMode(
        userId: userId,
        useDarkTheme: useDarkTheme,
        useSystemTheme: useSystemTheme,
      );
      
      result.fold(
        (failure) => emit(SettingsError(
          message: failure.message,
          code: failure.code,
        )),
        (updatedPreferences) {
          _currentPreferences = updatedPreferences;
          emit(ThemeUpdateSuccess(
            useDarkTheme: useDarkTheme,
            useSystemTheme: useSystemTheme,
          ));
          emit(SettingsLoaded(
            preferences: updatedPreferences,
            appSettings: _currentAppSettings!,
          ));
        },
      );
    }
  }
  
  /// Toggle biometrics
  Future<void> toggleBiometrics({
    required String userId,
    required bool useBiometrics,
  }) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await managePreferencesUseCase.toggleBiometrics(
        userId: userId,
        useBiometrics: useBiometrics,
      );
      
      result.fold(
        (failure) => emit(SettingsError(
          message: failure.message,
          code: failure.code,
        )),
        (updatedPreferences) {
          _currentPreferences = updatedPreferences;
          emit(BiometricsUpdateSuccess(
            useBiometrics: useBiometrics,
          ));
          emit(SettingsLoaded(
            preferences: updatedPreferences,
            appSettings: _currentAppSettings!,
          ));
        },
      );
    }
  }
  
  /// Toggle notifications
  Future<void> toggleNotifications({
    required String userId,
    required bool enableNotifications,
    bool? enableReminders,
    bool? enableProductUpdates,
  }) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await managePreferencesUseCase.toggleNotifications(
        userId: userId,
        enableNotifications: enableNotifications,
        enableReminders: enableReminders,
        enableProductUpdates: enableProductUpdates,
      );
      
      result.fold(
        (failure) => emit(SettingsError(
          message: failure.message,
          code: failure.code,
        )),
        (updatedPreferences) {
          _currentPreferences = updatedPreferences;
          emit(NotificationsUpdateSuccess(
            enableNotifications: enableNotifications,
          ));
          emit(SettingsLoaded(
            preferences: updatedPreferences,
            appSettings: _currentAppSettings!,
          ));
        },
      );
    }
  }
  
  /// Update app settings
  Future<void> updateAppSettings({
    required AppSettings settings,
  }) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(currentState.copyWith(isUpdating: true));
      
      final result = await managePreferencesUseCase.updateAppSettings(
        settings: settings,
      );
      
      result.fold(
        (failure) => emit(SettingsError(
          message: failure.message,
          code: failure.code,
        )),
        (updatedSettings) {
          _currentAppSettings = updatedSettings;
          emit(SettingsLoaded(
            preferences: _currentPreferences!,
            appSettings: updatedSettings,
          ));
        },
      );
    }
  }
  
  /// Update preferred scan mode
  Future<void> updatePreferredScanMode(ScanMode mode) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        preferredScanMode: mode,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Update conflict display mode
  Future<void> updateConflictDisplayMode(ConflictDisplayMode mode) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        conflictDisplayMode: mode,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Update font scale
  Future<void> updateFontScale(double scale) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        fontScale: scale,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Toggle analytics
  Future<void> toggleAnalytics(bool enable) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        enableAnalytics: enable,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Toggle crash reporting
  Future<void> toggleCrashReporting(bool enable) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        enableCrashReporting: enable,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Toggle offline mode
  Future<void> toggleOfflineMode(bool enable) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        enableOfflineMode: enable,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Update max ingredients in detail
  Future<void> updateMaxIngredientsInDetail(int count) async {
    if (state is SettingsLoaded && _currentAppSettings != null) {
      final updatedSettings = _currentAppSettings!.copyWith(
        maxIngredientsInDetail: count,
      );
      await updateAppSettings(settings: updatedSettings);
    }
  }
  
  /// Export user data
  Future<void> exportUserData(String userId) async {
    emit(SettingsExporting());
    
    final result = await managePreferencesUseCase.exportUserData(
      userId: userId,
    );
    
    result.fold(
      (failure) => emit(SettingsExportError(
        message: failure.message,
      )),
      (jsonData) => emit(SettingsExportSuccess(
        jsonData: jsonData,
      )),
    );
  }
  
  /// Import user data
  Future<void> importUserData({
    required String userId,
    required String jsonData,
  }) async {
    emit(SettingsImporting());
    
    final result = await managePreferencesUseCase.importUserData(
      userId: userId,
      jsonData: jsonData,
    );
    
    result.fold(
      (failure) => emit(SettingsImportError(
        message: failure.message,
      )),
      (_) {
        emit(SettingsImportSuccess());
        // Reload settings after import
        if (_currentPreferences != null && _currentAppSettings != null) {
          emit(SettingsLoaded(
            preferences: _currentPreferences!,
            appSettings: _currentAppSettings!,
          ));
        }
      },
    );
  }
  
  /// Reset all settings
  Future<void> resetAllSettings(String userId) async {
    emit(SettingsResetting());
    
    try {
      // Reset user preferences
      final preferencesResult = await managePreferencesUseCase.resetUserPreferences(
        userId: userId,
      );
      
      // Reset app settings
      final appSettingsResult = await managePreferencesUseCase.resetAppSettings();
      
      if (preferencesResult.isRight() && appSettingsResult.isRight()) {
        final preferences = preferencesResult.getOrElse(() => const UserPreferences());
        final appSettings = appSettingsResult.getOrElse(() => AppSettings.defaults());
        
        _currentPreferences = preferences;
        _currentAppSettings = appSettings;
        
        emit(SettingsResetSuccess(
          preferences: preferences,
          appSettings: appSettings,
        ));
        
        emit(SettingsLoaded(
          preferences: preferences,
          appSettings: appSettings,
        ));
      } else {
        String errorMessage = 'Failed to reset settings';
        
        if (preferencesResult.isLeft()) {
          errorMessage = preferencesResult.fold(
            (failure) => failure.message,
            (_) => errorMessage,
          );
        } else if (appSettingsResult.isLeft()) {
          errorMessage = appSettingsResult.fold(
            (failure) => failure.message,
            (_) => errorMessage,
          );
        }
        
        emit(SettingsResetError(
          message: errorMessage,
        ));
      }
    } catch (e) {
      emit(SettingsResetError(
        message: e.toString(),
      ));
    }
  }
  
  /// Clear local data
  Future<void> clearLocalData(String userId) async {
    try {
      final result = await managePreferencesUseCase.clearLocalData(
        userId: userId,
      );
      
      result.fold(
        (failure) => emit(SettingsError(
          message: failure.message,
          code: failure.code,
        )),
        (_) {
          // Reset current state
          _currentPreferences = null;
          _currentAppSettings = null;
          emit(SettingsInitial());
        },
      );
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }
}