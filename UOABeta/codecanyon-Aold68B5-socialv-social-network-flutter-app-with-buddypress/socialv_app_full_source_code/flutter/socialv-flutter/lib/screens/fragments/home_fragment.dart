import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/home/components/ad_component.dart';
import 'package:socialv/screens/home/components/initial_home_component.dart';
import 'package:socialv/screens/home/components/user_detail_bottomsheet_widget.dart';
import 'package:socialv/screens/post/components/post_component.dart';
import 'package:socialv/screens/shop/screens/initial_shop_screen.dart';
import 'package:socialv/screens/stories/component/home_story_component.dart';

import '../../utils/app_constants.dart';

class HomeFragment extends StatefulWidget {
  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ScrollController _controller = ScrollController();

  List<PostModel> postList = [];
  late Future<List<PostModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void initState() {
    future = getPostList();

    _animationController = BottomSheet.createAnimationController(this);
    _animationController.duration = const Duration(milliseconds: 500);
    _animationController.drive(CurveTween(curve: Curves.easeOutQuad));

    super.initState();

    setStatusBarColorBasedOnTheme();
    _controller.addListener(() {
      /// pagination
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;
          setState(() {});

          future = getPostList();
        }
      }

      /// appbar and bottom nav bar animation
      /*/// scroll down
      if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
        if (appStore.showAppbarAndBottomNavBar) appStore.setAppbarAndBottomNavBar(false);
      }

      /// scroll up
      if (_controller.position.userScrollDirection == ScrollDirection.forward) {
        if (!appStore.showAppbarAndBottomNavBar) appStore.setAppbarAndBottomNavBar(true);
      }*/
    });

    LiveStream().on(OnAddPost, (p0) {
      postList.clear();
      mPage = 1;
      future = getPostList();
    });
  }

  Future<List<PostModel>> getPostList() async {
    appStore.setLoading(true);
    await getPost(page: mPage, type: PostRequestType.all).then((value) {
      if (mPage == 1) postList.clear();

      mIsLastPage = value.length != PER_PAGE;
      postList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);

      setState(() {});
    });

    return postList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _controller.dispose();
    LiveStream().dispose(OnAddPost);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        setState(() {});

        future = getPostList();
        LiveStream().emit(GetUserStories);
      },
      color: context.primaryColor,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              SingleChildScrollView(
                controller: _controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Observer(
                      builder: (_) => SizedBox(
                        height: appStore.showAppbarAndBottomNavBar ? kToolbarHeight : 0.0,
                      ),
                    ),
                    if (!isError)
                      HomeStoryComponent(
                        callback: () {
                          LiveStream().emit(GetUserStories);
                        },
                      ),
                    FutureBuilder<List<PostModel>>(
                      future: future,
                      builder: (ctx, snap) {
                        if (snap.hasData) {
                          if (snap.data.validate().isEmpty && !appStore.isLoading) {
                            return Offstage();
                          } else {
                            return AnimatedListView(
                              disposeScrollController: false,
                              padding: EdgeInsets.only(left: 8, right: 8, bottom: 60),
                              itemCount: postList.length,
                              slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    PostComponent(
                                      post: postList[index],
                                      callback: () {
                                        mPage = 1;
                                        future = getPostList();
                                      },
                                    ),
                                    if ((index + 1) % 5 == 0) AdComponent(),
                                  ],
                                );
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                            );
                          }
                        }
                        return Offstage();
                      },
                    ),
                  ],
                ),
              ),
              if (!appStore.isLoading && isError)
                NoDataWidget(
                  imageWidget: NoDataLottieWidget(),
                  title: isError ? language!.somethingWentWrong : language!.noDataFound,
                ).center(),
              if (postList.isEmpty && !appStore.isLoading && !isError) InitialHomeComponent().center(),
              // Observer(
              //   builder: (_) => AnimatedContainer(
              //     height: appStore.showAppbarAndBottomNavBar ? kToolbarHeight : 0.0,
              //     duration: Duration(milliseconds: 400),
              //     child: AppBar(
              //       elevation: 0,
              //       leading: IconButton(
              //         icon: Image.asset(
              //           ic_more,
              //           width: 18,
              //           height: 18,
              //           fit: BoxFit.cover,
              //           color: context.iconColor,
              //         ),
              //         onPressed: () async {
              //           await showModalBottomSheet(
              //             context: context,
              //             isScrollControlled: true,
              //             backgroundColor: Colors.transparent,
              //             transitionAnimationController: _animationController,
              //             builder: (context) {
              //               return FractionallySizedBox(
              //                 heightFactor: 0.93,
              //                 child: Column(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: [
              //                     Container(
              //                       width: 45,
              //                       height: 5,
              //                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
              //                     ),
              //                     8.height,
              //                     Container(
              //                       decoration: BoxDecoration(
              //                         color: context.cardColor,
              //                         borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              //                       ),
              //                       child: UserDetailBottomSheetWidget(
              //                         callback: () {
              //                           mPage = 1;
              //                           future = getPostList();
              //                         },
              //                       ),
              //                     ).expand(),
              //                   ],
              //                 ),
              //               );
              //             },
              //           );
              //         },
              //       ),
              //       title: Text(language!.home, style: boldTextStyle(size: 18)),
              //       actions: [
              //         Lottie.asset(
              //           shopping_cart,
              //           alignment: Alignment.center,
              //           fit: BoxFit.cover,
              //         ).onTap(() {
              //           InitialShopScreen().launch(context);
              //         }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
              //       ],
              //     ),
              //   ),
              // ),
              Positioned(
               // bottom: mPage != 1 ? 8 : null,
                child: Observer(builder: (_) => LoadingWidget(isBlurBackground: mPage == 1 ? true : false).center().visible(appStore.isLoading)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
