import 'dart:async';

import 'package:dio/dio.dart';
import 'package:socialv/lib_msater_stufy/data/cache/cache_manager.dart';
import 'package:socialv/lib_msater_stufy/data/utils.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/splash/splash_screen.dart';

import '../../../../main2.dart';

class AppInterceptors extends Interceptor {
  Future<dynamic> onRequests(RequestOptions options) async {
    if (options.headers.containsKey("requirestoken")) {
      //remove the auxiliary header
      options.headers.remove("requirestoken");

      var header = preferences!.getString("apiToken");
      options.headers.addAll({"token": "$header"});

      return options;
    }
    return options;
  }

  @override
  Future<dynamic> onErrors(DioError err) async {
    if (err.response != null && err.response?.statusCode != null && err.response?.statusCode == 401) {
      (await CacheManager()).cleanCache();
      preferences!.setString("apiToken", "");
      navigatorKey.currentState?.pushNamed(SplashScreen.routeName);
    }
    return err;
  }

  Future<dynamic> onResponses(Response response) async {
    return response;
  }
}
