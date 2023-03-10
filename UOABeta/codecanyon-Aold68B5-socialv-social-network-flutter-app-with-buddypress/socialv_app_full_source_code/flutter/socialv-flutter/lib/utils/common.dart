import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/common_story_model.dart';
import 'package:socialv/models/group_response.dart';
import 'package:socialv/models/media_model.dart';
import 'package:socialv/models/member_response.dart';

import 'app_constants.dart';

InputDecoration inputDecoration(
  BuildContext context, {
  String? hint,
  String? label,
  TextStyle? hintStyle,
  TextStyle? labelStyle,
  Widget? prefix,
  EdgeInsetsGeometry? contentPadding,
  Widget? prefixIcon,
}) {
  return InputDecoration(
    contentPadding: contentPadding,
    labelText: label,
    hintText: hint,
    hintStyle: hintStyle ?? secondaryTextStyle(),
    labelStyle: labelStyle ?? secondaryTextStyle(),
    prefix: prefix,
    prefixIcon: prefixIcon,
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: dividerColor)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    border: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryColor)),
    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
  );
}

InputDecoration inputDecorationFilled(BuildContext context, {String? label, EdgeInsetsGeometry? contentPadding}) {
  return InputDecoration(
    fillColor: context.cardColor,
    filled: true,
    contentPadding: contentPadding ?? EdgeInsets.all(16),
    labelText: label,
    labelStyle: secondaryTextStyle(weight: FontWeight.w600),
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    enabledBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    disabledBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    focusedBorder: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    border: OutlineInputBorder(borderRadius: radius(defaultAppButtonRadius), borderSide: BorderSide(color: context.cardColor)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
    alignLabelWithHint: true,
  );
}

Widget headerContainer({required Widget child, required BuildContext context}) {
  return Stack(
    alignment: Alignment.bottomCenter,
    children: [
      Container(
        width: context.width(),
        decoration: BoxDecoration(color: context.primaryColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        padding: EdgeInsets.all(22),
        child: child,
      ),
      Container(
        height: 20,
        decoration: BoxDecoration(color: context.cardColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
      )
    ],
  );
}

Widget appButton({
  required String text,
  required Function onTap,
  double? width,
  double? height,
  ShapeBorder? shapeBorder,
  required BuildContext context,
  Color? color,
  TextStyle? textStyle,
}) {
  return AppButton(
    shapeBorder: shapeBorder ?? RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius)),
    text: text,
    textStyle: textStyle ?? boldTextStyle(color: Colors.white),
    onTap: onTap,
    elevation: 0,
    color: color ?? context.primaryColor,
    width: width ?? context.width() - 32,
    height: height ?? 56,
  );
}

Future<File?> getImageSource({bool isCamera = true}) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
  return File(pickedImage!.path);
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

void onShareTap(BuildContext context) async {
  Share.share('Share $APP_NAME app $playStoreBaseURL${await getPackageName()}');
}

String getFormattedDate(String date) => DateFormat.yMMMMd('en_US').format(DateTime.parse(date));

List<MemberResponse> getMemberListPref() {
  if (getStringAsync(SharePreferencesKey.RECENT_SEARCH_MEMBERS).isNotEmpty) return (json.decode(getStringAsync(SharePreferencesKey.RECENT_SEARCH_MEMBERS)) as List).map((i) => MemberResponse.fromJson(i)).toList();
  return [];
}

List<GroupResponse> getGroupListPref() {
  if (getStringAsync(SharePreferencesKey.RECENT_SEARCH_GROUPS).isNotEmpty) return (json.decode(getStringAsync(SharePreferencesKey.RECENT_SEARCH_GROUPS)) as List).map((i) => GroupResponse.fromJson(i)).toList();
  return [];
}

class TabIndicator extends Decoration {
  final BoxPainter painter = TabPainter();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => painter;
}

class TabPainter extends BoxPainter {
  Paint? _paint;

  TabPainter() {
    _paint = Paint()..color = Colors.white;
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Size size = Size(configuration.size!.width, 4);
    Offset _offset = Offset(offset.dx, offset.dy + 36);
    final Rect rect = _offset & size;
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        _paint!);
  }
}

Future<List<File>> getMultipleFiles({required MediaModel mediaType}) async {
  FilePickerResult? filePickerResult;
  List<File> imgList = [];
  filePickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: mediaType.allowedType.validate());

  if (filePickerResult != null) {
    filePickerResult.files.forEach((element) {
      log('element: ${element.path.validate().split("/").last.split(".").last}');

      if (element.path.validate().split("/").last.split(".").last.isNotEmpty) {
        imgList.add(File(element.path!));
      } else {
        toast('Cannot add this file');
      }
    });
  }
  return imgList;
}

String getFileExtension(String fileName) {
  try {
    return "." + fileName.split('.').last;
  } catch (e) {
    return '';
  }
}

String convertToAgo(String dateTime) {
  if (dateTime.isNotEmpty) {
    DateTime input = DateFormat(dateTime.contains('T') ? DATE_FORMAT_2 : DATE_FORMAT_1).parse(dateTime, true);
    return input.timeAgo;
  } else {
    return '';
  }
}

String formatDate(String date) {
  DateTime input = DateFormat(DATE_FORMAT_2).parse(date, true);

  return DateFormat.yMMMMd().format(input).toString();
}

Future<void> openWebPage(BuildContext context, {required String url}) async {
  final theme = Theme.of(context);
  try {
    await launch(
      url,
      customTabsOption: CustomTabsOption(
        toolbarColor: theme.primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: CustomTabsSystemAnimation.slideIn(),
        extraCustomTabs: const <String>['org.mozilla.firefox', 'com.microsoft.emmx'],
      ),
      safariVCOption: SafariViewControllerOption(
        preferredBarTintColor: theme.primaryColor,
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

void ifNotTester(VoidCallback callback) {
  if (appStore.loginEmail == DEMO_USER_EMAIL) {
    toast(language!.demoUserText);
  } else {
    callback.call();
  }
}

Future<List<MediaSourceModel>> getMultipleImages() async {
  FilePickerResult? filePickerResult;
  List<MediaSourceModel> imgList = [];
  filePickerResult = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.media);
  String mediaType = MediaTypes.photo;

  if (filePickerResult != null) {
    filePickerResult.files.forEach((element) {
      log('element: ${element.path.validate().split("/").last.split(".").last}');

      if (allowedVideoExtensions.any((e) => e == element.path.validate().split("/").last.split(".").last)) {
        mediaType = MediaTypes.video;
      }

      if (element.path.validate().split("/").last.split(".").last.isNotEmpty) {
        imgList.add(MediaSourceModel(
          mediaFile: File(element.path!),
          mediaType: mediaType,
          extension: element.path.validate().split("/").last.split(".").last,
        ));
      } else {
        toast('Cannot add this file');
      }
    });
  }
  return imgList;
}

String timeStampToDate(int time) {
  final DateTime input = DateTime.fromMillisecondsSinceEpoch(time * 1000);

  return input.timeAgo;
}

String getPrice(String price) {
  if (price.length > 2) {
    return price.substring(0, price.length - 2);
  } else {
    return price;
  }
}

void setStatusBarColorBasedOnTheme() {
  setStatusBarColor(appStore.isDarkMode ? appBackgroundColorDark : appLayoutBackground);
}