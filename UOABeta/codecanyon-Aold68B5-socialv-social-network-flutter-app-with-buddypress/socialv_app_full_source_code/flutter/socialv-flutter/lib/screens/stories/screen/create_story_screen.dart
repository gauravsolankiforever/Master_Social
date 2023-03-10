import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/file_picker_dialog_component.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/common_story_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/stories/component/set_story_duration.dart';
import 'package:socialv/screens/stories/component/story_video_component.dart';

import '../../../utils/app_constants.dart';

class CreateStoryScreen extends StatefulWidget {
  final File? cameraImage;
  final List<MediaSourceModel>? mediaList;

  const CreateStoryScreen({this.cameraImage, this.mediaList});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  List<MediaSourceModel> mediaList = [];
  List<CreateStoryModel> storyContentList = [];
  PageController pageController = PageController();

  TextEditingController storyTextController = TextEditingController();
  TextEditingController storyLinkController = TextEditingController();
  TextEditingController storyDurationController = TextEditingController();

  int selectedMediaIndex = 0;

  bool doResize = true;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(Colors.transparent);
    if (widget.cameraImage != null) {
      mediaList.add(MediaSourceModel(
        mediaFile: widget.cameraImage!,
        extension: widget.cameraImage!.path.validate().split("/").last.split(".").last,
        mediaType: MediaTypes.photo,
      ));
      storyContentList.add(CreateStoryModel(storyDuration: storyDuration));
    }

    if (widget.mediaList != null) {
      mediaList.addAll(widget.mediaList.validate());
      mediaList.forEach((element) {
        storyContentList.add(CreateStoryModel(storyDuration: storyDuration));
      });
    }
  }

  @override
  void dispose() {
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: doResize,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: mediaList.length,
            onPageChanged: (index) {
              selectedMediaIndex = index;
              if (storyContentList[index].storyText.validate().isNotEmpty) storyTextController.text = storyContentList[index].storyText.validate();
              if (storyContentList[index].storyLink.validate().isNotEmpty) storyLinkController.text = storyContentList[index].storyLink.validate();
              setState(() {});
            },
            itemBuilder: (ctx, index) {
              if (mediaList[index].mediaType == MediaTypes.video) {
                return CreateVideoStory(videoFile: mediaList[index].mediaFile);
              } else {
                return Image.file(mediaList[index].mediaFile, height: context.height(), width: context.width(), fit: BoxFit.cover);
              }
            },
          ),
          Positioned(
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    ...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10)).reversed,
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              width: context.width(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Image.asset(ic_close_square, color: Colors.white, height: 30, width: 30, fit: BoxFit.cover),
                    onPressed: () {
                      finish(context);
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Image.asset(ic_hyperlink, color: Colors.white, height: 28, width: 28, fit: BoxFit.cover),
                        onPressed: () {
                          doResize = false;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                                title: Text(language!.attachLinkHere, style: boldTextStyle()),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppTextField(
                                      autoFocus: true,
                                      controller: storyLinkController,
                                      textFieldType: TextFieldType.URL,
                                      decoration: inputDecoration(
                                        context,
                                        label: language!.link,
                                        labelStyle: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite),
                                      ),
                                    ),
                                    16.height,
                                    Row(
                                      children: [
                                        TextButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(defaultAppButtonRadius)),
                                            ),
                                            side: MaterialStateProperty.all(BorderSide(color: appColorPrimary.withOpacity(0.5))),
                                          ),
                                          onPressed: () {
                                            hideKeyboard(context);
                                            finish(context, false);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.close, color: textPrimaryColorGlobal, size: 20),
                                              6.width,
                                              Text(language!.cancel, style: boldTextStyle()),
                                            ],
                                          ).paddingSymmetric(vertical: 4).fit(),
                                        ).expand(),
                                        16.width,
                                        AppButton(
                                          elevation: 0,
                                          color: context.primaryColor,
                                          shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.link, color: Colors.white, size: 20),
                                              6.width,
                                              Text(language!.attach, style: boldTextStyle(color: Colors.white)),
                                            ],
                                          ).fit(),
                                          onTap: () {
                                            storyContentList[selectedMediaIndex].storyLink = storyLinkController.text;
                                            hideKeyboard(context);
                                            finish(context);
                                            setState(() {});
                                          },
                                        ).expand(),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ).then((value) => doResize = true);
                        },
                      ),
                      8.width,
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                                title: Text(language!.setStoryDuration, style: boldTextStyle()),
                                content: SetStoryDuration(
                                  onTap: (val) {
                                    storyContentList[selectedMediaIndex].storyDuration = val.toString();
                                    setState(() {});
                                    finish(context);
                                  },
                                  initialValue: storyContentList[selectedMediaIndex].storyDuration.toInt(),
                                ),
                              );
                            },
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                              padding: EdgeInsets.all(8),
                              child: Text(
                                '${storyContentList[selectedMediaIndex].storyDuration}s',
                                style: secondaryTextStyle(color: Colors.white, size: 12),
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(Icons.access_time_filled, color: context.primaryColor, size: 18),
                              ),
                            )
                          ],
                        ),
                        //child: Image.asset(ic_time_square, color: Colors.white, height: 24, width: 24, fit: BoxFit.cover),
                      ),
                      8.width,
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  ...List<Color>.generate(20, (index) => Colors.black.withAlpha(index * 10)),
                ],
              ),
            ),
            padding: EdgeInsets.fromLTRB(8, 60, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardBackgroundBlackDark,
                        border: Border.all(color: context.primaryColor.withOpacity(0.5)),
                        borderRadius: radius(defaultAppButtonRadius),
                      ),
                      height: 86,
                      width: 70,
                      child: Icon(Icons.add, color: Colors.white),
                      margin: EdgeInsets.only(bottom: 8),
                    ).onTap(() async {
                      FileTypes? file = await showInDialog(
                        context,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                        title: Text(language!.chooseAnAction, style: boldTextStyle()),
                        builder: (p0) {
                          return FilePickerDialog(isSelected: true);
                        },
                      );

                      if (file != null) {
                        if (file == FileTypes.CAMERA) {
                          await getImageSource(isCamera: true).then((value) {
                            mediaList.add(MediaSourceModel(
                              mediaFile: value!,
                              extension: value.path.validate().split("/").last.split(".").last,
                              mediaType: MediaTypes.photo,
                            ));
                            storyContentList.add(CreateStoryModel(storyDuration: storyDuration));

                            setState(() {});
                          }).catchError((e) {
                            appStore.setLoading(false);
                          });
                        } else {
                          await getMultipleImages().then((value) {
                            mediaList.addAll(value);
                            value.forEach((element) {
                              storyContentList.add(CreateStoryModel(storyDuration: storyDuration));
                            });
                            setState(() {});
                          });
                        }
                      }
                    }),
                    8.width,
                    Container(
                      height: 90,
                      width: 70,
                      child: Theme(
                        data: ThemeData(canvasColor: Colors.transparent),
                        child: ReorderableListView(
                          scrollDirection: Axis.horizontal,
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              if (oldIndex < newIndex) {
                                newIndex -= 1;
                              }
                              final MediaSourceModel item = mediaList.removeAt(oldIndex);
                              mediaList.insert(newIndex, item);
                            });
                          },
                          children: mediaList.map((e) {
                            int index = mediaList.indexOf(e);
                            if (mediaList[index].mediaType == MediaTypes.video) {
                              return Stack(
                                key: Key('$index'),
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      border: selectedMediaIndex == index ? Border.all(color: context.primaryColor) : Border(),
                                      borderRadius: radius(defaultAppButtonRadius),
                                    ),
                                    height: 86,
                                    width: 70,
                                    child: CreateVideoThumbnail(videoFile: mediaList[index].mediaFile),
                                  ),
                                  Container(
                                    child: Image.asset(ic_close, width: 10, height: 10, color: context.primaryColor),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ).onTap(() {
                                    mediaList.removeAt(index);
                                    setState(() {});
                                  }),
                                ],
                              );
                            } else {
                              return Stack(
                                key: Key('$index'),
                                alignment: Alignment.topRight,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          border: selectedMediaIndex == index ? Border.all(color: context.primaryColor) : Border(),
                                          borderRadius: radius(defaultAppButtonRadius),
                                        ),
                                        child: Image.file(
                                          mediaList[index].mediaFile,
                                          height: 86,
                                          width: 70,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRect(defaultAppButtonRadius),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    child: Image.asset(ic_close, width: 10, height: 10, color: context.primaryColor),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    padding: EdgeInsets.all(4),
                                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ).onTap(() {
                                    mediaList.removeAt(index);
                                    setState(() {});
                                  }),
                                ],
                              );
                            }
                          }).toList(),
                        ),
                      ),
                    ).expand(),
                  ],
                ),
                8.height,
                SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AppTextField(
                        autoFocus: false,
                        controller: storyTextController,
                        cursorColor: Colors.white,
                        textStyle: secondaryTextStyle(color: Colors.white),
                        textFieldType: TextFieldType.OTHER,
                        onChanged: (text) {
                          storyContentList[selectedMediaIndex].storyText = text;
                          setState(() {});
                        },
                        onFieldSubmitted: (text) {
                          storyContentList[selectedMediaIndex].storyText = text;
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: language!.sendMessage,
                          hintStyle: secondaryTextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(width: 1.0, color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(width: 1.0, color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(width: 1.0, color: Colors.white),
                          ),
                        ),
                      ).expand(),
                      8.width,
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(color: context.primaryColor, shape: BoxShape.circle),
                        child: Image.asset(ic_send, height: 28, width: 28, fit: BoxFit.fill, color: Colors.white),
                      ).onTap(() async {
                        ifNotTester(() async {
                          appStore.setLoading(true);

                          await uploadStory(context, contentList: storyContentList, fileList: mediaList).then((value) {
                            //
                          }).catchError((e) {
                            appStore.setLoading(false);
                            toast(e.toString());
                          });
                        });
                      }),
                    ],
                  ),
                ),
                8.height,
              ],
            ),
          ),
          Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
