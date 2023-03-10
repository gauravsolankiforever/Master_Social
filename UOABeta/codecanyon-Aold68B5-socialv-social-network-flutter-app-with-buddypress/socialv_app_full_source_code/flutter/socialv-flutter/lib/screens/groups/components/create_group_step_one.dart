import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/groups/screens/create_group_screen.dart';

import '../../../utils/app_constants.dart';

class CreateGroupStepOne extends StatefulWidget {
  final Function(int) onNextPage;

  CreateGroupStepOne({required this.onNextPage});

  @override
  State<CreateGroupStepOne> createState() => _CreateGroupStepOneState();
}

enum GroupType { PUBLIC, PRIVATE, HIDDEN }

class _CreateGroupStepOneState extends State<CreateGroupStepOne> {
  List<List<String>> get groupTypeRule => [
    [
      'Any site member can join this group.',
      'This group will be listed in the groups directory and in search results.',
      'Group content and activity will be visible to any site member.',
    ],
    [
      'Only people who request membership and are accepted can join the group.',
      'This group will be listed in the groups directory and in search results.',
      'Group content and activity will only be visible to members of the group.',
    ],
    [
      'Only users who are invited can join the group.',
      'This group will not be listed in the groups directory or search results.',
      'Group content and activity will only be visible to members of the group.',
    ],
  ];

  GroupType? groupType = GroupType.PUBLIC;
  final createGroupFormKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  FocusNode name = FocusNode();
  FocusNode description = FocusNode();

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: radiusOnly(topRight: defaultRadius, topLeft: defaultRadius),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: createGroupFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language!.enterGroupName, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)).paddingTop(16),
                    16.height,
                    AppTextField(
                      enabled: !appStore.isLoading,
                      isValidationRequired: true,
                      controller: nameCont,
                      autoFocus: true,
                      nextFocus: description,
                      focus: name,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: language!.thisFiledIsRequired,
                      textStyle: boldTextStyle(),
                      decoration: inputDecoration(
                        context,
                        label: language!.groupName,
                        labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                      ),
                    ),
                    16.height,
                    AppTextField(
                      enabled: !appStore.isLoading,
                      isValidationRequired: false,
                      controller: descriptionCont,
                      autoFocus: true,
                      focus: description,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      textFieldType: TextFieldType.MULTILINE,
                      maxLines: 5,
                      minLines: 5,
                      textStyle: boldTextStyle(),
                      decoration: inputDecoration(
                        context,
                        label: language!.groupDescription,
                        labelStyle: secondaryTextStyle(weight: FontWeight.w600),
                      ),
                    ),
                    24.height,
                    Text(language!.privacyOptions, style: primaryTextStyle(color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio(
                          value: GroupType.PUBLIC,
                          groupValue: groupType,
                          onChanged: (GroupType? value) {
                            if (!appStore.isLoading)
                              setState(() {
                                groupType = value;
                              });
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language!.thisIsAPublic, style: boldTextStyle()).paddingTop(12),
                            6.height,
                            Column(
                              children: groupTypeRule[0].map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.circle, color: Colors.grey.shade500, size: 8).paddingTop(4),
                                    4.width,
                                    Text(e.validate(), style: secondaryTextStyle(size: 12)).expand(),
                                  ],
                                ).paddingSymmetric(vertical: 2);
                              }).toList(),
                            ),
                          ],
                        ).expand(),
                      ],
                    ).onTap(() {
                      if (!appStore.isLoading)
                        setState(() {
                          groupType = GroupType.PUBLIC;
                        });
                    }),
                    16.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio(
                          value: GroupType.PRIVATE,
                          groupValue: groupType,
                          onChanged: (GroupType? value) {
                            if (!appStore.isLoading)
                              setState(() {
                                groupType = value;
                              });
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language!.thisIsAPrivate, style: boldTextStyle()).paddingTop(12),
                            6.height,
                            Column(
                              children: groupTypeRule[1].map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.circle, color: Colors.grey.shade500, size: 8).paddingTop(4),
                                    4.width,
                                    Text(e.validate(), style: secondaryTextStyle(size: 12)).expand(),
                                  ],
                                ).paddingSymmetric(vertical: 2);
                              }).toList(),
                            ),
                          ],
                        ).expand(),
                      ],
                    ).onTap(() {
                      if (!appStore.isLoading)
                        setState(() {
                          groupType = GroupType.PRIVATE;
                        });
                    }),
                    16.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio(
                          value: GroupType.HIDDEN,
                          groupValue: groupType,
                          onChanged: (GroupType? value) {
                            if (!appStore.isLoading)
                              setState(() {
                                groupType = value;
                              });
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(language!.thisIsAHidden, style: boldTextStyle()).paddingTop(12),
                            6.height,
                            Column(
                              children: groupTypeRule[2].map((e) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.circle, color: Colors.grey.shade500, size: 8).paddingTop(4),
                                    4.width,
                                    Text(e.validate(), style: secondaryTextStyle(size: 12)).expand(),
                                  ],
                                ).paddingSymmetric(vertical: 2);
                              }).toList(),
                            ),
                          ],
                        ).expand(),
                      ],
                    ).onTap(() {
                      if (!appStore.isLoading)
                        setState(() {
                          groupType = GroupType.HIDDEN;
                        });
                    }),
                    32.height,
                    appButton(
                      context: context,
                      text: language!.submit.capitalizeFirstLetter(),
                      onTap: () async {
                        if (createGroupFormKey.currentState!.validate() && !appStore.isLoading) {
                          ifNotTester(() async {
                            appStore.setLoading(true);
                            Map request = {
                              "name": nameCont.text,
                              "description": descriptionCont.text,
                              "status": groupType == GroupType.PUBLIC
                                  ? GroupStatus.public
                                  : groupType == GroupType.PRIVATE
                                      ? GroupStatus.private
                                      : GroupStatus.hidden,
                            };
                            await createGroup(request).then((value) async {
                              nameCont.clear();
                              descriptionCont.clear();
                              groupId = value.first.id.validate();
                              toast(language!.groupCreatedSuccessfully);
                              appStore.setLoading(false);
                              widget.onNextPage.call(1);
                            }).catchError((e) {
                              appStore.setLoading(false);
                              toast(e.toString(), print: true);
                            });
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => LoadingWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
