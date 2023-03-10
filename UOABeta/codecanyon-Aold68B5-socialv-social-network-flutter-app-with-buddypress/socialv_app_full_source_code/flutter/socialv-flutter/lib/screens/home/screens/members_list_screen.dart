import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/member_response.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/app_constants.dart';
import 'package:socialv/utils/cached_network_image.dart';

class MembersListScreen extends StatefulWidget {
  const MembersListScreen({Key? key}) : super(key: key);

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  List<MemberResponse> memberList = [];
  ScrollController _controller = ScrollController();
  Future<List<MemberResponse>>? future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    future = getMembersList();
  }

  Future<List<MemberResponse>> getMembersList() async {
    appStore.setLoading(true);

    await getAllMembers(type: MemberType.alphabetical, page: mPage).then((value) {
      mIsLastPage = value.length != 20;
      if (mPage == 1) memberList.clear();
      memberList.addAll(value);
      setState(() {});
      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString());
    });
    return memberList;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(false);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        title: Text(language!.members, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          FutureBuilder<List<MemberResponse>>(
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
                    controller: _controller,
                    disposeScrollController: false,
                    physics: AlwaysScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(delay: 120.milliseconds),
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                    itemCount: memberList.length,
                    itemBuilder: (context, index) {
                      MemberResponse member = memberList[index];
                      return GestureDetector(
                        onTap: () {
                          MemberProfileScreen(memberId: member.id.validate()).launch(context);
                        },
                        child: Row(
                          children: [
                            cachedImage(
                              member.avatarUrls!.full.validate(),
                              height: 56,
                              width: 56,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(100),
                            20.width,
                            Column(
                              children: [
                                Text(member.name.validate(), style: boldTextStyle()),
                                6.height,
                                Text(
                                  member.mentionName.validate(),
                                  style: secondaryTextStyle(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ).expand(),
                          ],
                        ).paddingSymmetric(vertical: 8),
                      );
                    },
                    onNextPage: () {
                      if (!mIsLastPage) {
                        mPage++;
                        setState(() {});
                        future = getMembersList();
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
            child: Observer(builder: (_) => LoadingWidget(isBlurBackground: mPage == 1? true : false).visible(appStore.isLoading)),
          ),
        ],
      ),
    );
  }
}
