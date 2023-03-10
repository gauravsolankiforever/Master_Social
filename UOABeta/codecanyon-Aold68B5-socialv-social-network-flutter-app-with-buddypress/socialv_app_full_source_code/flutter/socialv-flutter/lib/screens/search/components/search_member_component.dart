import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/member_response.dart';
import 'package:socialv/screens/fragments/profile_fragment.dart';
import 'package:socialv/screens/profile/screens/member_profile_screen.dart';
import 'package:socialv/screens/search/components/search_card_component.dart';
import 'package:socialv/utils/app_constants.dart';

class SearchMemberComponent extends StatelessWidget {
  final bool showRecent;
  final List<MemberResponse> memberList;
  final VoidCallback? callback;
  final ScrollController? controller;

  const SearchMemberComponent({required this.showRecent,
    required this.memberList, this.callback,
     this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      decoration: BoxDecoration(color: context.cardColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
      child: memberList.isNotEmpty
          ? SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showRecent) Text(language!.recent, style: boldTextStyle()).paddingOnly(left: 16, top: 16, right: 16),
                  AnimatedListView(
                    slideConfiguration: SlideConfiguration(
                      delay: 80.milliseconds,
                      verticalOffset: 300,
                    ),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    itemCount: memberList.length,
                    itemBuilder: (context, index) {
                      return SearchCardComponent(
                        isRecent: showRecent,
                        id: memberList[index].id.validate(),
                        name: memberList[index].name.validate(),
                        image: memberList[index].avatarUrls!.full.validate(),
                        subTitle: memberList[index].mentionName.validate(),
                        isMember: true,
                        callback: () {
                          callback?.call();
                        },
                      ).paddingSymmetric(vertical: 8).onTap(() async {
                        if (!appStore.recentMemberSearchList.contains(memberList[index])) {
                          appStore.recentMemberSearchList.add(memberList[index]);
                          await setValue(SharePreferencesKey.RECENT_SEARCH_MEMBERS, jsonEncode(appStore.recentMemberSearchList));
                        }
                        if (memberList[index].id.toString() == appStore.loginUserId) {
                          hideKeyboard(context);
                          ProfileFragment().launch(context);
                        } else {
                          hideKeyboard(context);
                          MemberProfileScreen(memberId: memberList[index].id.validate()).launch(context).then((value) {
                            callback!.call();
                          });
                        }
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent);
                    },
                  ),
                ],
              ),
            )
          : Text(language!.noRecentMembersSearched, style: boldTextStyle()).center(),
    );
  }
}
