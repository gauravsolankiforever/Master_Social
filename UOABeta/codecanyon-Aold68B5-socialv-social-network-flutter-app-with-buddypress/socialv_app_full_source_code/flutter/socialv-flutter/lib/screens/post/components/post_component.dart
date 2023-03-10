import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socialv/components/like_button_widget.dart';
import 'package:socialv/components/quick_view_post_widget.dart';
import 'package:socialv/screens/blockReport/components/show_report_dialog.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/get_post_likes_model.dart';
import 'package:socialv/models/post_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/fragments/profile_fragment.dart';
import 'package:socialv/screens/post/components/post_media_component.dart';
import 'package:socialv/screens/post/screens/comment_screen.dart';
import 'package:socialv/screens/post/screens/post_likes_screen.dart';
import 'package:socialv/screens/post/screens/single_post_screen.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/overlay_handler.dart';

import '../../../utils/app_constants.dart';

class PostComponent extends StatefulWidget {
  final PostModel post;
  final VoidCallback? callback;

  PostComponent({required this.post, this.callback});

  @override
  State<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostComponent> {
  OverlayHandler _overlayHandler = OverlayHandler();
  PageController pageController = PageController();

  List<GetPostLikesModel> postLikeList = [];
  bool isLiked = false;
  int postLikeCount = 0;
  int index = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    postLikeList = widget.post.usersWhoLiked.validate();
    postLikeCount = widget.post.likeCount.validate();
    isLiked = widget.post.isLiked.validate();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _overlayHandler.removeOverlay(context);
    pageController.dispose();
    super.dispose();
  }

  Future<void> postLike() async {
    ifNotTester(() async {
      isLiked = !isLiked;
      await likePost(postId: widget.post.activityId.validate()).then((value) {
        if (postLikeList.length < 3 && isLiked) {
          postLikeList.add(GetPostLikesModel(
            userId: appStore.loginUserId,
            userAvatar: appStore.loginAvatarUrl,
            userName: appStore.loginFullName,
          ));
        }
        if (!isLiked) {
          if (postLikeList.length <= 3) {
            postLikeList.removeWhere((element) => element.userId == appStore.loginUserId);
          }
          postLikeCount--;
        }

        if (isLiked) {
          postLikeCount++;
        }
        setState(() {});
      }).catchError((e) {
        if (postLikeList.length < 3) {
          postLikeList.removeWhere((element) => element.userId == appStore.loginUserId);
        }
        isLiked = false;
        setState(() {});
        log(e.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SinglePostScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
          if (value ?? false) widget.callback?.call();
        });
      },
      onPanEnd: (s) {
        _overlayHandler.removeOverlay(context);
      },
      onLongPress: () {
        _overlayHandler.insertOverlay(
          context,
          OverlayEntry(
            builder: (context) {
              return QuickViewPostWidget(
                postModel: widget.post,
                isPostLied: isLiked,
                onPostLike: () async {
                  postLike();
                  widget.callback!.call();
                },
                pageIndex: index,
              );
            },
          ),
        );
      },
      onLongPressEnd: (details) {
        _overlayHandler.removeOverlay(context);
      },
      child: Observer(
        builder: (_) => Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(borderRadius: radius(8), color: context.cardColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  cachedImage(
                    widget.post.userImage.validate(),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(100),
                  12.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.userName.validate(), style: boldTextStyle()),
                      4.height,
                      Text(convertToAgo(widget.post.dateRecorded.validate()), style: secondaryTextStyle()),
                    ],
                  ).expand(),
                  Theme(
                    data: Theme.of(context).copyWith(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      useMaterial3: false,
                    ),
                    child: PopupMenuButton(
                      enabled: !appStore.isLoading,
                      position: PopupMenuPosition.under,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (val) async {
                        if (val == 1) {
                          showConfirmDialogCustom(
                            context,
                            onAccept: (c) {
                              ifNotTester(() {
                                appStore.setLoading(true);

                                deletePost(postId: widget.post.activityId.validate()).then((value) {
                                  appStore.setLoading(false);
                                  toast(language!.postDeleted);
                                  widget.callback?.call();
                                  setState(() {});
                                }).catchError((e) {
                                  appStore.setLoading(false);
                                  toast(e.toString());
                                });
                              });
                            },
                            dialogType: DialogType.CONFIRMATION,
                            title: language!.deletePostConfirmation,
                            positiveText: language!.remove,
                          );
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
                                      child: ShowReportDialog(
                                        isPostReport: true,
                                        postId: widget.post.activityId.validate(),
                                        userId: widget.post.userId.validate(),
                                      ),
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
                        if (widget.post.userId.validate().toString() == appStore.loginUserId)
                          PopupMenuItem(
                            value: 1,
                            child: Text(language!.deletePost),
                            textStyle: primaryTextStyle(),
                          ),
                        if (widget.post.userId.validate().toString() != appStore.loginUserId)
                          PopupMenuItem(
                            value: 2,
                            child: Text(language!.reportPost),
                            textStyle: primaryTextStyle(),
                          ),
                      ],
                    ),
                  ),
                ],
              ).paddingOnly(left: 8, top: 8, right: 8).onTap(() {
                if (widget.post.userId.validate().toString() == appStore.loginUserId) {
                  ProfileFragment().launch(context);
                } else {
                  MemberProfileScreen(memberId: widget.post.userId.validate()).launch(context);
                }
              }, borderRadius: radius(8)),
              Divider(),
              Text(parseHtmlString(widget.post.content.validate()), style: primaryTextStyle()).paddingSymmetric(horizontal: 8),
              if (widget.post.mediaList.validate().isNotEmpty)
                PostMediaComponent(
                  mediaTitle: widget.post.userName.validate(),
                  mediaType: widget.post.mediaType.validate(),
                  mediaList: widget.post.mediaList.validate(),
                  onPageChange: (i) {
                    index = i;
                  },
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      LikeButtonWidget(
                        key: ValueKey(isLiked),
                        onPostLike: () {
                          postLike();
                        },
                        isPostLiked: isLiked,
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (!appStore.isLoading) {
                              CommentScreen(postId: widget.post.activityId.validate()).launch(context).then((value) {
                                if (value ?? false) widget.callback?.call();
                              });
                            }
                          },
                          icon: Image.asset(
                            ic_chat,
                            height: 22,
                            width: 22,
                            fit: BoxFit.cover,
                            color: context.iconColor,
                          ),
                        ),
                      ),
                      Image.asset(
                        ic_send,
                        height: 22,
                        width: 22,
                        fit: BoxFit.cover,
                        color: context.iconColor,
                      ).onTap(() {
                        if (!appStore.isLoading) {
                          String saveUrl = "$DOMAIN_URL/${widget.post.activityId.validate()}";
                          Share.share(saveUrl);
                        }
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      CommentScreen(postId: widget.post.activityId.validate()).launch(context).then(
                        (value) {
                          if (value ?? false) widget.callback?.call();
                        },
                      );
                    },
                    child: Text('${widget.post.commentCount} ${language!.comments}', style: secondaryTextStyle()),
                  ),
                ],
              ).paddingSymmetric(horizontal: 8),
              if (postLikeList.isNotEmpty)
                Row(
                  children: [
                    Stack(
                      children: postLikeList.validate().take(3).map(
                        (e) {
                          return Container(
                            width: 32,
                            height: 32,
                            margin: EdgeInsets.only(left: 18 * postLikeList.validate().indexOf(e).toDouble()),
                            child: cachedImage(
                              postLikeList.validate()[postLikeList.validate().indexOf(e)].userAvatar.validate(),
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(100),
                          );
                        },
                      ).toList(),
                    ),
                    RichText(
                      text: TextSpan(
                        text: language!.likedBy,
                        style: secondaryTextStyle(size: 12),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                postLikeList.first.userId.validate() == appStore.loginUserId ? ' you' : ' ${postLikeList.first.userName.validate()}',
                            style: boldTextStyle(size: 12),
                          ),
                          if (postLikeList.length > 1) TextSpan(text: ' And ', style: secondaryTextStyle(size: 12)),
                          if (postLikeList.length > 1) TextSpan(text: '${postLikeCount - 1} others', style: boldTextStyle(size: 12)),
                        ],
                      ),
                    ).paddingAll(8).onTap(() {
                      PostLikesScreen(postId: widget.post.activityId.validate()).launch(context);
                    }, highlightColor: Colors.transparent, splashColor: Colors.transparent)
                  ],
                ).paddingOnly(left: 8, right: 8, bottom: 8),
            ],
          ),
        ),
      ),
    );
  }
}
