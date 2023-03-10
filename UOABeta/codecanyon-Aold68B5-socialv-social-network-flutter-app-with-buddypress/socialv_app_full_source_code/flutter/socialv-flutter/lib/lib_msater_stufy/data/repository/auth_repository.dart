
import 'package:dio/dio.dart';
import 'package:inject/inject.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/lib_msater_stufy/data/cache/cache_manager.dart';
import 'package:socialv/lib_msater_stufy/data/models/auth.dart';
import 'package:socialv/lib_msater_stufy/data/network/api_provider.dart';

import '../../../main2.dart';
import '../../../models/login_response.dart';
import '../../../network/network_utils.dart';
import '../../../network/rest_apis.dart';
import '../../../utils/constants.dart';
import '../utils.dart';

abstract class AuthRepository {
  Future authUser(String login, String password, bool isSocialLogin);

  Future register(String login, String email, String password);

  Future restorePassword(String email);

  Future<Response> changePassword(String oldPassword, String newPassword);

  Future demoAuth();

  Future<String> getToken();

  Future<bool> isSigned();

  Future logout();
}

@provide
@singleton
class AuthRepositoryImpl extends AuthRepository {
  final UserApiProvider provider;
  static const tokenKey = "apiToken";

  AuthRepositoryImpl(this.provider);

  Future authUser(String login, String password, bool isSocialLogin) async {
    print("IsSocial Login >>>>>>>>>>>>>>>>>>>>>>>>>>>>..."+isSocialLogin.toString());

    if(!isSocialLogin)
      {
        AuthResponse response = await provider.authUser(login, password);
        _saveToken(response.token);

        print("Response Login >>>>>>>>>>>>>>>>>> 1");
        print(response);

        //~~~~~~~~~~~~~~~~~~~~~~~~~Social App Session~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        Map request = {
          Users.username: login.trim().validate(),
          Users.password: password.trim().validate(),
        };

        await loginUser(request).then((value) async {
          Map req = {"player_id": getStringAsync(SharePreferencesKey.ONE_SIGNAL_PLAYER_ID), "add": 1};
          print("Response Login >>>>>>>>>>>>>>>>>> 2"+value.toString());
          appStore.setToken(value.token!);
          appStore.setLoggedIn(true);
          _saveToken(value.token!);
          await setPlayerId(req).then((value) {
            //
          }).catchError((e) {
            log("Player id error : ${e.toString()}");
          });
          appStore.setPassword(password.validate());
          getMemberById();
        });
      }
     else
       {
         appStore.setLoading(true);
         Map request = {
           Users.username: login.trim().validate(),
           Users.password: password.trim().validate(),
         };

         await loginUser2(request: request, isSocialLogin: isSocialLogin).then((value) async {
           Map req = {"player_id": getStringAsync(SharePreferencesKey.ONE_SIGNAL_PLAYER_ID), "add": 1};
           appStore.setToken(value.token!);
           appStore.setLoggedIn(true);

           await setPlayerId(req).then((value) {
             //
           }).catchError((e) {
             log("Player id error : ${e.toString()}");
           });
           appStore.setPassword(password.validate());
           getMemberById();
         }).catchError((e) {
           appStore.setLoading(false);
           toast(e.toString(), print: true);
         });

       }








  }

  Future<LoginResponse> loginUser(Map request) async {
    print("LoginResponse >>>>>>>>>>>>>>> ");
    LoginResponse response = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.login, request: request, method: HttpMethod.POST, isAuth: true)));

    appStore.setToken(response.token.validate());
    appStore.setLoggedIn(true);

    appStore.setLoginName(response.userNicename.validate());
    appStore.setLoginFullName(response.userDisplayName.validate());
    appStore.setLoginEmail(response.userEmail.validate());
    return response;
  }

  Future<LoginResponse> loginUser2({required Map request, required bool isSocialLogin}) async {
    LoginResponse response;
    if (isSocialLogin.validate()) {
      response = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.socialLogin, request: request, method: HttpMethod.POST, isAuth: true)));
    } else {
      response = LoginResponse.fromJson(await handleResponse(await buildHttpResponse(APIEndPoint.login, request: request, method: HttpMethod.POST, isAuth: true)));
    }

    appStore.setToken(response.token.validate());
    appStore.setLoggedIn(true);

    appStore.setLoginName(response.userNicename.validate());
    appStore.setLoginFullName(response.userDisplayName.validate());
    appStore.setLoginEmail(response.userEmail.validate());
    return response;
  }

  Future<void> getMemberById() async {
    await getLoginMember().then((value) {
      print("Response Login >>>>>>>>>>>>>>>>>> 3"+value.toString());
      appStore.setLoginUserId(value.id.toString());
      appStore.setLoginAvatarUrl(value.avatarUrls!.full.validate());
      appStore.setLoading(false);


    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }




  Future register(String login, String email, String password) async {
    print("Rgister >>>>>>>>>>>>>>> ");
    AuthResponse response = await provider.signUpUser(login, email, password);
    _saveToken(response.token);
    //~~~~~~~~~~~~~~~~~~~~~~~~~Social App Session~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Map request = {
      "user_login": login,
      "user_name": login,
      "user_email": email,
      "password": password,
    };

    await createUser(request).then((value) async {
      print("Rgister >>>>>>>>>>>>>>> 2");
      Map request = {
        Users.username: email,
        Users.password: password,
      };

      toast(value.message!.first);

      await loginUser(request).then((value) async {
        print("Rgister >>>>>>>>>>>>>>> 3");
        Map req = {"player_id": getStringAsync(SharePreferencesKey.ONE_SIGNAL_PLAYER_ID), "add": 1};

        await setPlayerId(req).then((value) {
          //
        }).catchError((e) {
          log("Player id error : ${e.toString()}");
        });

        appStore.setLoading(false);
        appStore.setPassword(password);
        appStore.setToken(value.token!);
        appStore.setLoggedIn(true);
        getMemberById();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    });
   // LoginResponse response2 = LoginResponse.fromJson(response);

    // appStore.setLoginName(response2.userNicename!);
    // appStore.setLoginFullName(response2.userDisplayName!);
    // appStore.setLoginEmail(response2.userEmail!);
  }

  Future<String> getToken() {
    return Future.value(preferences!.getString(tokenKey));
  }

  void _saveToken(String token) {
    preferences!.setString(tokenKey, token);
    dio.options.headers.addAll({"token": "$token"});
  }

  Future<bool> isSigned() {
    String? token = preferences!.getString(tokenKey);
    dio.options.headers.addAll({"token": "$token"});
    if(token == null) {
      return Future.value(false);
    }
    if (token.isNotEmpty) return Future.value(true);
    return Future.value(false);
  }

  Future logout() async {
    preferences!.setString("apiToken", "");
    await CacheManager().cleanCache();
  }

  Future demoAuth() async {
    var token = await provider.demoAuth();
    dio.options.headers.addAll({"token": "$token"});
    _saveToken(token);
  }

  Future restorePassword(String email) async {
    await provider.restorePassword(email);
  }

  Future<Response> changePassword(String oldPassword, String newPassword) async {
    return await provider.changePassword(oldPassword,newPassword);
  }
}
