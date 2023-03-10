import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/media_model.dart';
import 'package:socialv/models/post_in_list_model.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/post/components/show_selected_media_component.dart';

import '../../../utils/app_constants.dart';

class AddPostScreen extends StatefulWidget {
  final String? component;
  final int? groupId;

  AddPostScreen({this.component, this.groupId});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  List<File> mediaList = [];

  int selectedIndex = -1;

  List<MediaModel> mediaTypeList = [];
  List<PostInListModel> postInList = [];

  MediaModel selectedType = MediaModel();

  TextEditingController postContentTextEditController = TextEditingController();

  PostInListModel dropdownValue = PostInListModel();

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      setStatusBarColor(context.cardColor);
      getMediaList();
      postIn();
    });
  }

  Future<void> getMediaList() async {
    appStore.setLoading(true);
    await getMediaTypes(type: widget.component.validate()).then((value) {
      mediaTypeList.addAll(value);
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
    setState(() {});
  }

  Future<void> postIn() async {
    appStore.setLoading(true);
    await getPostInList().then((value) {
      postInList.addAll(value);

      if (widget.groupId != null) {
        value.forEach((element) {
          if (element.id == widget.groupId) {
            dropdownValue = element;
          }
        });
      } else {
        dropdownValue = value.first;
      }
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    setStatusBarColorBasedOnTheme();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: context.iconColor),
        backgroundColor: context.cardColor,
        title: Text(language!.newPost, style: boldTextStyle(size: 20)),
        elevation: 0,
        centerTitle: true,
        actions: [
          AppButton(
            enabled: true,
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(4)),
            text: language!.post,
            textStyle: primaryTextStyle(color: Colors.white, size: 12),
            onTap: () async {
              hideKeyboard(context);
              ifNotTester(() async {
                if (!appStore.isLoading) {
                  if (mediaTypeList.isEmpty || postContentTextEditController.text.trim().isEmpty) {
                    toast(language!.addPostContent);
                  } else {
                    appStore.setLoading(true);
                    await uploadPost(
                      files: mediaList,
                      content: postContentTextEditController.text,
                      mediaType: selectedIndex != -1 ? mediaTypeList[selectedIndex].type : null,
                      isMedia: selectedIndex == -1 ? false : true,
                      postIn: dropdownValue.id.validate().toString(),
                    ).then((value) async {
                      appStore.setLoading(false);
                      LiveStream().emit(OnAddPost);
                      LiveStream().emit(OnAddPostProfile);
                      finish(context, true);
                    }).catchError((e) {
                      toast(language!.somethingWentWrong, print: true);
                      appStore.setLoading(false);
                    });
                  }
                }
              });
            },
            color: context.primaryColor,
            width: 60,
            padding: EdgeInsets.all(0),
            elevation: 0,
          ).paddingSymmetric(horizontal: 16, vertical: 12),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.width(),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(borderRadius: radius(), color: context.scaffoldBackgroundColor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mediaTypeList.map((e) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: selectedIndex == mediaTypeList.indexOf(e) ? context.primaryColor : Colors.transparent,
                          borderRadius: selectedIndex == mediaTypeList.indexOf(e) && selectedIndex == 0
                              ? BorderRadius.only(topLeft: Radius.circular(defaultRadius), bottomLeft: Radius.circular(defaultRadius))
                              : selectedIndex == mediaTypeList.indexOf(e) && selectedIndex == mediaTypeList.length - 1
                                  ? BorderRadius.only(topRight: Radius.circular(defaultRadius), bottomRight: Radius.circular(defaultRadius))
                                  : BorderRadius.circular(0),
                        ),
                        child: Text(
                          e.title.validate(),
                          style: boldTextStyle(size: 12, color: selectedIndex == mediaTypeList.indexOf(e) ? white : Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                      ).onTap(() {
                        if (!appStore.isLoading) {
                          mediaList.clear();
                          selectedIndex = mediaTypeList.indexOf(e);
                          setState(() {});
                        }
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).expand();
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(defaultRadius)),
                  child: TextField(
                    enabled: !appStore.isLoading,
                    controller: postContentTextEditController,
                    autofocus: false,
                    maxLines: 10,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: language!.whatsOnYourMind,
                      hintStyle: secondaryTextStyle(size: 12),
                    ),
                  ),
                ),
                if (selectedIndex != -1)
                  Stack(
                    children: [
                      DottedBorderWidget(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        radius: defaultAppButtonRadius,
                        dotsWidth: 8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppButton(
                              elevation: 0,
                              color: appColorPrimary,
                              text: language!.selectFiles,
                              textStyle: boldTextStyle(color: Colors.white),
                              onTap: () async {
                                if (!appStore.isLoading) {
                                  appStore.setLoading(true);
                                  mediaList.addAll(
                                    await getMultipleFiles(mediaType: mediaTypeList[selectedIndex]).whenComplete(() => appStore.setLoading(false)),
                                  );
                                  setState(() {});
                                }
                              },
                            ),
                            16.height,
                            Text(
                              '${language!.addPost} ${mediaTypeList[selectedIndex].title.capitalizeFirstLetter()}',
                              style: secondaryTextStyle(size: 16),
                            ).center(),
                            8.height,
                            Text(
                              '${language!.pleaseSelectOnly} ${mediaTypeList[selectedIndex].type} ${language!.files} ',
                              style: secondaryTextStyle(),
                            ).center(),
                          ],
                        ),
                      ),
                      Positioned(
                        child: Icon(Icons.cancel_outlined, color: appColorPrimary, size: 18).onTap(() {
                          if (!appStore.isLoading) {
                            mediaList.clear();
                            selectedIndex = -1;
                            setState(() {});
                          }
                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                        right: 6,
                        top: 6,
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 16, vertical: 16),
                if (mediaList.isNotEmpty) ShowSelectedMediaComponent(mediaList: mediaList, mediaType: mediaTypeList[selectedIndex]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(language!.postIn, style: boldTextStyle()).paddingSymmetric(horizontal: 16),
                    if (dropdownValue.id != null)
                      Container(
                        height: 40,
                        decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: radius(8)),
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<PostInListModel>(
                              borderRadius: BorderRadius.circular(8),
                              value: dropdownValue,
                              icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? bodyDark : bodyWhite),
                              elevation: 8,
                              style: primaryTextStyle(),
                              underline: Container(height: 2, color: appColorPrimary),
                              alignment: Alignment.bottomCenter,
                              onChanged: (PostInListModel? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                              items: postInList.map<DropdownMenuItem<PostInListModel>>((e) {
                                return DropdownMenuItem<PostInListModel>(
                                  value: e,
                                  child: Text('${e.title.validate()}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                50.height,
              ],
            ),
          ),
          Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
