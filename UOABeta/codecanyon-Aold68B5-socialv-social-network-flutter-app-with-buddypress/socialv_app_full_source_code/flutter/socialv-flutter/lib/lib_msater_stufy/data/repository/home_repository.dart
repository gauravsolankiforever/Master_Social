import 'dart:developer';


import 'package:inject/inject.dart';
import 'package:socialv/lib_msater_stufy/data/cache/localization_local.dart';
import 'package:socialv/lib_msater_stufy/data/models/AppSettings.dart';
import 'package:socialv/lib_msater_stufy/data/models/category.dart';
import 'package:socialv/lib_msater_stufy/data/network/api_provider.dart';
import 'package:socialv/lib_msater_stufy/data/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cache/app_settings_local.dart';

abstract class HomeRepository {
  Future<List<Category>> getCategories();

  Future<AppSettings> getAppSettings();

  void saveLocal(AppSettings appSettings);

  Future<List<AppSettings>> getAppSettingsLocal();

  Future<Map<String, dynamic>> getAllLocalizationLocal();

  void saveLocalizationLocal(Map<String, dynamic> localizationMap);
}

@provide
@singleton
class HomeRepositoryImpl implements HomeRepository {
  final UserApiProvider apiProvider;
  final SharedPreferences _sharedPreferences;
  final AppLocalStorage appLocalStorage;
  final LocalizationLocalStorage localizationLocalStorage;

  HomeRepositoryImpl(this.apiProvider, this._sharedPreferences, this.appLocalStorage, this.localizationLocalStorage);

  //Get categories
  @override
  Future<List<Category>> getCategories() {
    return apiProvider.getCategories();
  }

  //Get app settings
  @override
  Future<AppSettings> getAppSettings() async {
    AppSettings appSettings = await apiProvider.getAppSettings();

    var r = appSettings.options?.main_color?.r as int;



    if (appSettings.options?.main_color != null) {
      preferences!.setInt('main_color_r', r);
      preferences!.setInt('main_color_g', appSettings.options?.main_color?.g as int);
      preferences!.setInt('main_color_b', appSettings.options?.main_color?.b as int);
      preferences!.setDouble('main_color_a', appSettings.options?.main_color?.a as double);
    }

    if (appSettings.options?.secondary_color != null) {
      preferences!.setInt('second_color_r', appSettings.options?.secondary_color?.r as int);
      preferences!.setInt('second_color_g', appSettings.options?.secondary_color?.g as int);
      preferences!.setInt('second_color_b', appSettings.options?.secondary_color?.b as int);
      preferences!.setDouble('second_color_a', appSettings.options?.secondary_color?.a as double);
    }

    preferences!.setBool('app_view', appSettings.options?.app_view as bool);

    return appSettings;
  }

  //Save to local AppSettings
  void saveLocal(AppSettings appSettings) async {
    try {
      return appLocalStorage.saveLocalAppSetting(appSettings);
    } catch (e) {
      log(e.toString());
    }
  }

  //Get local AppSettings
  Future<List<AppSettings>> getAppSettingsLocal() async {
    return await appLocalStorage.getAppSettingsLocal();
  }

  //Save localization to local
  void saveLocalizationLocal(Map<String, dynamic> localizationMap) {
    try {
      return localizationLocalStorage.saveLocalizationLocal(localizationMap);
    } catch (e) {
      log(e.toString());
    }
  }

  //Get all localization from local
  Future<Map<String, dynamic>> getAllLocalizationLocal() async {
    return localizationLocalStorage.getLocalization();
  }
}
