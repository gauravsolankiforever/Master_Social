import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/notification_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/notification/components/notification_widget.dart';

class NotificationFragment extends StatefulWidget {
  @override
  State<NotificationFragment> createState() => _NotificationFragmentState();
}

class _NotificationFragmentState extends State<NotificationFragment> {
  List<NotificationModel> notificationList = [];
  late Future<List<NotificationModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getList();
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    appStore.setNotificationCount(0);
  }

  Future<List<NotificationModel>> getList() async {
    appStore.setLoading(true);
    await notificationsList(page: mPage).then((value) {
      if (mPage == 1) notificationList.clear();
      mIsLastPage = value.length != 20;
      notificationList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return notificationList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        future = getList();
      },
      color: context.primaryColor,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: context.iconColor),
          title: Text(language!.notifications, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Observer(
          builder: (_) => Stack(
            alignment: Alignment.topCenter,
            children: [
              FutureBuilder<List<NotificationModel>>(
                future: future,
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    return NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: isError ? language!.somethingWentWrong : language!.noDataFound,
                    ).center();
                  }

                  if (snap.hasData) {
                    if (snap.data.validate().isEmpty && !appStore.isLoading) {
                      return NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: isError ? language!.somethingWentWrong : language!.noDataFound,
                      ).center();
                    } else {
                      return AnimatedListView(
                        padding: EdgeInsets.only(bottom: 50),
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        slideConfiguration: SlideConfiguration(
                          delay: 80.milliseconds,
                          verticalOffset: 300,
                        ),
                        itemCount: notificationList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            color: notificationList[index].isNew == 1 ? context.cardColor : context.scaffoldBackgroundColor,
                            child: NotificationWidget(
                              notificationModel: notificationList[index],
                              callback: () {
                                mPage = 1;
                                future = getList();
                              },
                            ),
                          );
                        },
                        onNextPage: () {
                          if (!mIsLastPage) {
                            mPage++;
                            future = getList();
                          }
                        },
                      );
                    }
                  }
                  return Offstage();
                },
              ),
              if (appStore.isLoading) Positioned(bottom: mPage != 1 ? 10 : null, child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false))
            ],
          ),
        ),
      ),
    );
  }
}
