import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/invite_user_list_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/screens/create_group_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class InviteUserComponent extends StatefulWidget {
  final int? groupId;

  InviteUserComponent({this.groupId});

  @override
  State<InviteUserComponent> createState() => _InviteUserComponentState();
}

class _InviteUserComponentState extends State<InviteUserComponent> {
  List<InviteUserListModel> invites = [];
  late Future<List<InviteUserListModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getInvites();
    super.initState();
  }

  Future<List<InviteUserListModel>> getInvites() async {
    appStore.setLoading(true);

    await getGroupInviteList(page: mPage, groupId: widget.groupId ?? groupId).then((value) {
      if (mPage == 1) invites.clear();

      mIsLastPage = value.length != PER_PAGE;
      invites.addAll(value);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return invites;
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
        setState(() {});

        future = getInvites();
      },
      color: context.primaryColor,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<InviteUserListModel>>(
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
                    physics: AlwaysScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(
                      delay: 80.milliseconds,
                      verticalOffset: 300,
                    ),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    itemCount: invites.length,
                    itemBuilder: (context, index) {
                      InviteUserListModel member = invites[index];
                      return Row(
                        children: [
                          cachedImage(
                            member.userImage.validate(),
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ).cornerRadiusWithClipRRect(100),
                          8.width,
                          Text(member.userName.validate(), style: primaryTextStyle()).expand(),
                          member.isInvited.validate()
                              ? TextButton(
                                  onPressed: () async {
                                    if (!appStore.isLoading)
                                      ifNotTester(() async {
                                        mPage = 1;

                                        appStore.setLoading(true);

                                        await invite(groupId: widget.groupId ?? groupId, userId: member.userId.validate(), isInviting: 0)
                                            .then((value) async {
                                          mPage = 1;
                                          setState(() {});

                                          future = getInvites();
                                        }).catchError((e) {
                                          appStore.setLoading(false);

                                          toast(e.toString());
                                        });
                                      });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, color: context.primaryColor, size: 18),
                                      4.width,
                                      Text(language!.invited, style: primaryTextStyle(size: 14, color: context.primaryColor)),
                                    ],
                                  ),
                                )
                              : TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(defaultRadius),
                                        side: BorderSide(color: context.primaryColor),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (!appStore.isLoading)
                                      ifNotTester(() async {
                                        mPage = 1;
                                        appStore.setLoading(true);

                                        await invite(groupId: widget.groupId ?? groupId, userId: member.userId.validate(), isInviting: 1)
                                            .then((value) async {
                                          mPage = 1;
                                          setState(() {});

                                          future = getInvites();
                                        }).catchError((e) {
                                          appStore.setLoading(false);
                                          toast(e.toString(), print: true);
                                        });
                                      });
                                  },
                                  child: Text(language!.invite, style: primaryTextStyle(size: 14, color: context.primaryColor)),
                                )
                        ],
                      ).onTap(() async {
                        MemberProfileScreen(memberId: member.userId.validate()).launch(context);
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8);
                    },
                    onNextPage: () {
                      if (!mIsLastPage) {
                        mPage++;
                        setState(() {});
                        future = getInvites();
                      }
                    },
                  );
                }
              }
              return Offstage();
            },
          ),
          Positioned(
            bottom: mPage != 1 ? 8 : null,
            child: Observer(builder: (_) => LoadingWidget(isBlurBackground: mPage == 1 ? true : false).visible(appStore.isLoading)),
          ),
        ],
      ),
    );
  }
}
