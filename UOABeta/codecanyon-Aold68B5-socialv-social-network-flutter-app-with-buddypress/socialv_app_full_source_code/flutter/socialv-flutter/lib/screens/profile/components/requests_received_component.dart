import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/friend_request_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class RequestsReceivedComponent extends StatefulWidget {
  RequestsReceivedComponent();

  @override
  State<RequestsReceivedComponent> createState() => _RequestsReceivedComponentState();
}

class _RequestsReceivedComponentState extends State<RequestsReceivedComponent> with AutomaticKeepAliveClientMixin {
  List<FriendRequestModel> list = [];
  late Future<List<FriendRequestModel>> future;

  ScrollController _scrollController = ScrollController();

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = requestList();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          appStore.setLoading(true);
          future = requestList();
        }
      }
    });

    afterBuildCreated(() async {
      await 1.seconds.delay;
      appStore.setLoading(true);
    });
  }

  Future<List<FriendRequestModel>> requestList() async {
    await getFriendRequestList(page: mPage).then((value) {
      if (mPage == 1) list.clear();

      mIsLastPage = value.length != PER_PAGE;
      list.addAll(value);

      appStore.setLoading(false);
      setState(() {});

    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      setState(() {});

      toast(e.toString(), print: true);
    });
    appStore.setLoading(false);
    return list;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      width: context.width(),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
      child: Stack(
        alignment: isError || list.isEmpty ? Alignment.center : Alignment.topCenter,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (list.isNotEmpty) Text('${language!.requestsReceived} ( ${list.length} )', style: boldTextStyle()).paddingAll(16),
                FutureBuilder<List<FriendRequestModel>>(
                  future: future,
                  builder: (ctx, snap) {
                    if (snap.hasError) {
                      return NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: isError ? language!.somethingWentWrong : language!.noDataFound,
                      ).center();
                    }

                    if (snap.hasData) {
                      if (snap.data.validate().isEmpty) {
                        return NoDataWidget(
                          imageWidget: NoDataLottieWidget(),
                          title: isError ? language!.somethingWentWrong : language!.noDataFound,
                        ).center();
                      } else {
                        return AnimatedListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          slideConfiguration: SlideConfiguration(
                            delay: 80.milliseconds,
                            verticalOffset: 300,
                          ),
                          padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(8)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      cachedImage(
                                        list[index].userImage.validate(),
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover,
                                      ).cornerRadiusWithClipRRect(100),
                                      20.width,
                                      Column(
                                        children: [
                                          Text(list[index].userName.validate(), style: boldTextStyle(size: 14)),
                                          Text(list[index].userMentionName.validate(), style: secondaryTextStyle()),
                                        ],
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                      ),
                                    ],
                                  ),
                                  24.height,
                                  Row(
                                    children: [
                                      AppButton(
                                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                                        text: language!.confirm,
                                        textStyle: secondaryTextStyle(color: Colors.white, size: 14),
                                        onTap: () async {
                                          if (!appStore.isLoading)
                                            ifNotTester(() async {
                                              appStore.setLoading(true);
                                              await acceptFriendRequest(id: list[index].userId.validate()).then((value) async {
                                                mPage = 1;
                                                appStore.setLoading(true);
                                                future = requestList();
                                                LiveStream().emit(OnRequestAccept);
                                              }).catchError((e) {
                                                appStore.setLoading(false);
                                                toast(e.toString(), print: true);
                                              });
                                            });
                                        },
                                        elevation: 0,
                                        color: context.primaryColor,
                                        height: 32,
                                      ).expand(),
                                      16.width,
                                      AppButton(
                                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
                                        text: language!.decline,
                                        textStyle: secondaryTextStyle(color: context.primaryColor, size: 14),
                                        onTap: () {
                                          if (!appStore.isLoading)
                                            ifNotTester(() {
                                              appStore.setLoading(true);

                                              removeExistingFriendConnection(
                                                friendId: list[index].userId.validate().toString(),
                                                passRequest: false,
                                              ).then((value) {
                                                mPage = 1;
                                                appStore.setLoading(true);
                                                future = requestList();
                                              }).catchError((e) {
                                                appStore.setLoading(false);
                                                toast(e.toString(), print: true);
                                              });
                                            });
                                        },
                                        elevation: 0,
                                        color: context.cardColor,
                                        height: 32,
                                      ).expand(),
                                    ],
                                  )
                                ],
                              ),
                            ).onTap(() async {
                              MemberProfileScreen(memberId: list[index].userId.validate()).launch(context).then((value) {
                                if (value ?? false) {
                                  mPage = 1;
                                  appStore.setLoading(true);
                                  future = requestList();
                                  LiveStream().emit(OnRequestAccept);
                                }
                              });
                            }).paddingSymmetric(vertical: 8);
                          },
                        );
                      }
                    }
                    return Offstage();
                  },
                ),
              ],
            ),
          ),
          Observer(
            builder: (_) {
              if (appStore.isLoading) {
                return Positioned(
                  bottom: mPage != 1 ? 10 : null,
                  child: LoadingWidget(isBlurBackground: false),
                );
              } else {
                return Offstage();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
