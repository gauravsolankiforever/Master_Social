import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/screens/blockReport/components/block_member_dialog.dart';
import 'package:socialv/screens/blockReport/components/show_report_dialog.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/member_detail_model.dart';
import 'package:socialv/models/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/screens/group_screen.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/profile/components/profile_header_component.dart';
import 'package:socialv/screens/profile/components/request_follow_widget.dart';
import 'package:socialv/screens/profile/screens/member_friends_screen.dart';
import 'package:socialv/screens/profile/screens/personal_info_screen.dart';

import '../../../utils/app_constants.dart';

class MemberProfileScreen extends StatefulWidget {
  final int memberId;

  MemberProfileScreen({required this.memberId});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  MemberDetailModel member = MemberDetailModel();

  bool isCallback = false;
  bool showDetails = false;

  List<PostModel> postList = [];
  late Future<List<PostModel>> future;

  ScrollController _scrollController = ScrollController();

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;
  bool hasInfo = false;
  bool isLoading = true;

  @override
  void initState() {
    future = getPostList();
    setStatusBarColor(Colors.transparent);
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage && postList.isNotEmpty) {
          appStore.setLoading(true);
          mPage++;
          future = getPostList();
        }
      }
    });

    afterBuildCreated(() {
      appStore.setLoading(true);
      getMember();
    });
  }

  Future<List<PostModel>> getPostList() async {
    if (mPage == 1) postList.clear();
    isLoading = true;

    await getPost(type: PostRequestType.timeline, page: mPage, userId: widget.memberId).then((value) {
      mIsLastPage = value.length != PER_PAGE;
      postList.addAll(value);
      isLoading = false;
      setState(() {});
    }).catchError((e) {
      isError = true;
      isLoading = false;
      setState(() {});
      toast(e.toString(), print: true);
    });

    return postList;
  }

  Future<void> getMember() async {
    await getMemberDetail(userId: widget.memberId).then((value) {
      member = value.first;
      for (var i in member.profileInfo.validate()) {
        for (var j in i.fields.validate()) {
          if (j.value.validate().isNotEmpty) {
            hasInfo = true;
            break;
          }
        }
      }

      showDetails = !(member.blockedByMe.validate() || member.blockedBy.validate());
      appStore.setLoading(false);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
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
    return WillPopScope(
      onWillPop: () {
        appStore.setLoading(false);

        finish(context, isCallback);
        return Future.value(true);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          appStore.setLoading(true);
          mPage = 1;
          future = getPostList();
          getMember();
        },
        color: appColorPrimary,
        child: Observer(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(language!.profile, style: boldTextStyle(size: 20)),
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: context.iconColor),
              actions: [
                if (!appStore.isLoading && showDetails)
                  Theme(
                    data: Theme.of(context).copyWith(useMaterial3: false),
                    child: PopupMenuButton(
                      enabled: !appStore.isLoading,
                      position: PopupMenuPosition.under,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (val) async {
                        if (val == 1) {
                          PersonalInfoScreen(profileInfo: member.profileInfo.validate(), hasUserInfo: hasInfo).launch(context);
                        } else if (val == 2) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return BlockMemberDialog(
                                mentionName: member.mentionName.validate(),
                                id: member.id.validate().toInt(),
                                callback: () {
                                  appStore.setLoading(true);
                                  getMember();
                                },
                              );
                            },
                          ).then((value) {});
                        } else {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return FractionallySizedBox(
                                heightFactor: 0.80,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 5,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                                    ),
                                    8.height,
                                    Container(
                                      decoration: BoxDecoration(
                                        color: context.cardColor,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                      ),
                                      child: ShowReportDialog(isPostReport: false, userId: widget.memberId),
                                    ).expand(),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                      },
                      icon: Icon(Icons.more_horiz),
                      itemBuilder: (context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: context.iconColor, size: 20),
                              8.width,
                              Text(language!.about, style: primaryTextStyle()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(Icons.block, color: context.iconColor, size: 20),
                              8.width,
                              Text(language!.block, style: primaryTextStyle()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Row(
                            children: [
                              Icon(Icons.report_gmailerrorred, color: context.iconColor, size: 20),
                              8.width,
                              Text(language!.report, style: primaryTextStyle()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            body: appStore.isLoading
                ? LoadingWidget().center()
                : isError
                    ? NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: isError ? language!.somethingWentWrong : language!.noDataFound,
                      ).center()
                    : SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            ProfileHeaderComponent(
                              avatarUrl: member.blockedBy.validate() ? AppImages.defaultAvatarUrl : member.memberAvatarImage.validate(),
                              cover: member.blockedBy.validate() ? null : member.memberCoverImage.validate(),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(member.blockedBy.validate() ? language!.userNotFound : member.name.validate(), style: boldTextStyle(size: 20)),
                                4.height,
                                if (!member.blockedBy.validate()) Text(member.mentionName.validate(), style: secondaryTextStyle()),
                              ],
                            ).paddingAll(16),
                            if (!appStore.isLoading && !member.blockedBy.validate())
                              RequestFollowWidget(
                                userMentionName: member.mentionName.validate(),
                                userName: member.name.validate(),
                                memberId: member.id.validate().toInt(),
                                friendshipStatus: member.friendshipStatus.validate(),
                                callback: () {
                                  isCallback = true;
                                  future = getPostList();
                                  getMember();
                                },
                                isBlockedByMe: member.blockedByMe.validate(),
                              ),
                            16.height,
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(showDetails ? member.postCount.validate().toString() : '0', style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text(language!.posts, style: secondaryTextStyle(size: 12)),
                                  ],
                                ).onTap(() {
                                  _scrollController.animateTo(context.height() * 0.35,
                                      duration: const Duration(milliseconds: 500), curve: Curves.linear);
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                Column(
                                  children: [
                                    Text(showDetails ? member.friendsCount.validate().toString() : '0', style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text(language!.friends, style: secondaryTextStyle(size: 12)),
                                  ],
                                ).onTap(() {
                                  if (member.friendsCount.validate() != 0 && showDetails) {
                                    MemberFriendsScreen(memberId: member.id.validate().toInt()).launch(context);
                                  } else {
                                    toast(language!.canNotViewFriends);
                                  }
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                                Column(
                                  children: [
                                    Text(showDetails ? member.groupsCount.validate().toString() : '0', style: boldTextStyle(size: 18)),
                                    4.height,
                                    Text(language!.groups, style: secondaryTextStyle(size: 12)),
                                  ],
                                ).onTap(() {
                                  if (member.groupsCount.validate() != 0 && showDetails) {
                                    GroupScreen(userId: member.id.validate().toInt()).launch(context);
                                  } else {
                                    toast(language!.canNotViewGroups);
                                  }
                                }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand(),
                              ],
                            ),
                            16.height,
                            if (!appStore.isLoading && showDetails)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    child: Text(
                                      '${language!.posts} (${member.postCount == null ? 0 : member.postCount})',
                                      style: boldTextStyle(color: appColorPrimary),
                                    ).paddingSymmetric(horizontal: 16),
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
                                                padding: EdgeInsets.only(left: 8, right: 8, bottom: 50),
                                                itemCount: postList.length,
                                                slideConfiguration: SlideConfiguration(
                                                  delay: 80.milliseconds,
                                                  verticalOffset: 300,
                                                ),
                                                itemBuilder: (context, index) {
                                                  return PostComponent(
                                                    post: postList[index],
                                                    callback: () {
                                                      appStore.setLoading(true);
                                                      mPage = 1;
                                                      future = getPostList();
                                                      getMember();
                                                    },
                                                  );
                                                },
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
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
                                  16.height,
                                ],
                              ),
                            16.height,
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
