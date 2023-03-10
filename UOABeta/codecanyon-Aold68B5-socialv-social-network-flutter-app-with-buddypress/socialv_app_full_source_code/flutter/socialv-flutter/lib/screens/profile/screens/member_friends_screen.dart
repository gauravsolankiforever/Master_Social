import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/friend_list_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

class MemberFriendsScreen extends StatefulWidget {
  final int memberId;

  const MemberFriendsScreen({required this.memberId});

  @override
  State<MemberFriendsScreen> createState() => _MemberFriendsScreenState();
}

class _MemberFriendsScreenState extends State<MemberFriendsScreen> {
  List<FriendListModel> membersList = [];
  late Future<List<FriendListModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = friendsList();

    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  Future<List<FriendListModel>> friendsList() async {
    appStore.setLoading(true);

    await getFriendList(page: mPage, userId: widget.memberId).then((value) {
      if (mPage == 1) membersList.clear();

      mIsLastPage = value.length != 20;
      membersList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return membersList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        future = friendsList();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: context.iconColor),
          title: Text(language!.friends, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Observer(
          builder: (_) => Stack(
            alignment: Alignment.topCenter,
            children: [
              FutureBuilder<List<FriendListModel>>(
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
                        slideConfiguration: SlideConfiguration(
                          delay: 80.milliseconds,
                          verticalOffset: 300,
                        ),
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                        itemCount: membersList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              cachedImage(
                                membersList[index].userImage.validate(),
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRect(100),
                              20.width,
                              Column(
                                children: [
                                  Text(membersList[index].userName.validate(), style: boldTextStyle(size: 14)),
                                  Text(membersList[index].userMentionName.validate(), style: secondaryTextStyle()),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ],
                          ).onTap(() async {
                            MemberProfileScreen(memberId: membersList[index].userId.validate()).launch(context);
                          }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8);
                        },
                        onNextPage: () {
                          if (!mIsLastPage) {
                            mPage++;
                            future = friendsList();
                          }
                        },
                      );
                    }
                  }
                  return Offstage();
                },
              ),
              Observer(
                builder: (_) {
                  if (appStore.isLoading) {
                    return Positioned(
                      bottom: mPage != 1 ? 10 : null,
                      child: LoadingWidget(isBlurBackground: mPage == 1? true : false),
                    );
                  } else {
                    return Offstage();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
