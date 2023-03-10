import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/blocked_accounts_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/blockReport/components/unblock_member_dialog.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

class BlockedAccounts extends StatefulWidget {
  const BlockedAccounts({Key? key}) : super(key: key);

  @override
  State<BlockedAccounts> createState() => _BlockedAccountsState();
}

class _BlockedAccountsState extends State<BlockedAccounts> {
  List<BlockedAccountsModel> membersList = [];
  late Future<List<BlockedAccountsModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    future = blockedList();

    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  Future<List<BlockedAccountsModel>> blockedList() async {
    appStore.setLoading(true);

    await getBlockedAccounts().then((value) {
      membersList.clear();

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
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        future = blockedList();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: context.iconColor),
          title: Text(language!.blockedAccounts, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Observer(
          builder: (_) => Stack(
            alignment: Alignment.topCenter,
            children: [
              FutureBuilder<List<BlockedAccountsModel>>(
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
                        slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                        physics: AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                        itemCount: membersList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
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
                                MemberProfileScreen(memberId: membersList[index].userId.validate().toInt()).launch(context).then((value) {
                                  if(value ?? false) {
                                    mPage = 1;
                                    future = blockedList();
                                  }
                                });
                              }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8),
                              Observer(
                                builder: (_) => TextButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(defaultAppButtonRadius),
                                        side: BorderSide(color: context.primaryColor),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (!appStore.isLoading) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return UnblockMemberDialog(
                                            name: membersList[index].userName.validate(),
                                            mentionName: membersList[index].userMentionName.validate(),
                                            id: membersList[index].userId.validate().toInt(),
                                            callback: () {
                                              future = blockedList();
                                            },
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Text(language!.unblock, style: primaryTextStyle(size: 14, color: context.primaryColor)),
                                ),
                              )
                            ],
                          );
                        },
                        onNextPage: () {
                          if (!mIsLastPage) {
                            mPage++;
                            future = blockedList();
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
                      child: LoadingWidget(),
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
