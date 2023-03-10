import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/group_response.dart';
import 'package:socialv/screens/groups/screens/group_detail_screen.dart';
import 'package:socialv/screens/search/components/search_card_component.dart';
import 'package:socialv/utils/app_constants.dart';

class SearchGroupComponent extends StatelessWidget {
  final bool showRecent;
  final List<GroupResponse> groupList;
  final VoidCallback? callback;
  final ScrollController? controller;

  const SearchGroupComponent({required this.showRecent, this.callback, required this.groupList,
     this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
      child: groupList.isNotEmpty
          ? SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language!.recent, style: boldTextStyle()).paddingAll(16).visible(showRecent),
                  AnimatedListView(
                    slideConfiguration: SlideConfiguration(
                      delay: 80.milliseconds,
                      verticalOffset: 300,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    itemCount: groupList.length,
                    itemBuilder: (context, index) {
                      return SearchCardComponent(
                        isRecent: showRecent,
                        id: groupList[index].id.validate(),
                        isMember: false,
                        name: groupList[index].name.validate(),
                        image: groupList[index].avatarUrls!.full.validate(),
                        subTitle: parseHtmlString(groupList[index].description!.rendered.validate()),
                        callback: () {
                          callback?.call();
                        },
                      ).paddingSymmetric(vertical: 8).onTap(() async {
                        if (!appStore.recentGroupsSearchList.contains(groupList[index])) {
                          appStore.recentGroupsSearchList.add(groupList[index]);
                          await setValue(SharePreferencesKey.RECENT_SEARCH_GROUPS, jsonEncode(appStore.recentGroupsSearchList));
                        }
                        hideKeyboard(context);
                        GroupDetailScreen(groupId: groupList[index].id.validate()).launch(context);
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
                    },
                  ),
                ],
              ),
            )
          : Text(language!.noRecentGroupsSearched, style: boldTextStyle()).center(),
    );
  }
}
