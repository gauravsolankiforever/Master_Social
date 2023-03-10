import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/components/loading_widget.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/models/group_response.dart';
import 'package:socialv/models/member_response.dart';
import 'package:socialv/network/rest_apis.dart';
import 'package:socialv/screens/search/components/search_group_component.dart';
import 'package:socialv/screens/search/components/search_member_component.dart';

import '../../utils/app_constants.dart';

class SearchFragment extends StatefulWidget {
  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> with SingleTickerProviderStateMixin {
  List<MemberResponse> memberList = [];
  List<GroupResponse> groupList = [];

  TextEditingController searchController = TextEditingController();
  late TabController tabController;

  ScrollController _scrollController = ScrollController();

  int mPage = 1;
  bool mIsLastPage = false;

  bool hasShowClearTextIcon = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!mIsLastPage) {
          mPage++;

          if (tabController.index == 0) {
            getMembersList(text: searchController.text.trim(), page: mPage);
          } else {
            getGroups(text: searchController.text.trim(), page: mPage);
          }
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        hasShowClearTextIcon = false;
        setState(() {});
      }
    });
  }

  Future<void> getMembersList({String? text, int page = 1}) async {
    if (text!.isEmpty) {
      memberList.clear();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(true);
      await getAllMembers(type: MemberType.alphabetical, searchText: text, page: page).then((value) {
        mIsLastPage = value.length != 20;
        if (page == 1) memberList.clear();
        memberList.addAll(value);


        appStore.setLoading(false);
      }).catchError((e) {
        toast(e.toString());
        appStore.setLoading(false);
      });
    }
    setState(() {});
  }

  Future<void> getGroups({String? text, int page = 1})
  async
  {


    if (text!.isEmpty) {
      groupList.clear();
    } else {
      appStore.setLoading(true);

      await getUserGroups(searchText: text, page: page).then((value) {
        mIsLastPage = value.length != 20;
        if (page == 1) groupList.clear();
        groupList.addAll(value);
        appStore.setLoading(false);
      }).catchError((e) {
        toast(e.toString());
        appStore.setLoading(false);
      });
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    tabController.dispose();
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void showClearTextIcon() {
    if (!hasShowClearTextIcon) {
      hasShowClearTextIcon = true;
      setState(() {});
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: context.iconColor),
          leadingWidth: 30,
          title: Container(
            margin: EdgeInsets.only(top: 8),
            decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(8)),
            child: AppTextField(
              controller: searchController,
              onChanged: (val) {
                if (tabController.index == 0) {
                  getMembersList(text: val);
                } else {
                  getGroups(text: val);
                }
              },
              textFieldType: TextFieldType.USERNAME,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: language!.searchHere,
                hintStyle: secondaryTextStyle(),
                prefixIcon: Image.asset(
                  ic_search,
                  height: 16,
                  width: 16,
                  fit: BoxFit.cover,
                  color: appStore.isDarkMode ? bodyDark : bodyWhite,
                ).paddingAll(16),
                suffixIcon: hasShowClearTextIcon
                    ? IconButton(
                        icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
                        onPressed: () {
                          hideKeyboard(context);

                          memberList.clear();
                          groupList.clear();
                          searchController.clear();
                          hasShowClearTextIcon = false;
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                Container(
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
                  ),
                  padding: EdgeInsets.fromLTRB(22, 12, 22, 0),
                  child: TabBar(
                    unselectedLabelColor: Colors.white54,
                    labelColor: Colors.white,
                    labelStyle: boldTextStyle(),
                    unselectedLabelStyle: primaryTextStyle(),
                    controller: tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicator: TabIndicator(),
                    tabs: [
                      Text(language!.members).paddingSymmetric(vertical: 12),
                      Text(language!.groups).paddingSymmetric(vertical: 12),
                    ],
                  ),
                ),
                Container(
                  color: context.primaryColor,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SearchMemberComponent(
                        controller: _scrollController,
                        memberList: memberList.isEmpty ? appStore.recentMemberSearchList : memberList,
                        showRecent: memberList.isEmpty ? true : false,
                        callback: () {
                          setState(() {});
                        },
                      ),
                      SearchGroupComponent(
                        controller: _scrollController,
                        showRecent: groupList.isEmpty ? true : false,
                        groupList: groupList.isEmpty ? appStore.recentGroupsSearchList : groupList,
                        callback: () {
                          setState(() {});
                        },
                      )
                    ],
                  ),
                ).expand(),
              ],
            ),
            Observer(builder: (_) => LoadingWidget(isBlurBackground: false).center().visible(appStore.isLoading))
          ],
        ),
      ),
    );
  }
}
