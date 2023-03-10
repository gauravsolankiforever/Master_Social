import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/dashboard_api_response.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/fragments/home_fragment.dart';
import 'package:socialv/screens/fragments/notification_fragment.dart';
import 'package:socialv/screens/fragments/profile_fragment.dart';
import 'package:socialv/screens/fragments/search_fragment.dart';
import 'package:socialv/screens/post/screens/add_post_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

List<VisibilityOptions>? visibilities;
List<ReportType>? reportTypes;

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  bool hasUpdate = false;
  late ScrollController _controller = ScrollController();

  bool onAnimationEnd = true;



  @override
  void initState() {
    super.initState();

    getDetails();
    getNonce().then((value) {
      appStore.setNonce(value.storeApiNonce.validate());
    }).catchError(onError);

    setStatusBarColorBasedOnTheme();
    _controller.addListener(() {
      //
    });
  }
  List<Widget> appFragments = [
    HomeFragment(),
    SearchFragment(),
    SizedBox(),
    NotificationFragment(),
    ProfileFragment(),
  ];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> getDetails() async {
    await getDashboardDetails().then((value) {
      appStore.setNotificationCount(value.notificationCount.validate());
      visibilities = value.visibilities.validate();
      reportTypes = value.reportTypes.validate();
    }).catchError(onError);
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      onWillPop: () {
        if (selectedIndex != 0) {
          setState(() {
            selectedIndex = 0;
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: appFragments[selectedIndex],
        bottomNavigationBar: Observer(
          builder: (_) {
            return AnimatedContainer(
              color: context.cardColor,
              duration: Duration(milliseconds: 400),
              //height: appStore.showAppbarAndBottomNavBar ? 66.0 : 0.0,
              child: appStore.showAppbarAndBottomNavBar
                  ? SingleChildScrollView(
                child: BottomNavigationBar(
                  showSelectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                      icon: Image.asset(BottomNavigationImage.home, height: 24, width: 24, fit: BoxFit.cover, color: context.iconColor).paddingTop(12),
                      label: '',
                      activeIcon: Image.asset(BottomNavigationImage.home_selected, height: 24, width: 24, fit: BoxFit.cover).paddingTop(12),
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(BottomNavigationImage.search, height: 20, width: 20, fit: BoxFit.cover, color: context.iconColor).paddingTop(12),
                      label: '',
                      activeIcon: Image.asset(BottomNavigationImage.search_selected, height: 24, width: 24, fit: BoxFit.cover).paddingTop(12),
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        BottomNavigationImage.create_post,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                        color: context.iconColor,
                      ).paddingTop(12),
                      label: '',
                      activeIcon: Image.asset(BottomNavigationImage.create_post_selected, height: 24, width: 24, fit: BoxFit.cover).paddingTop(12),
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            BottomNavigationImage.notification,
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                            color: context.iconColor,
                          ).paddingTop(12),
                          if (appStore.notificationCount != 0)
                            Positioned(
                              right: appStore.notificationCount.toString().length > 1 ? -6 : -4,
                              top: 3,
                              child: Container(
                                padding: EdgeInsets.all(appStore.notificationCount.toString().length > 1 ? 4 : 6),
                                decoration: BoxDecoration(color: appColorPrimary, shape: BoxShape.circle),
                                child: Text(
                                  appStore.notificationCount.toString(),
                                  style: boldTextStyle(color: Colors.white, size: 10, weight: FontWeight.w700, letterSpacing: 0.7),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: '',
                      activeIcon: Image.asset(
                        BottomNavigationImage.notification_selected,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ).paddingTop(12),
                    ),
                    BottomNavigationBarItem(
                      icon: cachedImage(
                        appStore.loginAvatarUrl,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                      ).cornerRadiusWithClipRRect(100).paddingTop(12),
                      label: '',
                      activeIcon: Container(
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: appColorPrimary, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Observer(
                          builder: (_) => cachedImage(
                            appStore.loginAvatarUrl,
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(100),
                        ),
                      ),
                    ),
                  ],
                  onTap: (val) async {
                    if (val == 2) {
                      await AddPostScreen().launch(context);
                    } else {
                      selectedIndex = val;
                    }
                    setState(() {});
                  },
                  currentIndex: selectedIndex,
                ),
              )
                  : SizedBox(width: context.width()),
            );
          },
        ),
      ),
    );
  }
}
