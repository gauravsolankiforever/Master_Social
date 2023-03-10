import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inject/inject.dart';

import 'package:socialv/lib_msater_stufy/theme/theme.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/assignment/assignment_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/category_detail/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/category_detail/category_detail_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/course/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/course/course_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/courses/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/courses/user_courses_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/detail_profile/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/detail_profile/detail_profile_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/edit_profile_bloc/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/edit_profile_bloc/edit_profile_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/favorites/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/favorites/favorites_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/final/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/final/final_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/home/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/home/home_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/home_simple/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/home_simple/home_simple_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/lesson_stream/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/lesson_stream/lesson_stream_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/lesson_video/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/lesson_video/lesson_video_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/lesson_zoom/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/lesson_zoom/zoom_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/orders/orders_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/plans/plans_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/profile/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/profile/profile_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/profile_assignment/profile_assignment_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/question_ask/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/question_ask/question_ask_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/question_details/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/question_details/question_details_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/questions/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/questions/questions_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/quiz_lesson/quiz_lesson_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/quiz_screen/quiz_screen_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/restore_password/restore_password_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/change_password/change_password_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/review_write/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/review_write/review_write_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/search/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/search/search_screen_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/search_detail/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/text_lesson/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/text_lesson/text_lesson_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/user_course/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/user_course/user_course_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/user_course_locked/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/user_course_locked/user_course_locked_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/video/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/video/video_bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/assignment/assignment_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/auth/auth_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/category_detail/category_detail_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/course/course_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/detail_profile/detail_profile_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/final/final_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/lesson_stream/lesson_stream_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/lesson_video/lesson_video_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/main_screens.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/plans/plans_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/profile_assignment/profile_assignment_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/profile_edit/profile_edit_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/question_ask/question_ask_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/question_details/question_details_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/questions/questions_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/quiz_lesson/quiz_lesson_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/quiz_screen/quiz_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/restore_password/restore_password_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/change_password/change_password_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/review_write/review_write_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/search_detail/search_detail_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/splash/splash_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/text_lesson/text_lesson_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/user_course/user_course.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/user_course_locked/user_course_locked_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/video_screen/video_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/web_checkout/web_checkout_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/zoom/zoom.dart';
import 'package:socialv/lib_msater_stufy/ui/widgets/message_notification.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/search_detail/search_detail_bloc.dart';
import '../main2.dart';
import 'data/push/push_manager.dart';
import 'data/repository/localization_repository.dart';
import 'data/utils.dart';
import 'di/app_injector.dart';
import 'ui/screens/orders/orders.dart';
import 'ui/screens/user_course/user_course.dart';
masterStudyAppIntialize() async
{
  // System style AppBar



  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.grey.withOpacity(0.4), //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons
  ));
  WidgetsFlutterBinding.ensureInitialized();


  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
      AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  //SharedPreferences
  preferences = await SharedPreferences.getInstance();

  //Firebase
  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PushNotificationsManager().init();

  //Localizations
  localizations = LocalizationRepositoryImpl(await getDefaultLocalization());



  localizations!=null? print("localizations>>>>>>>>>>>>>>>>>>>>>>>>>> "):print("localizations >>>>> null");

  appDocDir = await getApplicationDocumentsDirectory();
  appView = preferences!.getBool("app_view") ?? false;

  if (Platform.isAndroid) androidInfo = await deviceInfo.androidInfo;
  if (Platform.isIOS) iosDeviceInfo = await deviceInfo.iosInfo;



}