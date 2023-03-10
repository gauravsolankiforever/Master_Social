import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/get_post_likes_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class PostLikesScreen extends StatefulWidget {
  final int postId;

  const PostLikesScreen({required this.postId});

  @override
  State<PostLikesScreen> createState() => _PostLikesScreenState();
}

class _PostLikesScreenState extends State<PostLikesScreen> {
  List<GetPostLikesModel> list = [];
  late Future<List<GetPostLikesModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = likesList();
    super.initState();
  }

  Future<List<GetPostLikesModel>> likesList() async {
    appStore.setLoading(true);

    await getPostLikes(id: widget.postId, page: mPage).then((value) {
      if (mPage == 1) list.clear();

      mIsLastPage = value.length != PER_PAGE;
      list.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return list;
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
        future = likesList();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: context.iconColor),
          title: Text(language!.likes, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Observer(
          builder: (_) => Stack(
            alignment: Alignment.topCenter,
            children: [
              FutureBuilder<List<GetPostLikesModel>>(
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
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              cachedImage(
                                list[index].userAvatar.validate(),
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
                          ).onTap(() async {
                            MemberProfileScreen(memberId: list[index].userId.validate().toInt()).launch(context);
                          }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8);
                        },
                        onNextPage: () {
                          if (!mIsLastPage) {
                            mPage++;
                            future = likesList();
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
