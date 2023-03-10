import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/language/app_localizations.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/group_response.dart';
import 'package:socialv/models/member_response.dart';
import 'package:socialv/utils/colors.dart';
import 'package:socialv/utils/constants.dart';

import '../lib_msater_stufy/data/utils.dart';
import '../network/rest_apis.dart';

part 'app_store.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  String nonce = '';

  @observable
  bool showAppbarAndBottomNavBar = true;

  @observable
  bool showShopBottom = true;

  @observable
  bool isLoggedIn = false;

  @observable
  bool doRemember = false;

  @observable
  bool showGif = false;

  @observable
  bool isDarkMode = false;

  @observable
  String selectedLanguage = "";

  @observable
  bool isLoading = false;

  @observable
  String token = '';

  @observable
  String loginEmail = '';

  @observable
  String loginFullName = '';

  @observable
  String loginName = '';

  @observable
  String password = '';

  @observable
  String loginUserId = '';

  @observable
  String loginAvatarUrl = '';

  @observable
  List<MemberResponse> recentMemberSearchList = [];

  @observable
  List<GroupResponse> recentGroupsSearchList = [];

  @observable
  int notificationCount = 0;

  @action
  Future<void> setNonce(String val, {bool isInitializing = false}) async {
    nonce = val;
    if (!isInitializing) await setValue(SharePreferencesKey.NONCE, '$val');
  }

  @action
  void setNotificationCount(int value) {
    notificationCount = value;
  }

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(SharePreferencesKey.IS_LOGGED_IN, val);
  }

  @action
  void setAppbarAndBottomNavBar(bool val) {
    showAppbarAndBottomNavBar = val;
  }

  @action
  void setShopBottom(bool val) {
    showShopBottom = val;
  }

  @action
  Future<void> setToken(String val, {bool isInitializing = false}) async {
    token = val;
    if (!isInitializing) await setValue(SharePreferencesKey.TOKEN, '$val');
  }

  @action
  Future<void> setLoginEmail(String val, {bool isInitializing = false}) async {
    loginEmail = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_EMAIL, val);
  }

  @action
  Future<void> setLoginFullName(String val, {bool isInitializing = false}) async {
    loginFullName = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_FULL_NAME, val);
  }

  @action
  Future<void> setLoginName(String val, {bool isInitializing = false}) async {
    loginName = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_DISPLAY_NAME, val);
  }

  @action
  Future<void> setPassword(String val, {bool isInitializing = false}) async {
    password = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_PASSWORD, val);
  }

  @action
  Future<void> setLoginUserId(String val, {bool isInitializing = false}) async {
    loginUserId = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_USER_ID, val);
  }

  @action
  Future<void> setLoginAvatarUrl(String val, {bool isInitializing = false}) async {
    loginAvatarUrl = val;
    if (!isInitializing) await setValue(SharePreferencesKey.LOGIN_AVATAR_URL, val);
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  Future<void> setRemember(bool val, {bool isInitializing = false}) async {
    doRemember = val;
    if (!isInitializing) await setValue(SharePreferencesKey.REMEMBER_ME, val);
  }

  @action
  Future<void> toggleDarkMode({bool? value, bool isFromMain = false}) async {
    isDarkMode = value ?? !isDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = bodyDark;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = bodyWhite;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = appColorPrimary;
      shadowColorGlobal = Colors.black12;
    }

    if (!isFromMain) setStatusBarColor(isDarkMode ? appBackgroundColorDark : appLayoutBackground, delayInMilliSeconds: 300);
  }
  @action
  void setShowGif(bool val) {
    showGif = val;
  }
  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    selectedLanguageDataModel = getSelectedLanguageModel(defaultLanguage: Constants.defaultLanguage);
    selectedLanguage = getSelectedLanguageModel(defaultLanguage: Constants.defaultLanguage)!.languageCode!;
    language = await AppLocalizations().load(Locale(selectedLanguage));

    print("LLLLLLLLLLLLLLLLLLLLL"+language!.category);
  }
}
