import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/components/no_data_lottie_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/comment_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/post/components/comment_component.dart';
import 'package:socialv/screens/post/screens/comment_reply_screen.dart';
import 'package:socialv/utils/cached_network_image.dart';
import 'package:socialv/utils/common.dart';
import 'package:socialv/utils/constants.dart';

class CommentScreen extends StatefulWidget {
  final int postId;

  const CommentScreen({required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentController = TextEditingController();
  FocusNode commentFocus = FocusNode();

  List<CommentModel> commentList = [];
  late Future<List<CommentModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;
  bool isChange = false;
  int commentParentId = -1;

  @override
  void initState() {
    future = getCommentsList();
    super.initState();
    afterBuildCreated(() {
      setStatusBarColor(context.cardColor);
    });
  }

  Future<List<CommentModel>> getCommentsList([bool showLoader = true]) async {
    appStore.setLoading(showLoader);

    await getComments(id: widget.postId, page: mPage).then((value) {
      if (mPage == 1) commentList.clear();

      mIsLastPage = value.length != PER_PAGE;
      commentList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return commentList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void deleteComment(int commentId) async {
    ifNotTester(() async {
      appStore.setLoading(true);
      await deletePostComment(postId: widget.postId, commentId: commentId).then((value) {
        mPage = 1;
        future = getCommentsList();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    });
  }

  void postComment(String commentContent, {int? parentId}) async {
    ifNotTester(() async {
      var comment = CommentModel(
        content: commentContent,
        userImage: appStore.loginAvatarUrl,
        dateRecorded: DateFormat(DATE_FORMAT_1).format(DateTime.now()),
        userName: appStore.loginFullName,
      );

      if (parentId == null) {
        commentList.add(comment);
      } else if (commentList.any((element) => element.id.toInt() == parentId)) {
        var temp = commentList.firstWhere((element) => element.id.toInt() == parentId);

        if (temp.children == null) temp.children = [];
        temp.children!.add(comment);
      } else {
        appStore.setLoading(true);
      }

      setState(() {});
      await savePostComment(postId: widget.postId, content: commentContent, parentId: parentId).then((value) {
        mPage = 1;
        isChange = true;
        future = getCommentsList(false);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    });
  }

  @override
  void dispose() {
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        appStore.setLoading(false);
        finish(context, isChange);
        return Future.value(true);
      },
      child: RefreshIndicator(
        onRefresh: () async {
          mPage = 1;
          future = getCommentsList();
        },
        color: context.primaryColor,
        child: Scaffold(
          backgroundColor: context.cardColor,
          appBar: AppBar(
            backgroundColor: context.cardColor,
            iconTheme: IconThemeData(color: context.iconColor),
            title: Text(language!.comments, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
          ),
          body: SizedBox(
            height: context.height(),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                FutureBuilder<List<CommentModel>>(
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
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 90),
                          itemCount: commentList.length,
                          itemBuilder: (context, index) {
                            CommentModel _comment = commentList[index];

                            return Column(
                              children: [
                                CommentComponent(
                                  callback: () {
                                    //
                                  },
                                  isParent: true,
                                  comment: _comment,
                                  postId: widget.postId,
                                  onDelete: () {
                                    showConfirmDialogCustom(
                                      context,
                                      dialogType: DialogType.DELETE,
                                      onAccept: (c) {
                                        deleteComment(_comment.id.validate().toInt());
                                      },
                                    );
                                  },
                                  onReply: () async {
                                    FocusScope.of(context).requestFocus(commentFocus);
                                    commentParentId = _comment.id.validate().toInt();
                                  },
                                ),
                                if (_comment.children.validate().isNotEmpty)
                                  ListView.separated(
                                    itemBuilder: (context, i) {
                                      return CommentComponent(
                                        callback: () {
                                          mPage = 1;
                                          isChange = true;
                                          future = getCommentsList();
                                        },
                                        isParent: false,
                                        comment: _comment.children.validate()[i],
                                        postId: widget.postId,
                                        onDelete: () {
                                          deleteComment(_comment.children.validate()[i].id.toInt());
                                        },
                                        onReply: () async {
                                          CommentReplyScreen(
                                            callback: () {
                                              mPage = 1;
                                              isChange = true;
                                              future = getCommentsList();
                                            },
                                            postId: widget.postId,
                                            comment: _comment.children.validate()[i],
                                          ).launch(context).then((value) {
                                            if (value ?? false) {
                                              mPage = 1;
                                              isChange = true;
                                              future = getCommentsList();
                                            }
                                          });
                                        },
                                      );
                                    },
                                    itemCount: _comment.children.validate().length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    padding: EdgeInsets.only(left: 16, top: 8),
                                    separatorBuilder: (c, i) => Divider(height: 0),
                                  ),
                                Divider(),
                              ],
                            );
                          },
                          onNextPage: () {
                            if (!mIsLastPage) {
                              mPage++;
                              future = getCommentsList();
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
                        child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                      );
                    } else {
                      return Offstage();
                    }
                  },
                ),
                Positioned(
                  bottom: context.navigationBarHeight,
                  child: Container(
                    width: context.width(),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: context.scaffoldBackgroundColor,
                    child: Row(
                      children: [
                        cachedImage(appStore.loginAvatarUrl, height: 36, width: 36, fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
                        10.width,
                        AppTextField(
                          focus: commentFocus,
                          controller: commentController,
                          textFieldType: TextFieldType.OTHER,
                          decoration: InputDecoration(
                            hintText: language!.writeAComment,
                            hintStyle: secondaryTextStyle(size: 16),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                          onTap: () {
                            /// Clear recently posted comment id
                            commentParentId = -1;
                          },
                        ).expand(),
                        TextButton(
                          onPressed: () async {
                            if (commentController.text.isNotEmpty) {
                              hideKeyboard(context);

                              String content = commentController.text.trim();
                              commentController.clear();

                              postComment(content, parentId: commentParentId == -1 ? null : commentParentId);
                            } else {
                              toast(language!.writeComment);
                            }
                          },
                          child: Text(language!.reply, style: primaryTextStyle(color: context.primaryColor)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
