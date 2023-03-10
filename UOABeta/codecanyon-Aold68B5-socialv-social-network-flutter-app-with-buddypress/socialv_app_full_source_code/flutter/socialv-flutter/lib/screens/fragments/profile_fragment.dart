import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/member_detail_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/screens/group_screen.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/profile/components/profile_header_component.dart';
import 'package:socialv/screens/profile/screens/profile_friends_screen.dart';
import 'package:socialv/screens/settings/screens/settings_screen.dart';

import '../../models/post_model.dart';
import '../../utils/app_constants.dart';

class ProfileFragment extends StatefulWidget {
  @override
  State<ProfileFragment> createState() => _ProfileFragmentState();
}

class _ProfileFragmentState extends State<ProfileFragment> {
  ScrollController _scrollController = ScrollController();

  MemberDetailModel _memberDetails = MemberDetailModel();
  List<PostModel> _userPostList = [];
  late Future<List<PostModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;
  bool isLoading = false;

  @override
  void initState() {
    future = getUserPostList();

    setStatusBarColor(Colors.transparent);
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          future = getUserPostList();
        }
      }
    });

    getMemberDetails();

    LiveStream().on(OnAddPostProfile, (p0) {
      getMemberDetails();
      _userPostList.clear();
      mPage = 1;
      future = getUserPostList();
    });
  }

  Future<void> getMemberDetails() async {
    appStore.setLoading(true);
    await getMemberDetail(userId: appStore.loginUserId.toInt()).then((value) async {
      _memberDetails = value.first;
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<List<PostModel>> getUserPostList() async {
    if (mPage == 1) _userPostList.clear();
    isLoading = true;
    setState(() {});
    await getPost(type: PostRequestType.timeline, page: mPage).then((value) {
      mIsLastPage = value.length != PER_PAGE;
      isLoading = false;
      _userPostList.addAll(value);
      setState(() {});
    }).catchError((e) {
      isLoading = false;
      isError = true;
      setState(() {});
      toast(e.toString(), print: true);
    });

    return _userPostList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(OnAddPostProfile);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        getMemberDetails();
        future = getUserPostList();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language!.profile, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: context.iconColor),
          actions: [
            IconButton(
              onPressed: () {
                SettingsScreen().launch(context).then((value) {
                  if (value ?? false) getMemberDetails();
                });
              },
              icon: Image.asset(
                ic_setting,
                height: 20,
                width: 20,
                fit: BoxFit.cover,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
        body: Observer(
          builder: (context) {
            return appStore.isLoading
                ? LoadingWidget().center()
                : SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProfileHeaderComponent(avatarUrl: appStore.loginAvatarUrl, cover: _memberDetails.memberCoverImage.validate()),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(appStore.loginFullName, style: boldTextStyle(size: 20)),
                                4.height,
                                Text(appStore.loginName, style: secondaryTextStyle()),
                              ],
                            ).paddingAll(16),
                            Row(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_memberDetails.postCount.validate().toString(), style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text(language!.posts, style: secondaryTextStyle(size: 12)),
                                  ],
                                ).paddingSymmetric(vertical: 8).onTap(() {
                                  _scrollController.animateTo(context.height() * 0.35,
                                      duration: const Duration(milliseconds: 500), curve: Curves.linear);
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_memberDetails.friendsCount.validate().toString(), style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text(language!.friends, style: secondaryTextStyle(size: 12)),
                                  ],
                                ).paddingSymmetric(vertical: 8).onTap(() {
                                  ProfileFriendsScreen().launch(context).then((value) {
                                    if (value) getMemberDetails();
                                  });
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_memberDetails.groupsCount.validate().toString(), style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text(language!.groups, style: secondaryTextStyle(size: 12)),
                                  ],
                                ).paddingSymmetric(vertical: 8).onTap(() {
                                  GroupScreen().launch(context).then((value) {
                                    if (value) getMemberDetails();
                                  });
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                              ],
                            ),
                          ],
                        ),
                        if (!appStore.isLoading)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                16.height,
                                Align(
                                  child: Text(language!.posts, style: boldTextStyle(color: context.primaryColor, size: 20))
                                      .paddingSymmetric(horizontal: 16),
                                  alignment: Alignment.centerLeft,
                                ),
                                FutureBuilder<List<PostModel>>(
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
                                        return Stack(
                                          children: [
                                            AnimatedListView(
                                              padding: EdgeInsets.only(left: 8, right: 8, bottom: 50, top: 8),
                                              itemCount: _userPostList.length,
                                              slideConfiguration: SlideConfiguration(
                                                delay: 80.milliseconds,
                                                verticalOffset: 300,
                                              ),
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return PostComponent(
                                                  post: _userPostList[index],
                                                  callback: () {
                                                    isLoading = true;
                                                    mPage = 1;
                                                    getMemberDetails();
                                                    future = getUserPostList();
                                                  },
                                                );
                                              },
                                            ),
                                            if (mPage != 1 && isLoading)
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                left: 0,
                                                child: ThreeBounceLoadingWidget(),
                                              )
                                          ],
                                        );
                                      }
                                    }
                                    return ThreeBounceLoadingWidget().paddingTop(16);
                                  },
                                ),
                              ],
                          ),
                        if (!appStore.isLoading && isError)
                          NoDataWidget(
                            imageWidget: NoDataLottieWidget(),
                            title: isError ? language!.somethingWentWrong : language!.noDataFound,
                          ).paddingSymmetric(vertical: 20).center(),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
