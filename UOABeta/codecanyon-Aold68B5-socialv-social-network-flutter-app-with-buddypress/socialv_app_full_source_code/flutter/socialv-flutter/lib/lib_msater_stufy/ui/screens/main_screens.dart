import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:socialv/lib_msater_stufy/data/models/AppSettings.dart';
import 'package:socialv/lib_msater_stufy/mydrawer.dart';
import 'package:socialv/lib_msater_stufy/ui/bloc/course/bloc.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/course/course_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/profile_edit/profile_edit_screen.dart';
import '../../../../main2.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/courses/courses_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/favorites/favorites_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/home/home_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/home_simple/home_simple_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/profile/profile_screen.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/search/search_screen.dart';

import '../../../configs.dart';
import '../../../screens/fragments/home_fragment.dart';
import '../../../screens/fragments/notification_fragment.dart';
import '../../../screens/fragments/search_fragment.dart';
import '../../../screens/groups/screens/group_screen.dart';
import '../../../screens/post/screens/add_post_screen.dart';
import '../../../screens/profile/screens/profile_friends_screen.dart';
import '../../../screens/shop/screens/initial_shop_screen.dart';
import '../../../screens/stories/screen/user_story_screen.dart';
import '../../../utils/images.dart';
import 'auth/auth_screen.dart';


class MainScreenArgs {
  final OptionsBean optionsBean;

  MainScreenArgs(this.optionsBean);
}

class MainScreen extends StatelessWidget {
  final Function myCoursesCallback;
  static const routeName = "mainScreen";

  const MainScreen(this.myCoursesCallback) : super();

  @override
  Widget build(BuildContext context) {
    final dynamic? args = ModalRoute.of(context)?.settings.arguments;


    return MainScreenWidget(args!.optionsBean,myCoursesCallback);
  }
}

class MainScreenWidget extends StatefulWidget {

  final OptionsBean optionsBean;
  final Function myCoursesCallback;

  const MainScreenWidget(this.optionsBean,this.myCoursesCallback) : super();



  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreenWidget> {







  late String token;
  var _selectedIndex = 0;
  final _selectedItemColor = mainColor;
  final _unselectedItemColor = Colors.white;
  final _selectedBgColor = Colors.white;
  final _unselectedBgColor = mainColor;

  Color? _getBgColor(int index) => _selectedIndex == index ? _selectedBgColor : _unselectedBgColor;

  Color? _getItemColor(int index) => _selectedIndex == index ? _selectedItemColor : _unselectedItemColor;

  Widget _buildIcon(String iconData, String text, int index) => Container(
        width: double.infinity,
        height: kBottomNavigationBarHeight,
        child: Material(
          color: _getBgColor(index),
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //Icon(iconData),
                Padding(
                  padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                  child: SvgPicture.asset(iconData, height: 22.0, color: _getItemColor(index)),
                ),
                Text(text, textScaleFactor: 1.0, style: TextStyle(fontSize: 12, color: _getItemColor(index))),
              ],
            ),
            onTap: () => _onItemTapped(index),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
  }




   bool course_selected=false;
   bool search_selected=false;
   bool fav_selected=false;
   bool home_selected=false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var height =MediaQuery.of(context).size.height;
    var width =MediaQuery.of(context).size.width;


    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Builder(
          builder: (context1) {
            return AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              titleSpacing: 0,

              iconTheme: IconThemeData(color: mainColor),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        onTap: () {
                         print(">>>>>>");
                         Scaffold.of(context1).openDrawer();
                        },
                        child:  Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 26.0,
                        ),
                      )
                  ),







                ],
              ),
              elevation: 1,
            );
          }
        ),
      ),
      body: Builder(
        builder: (context) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _getBody(_selectedIndex),
          );
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: _buildIcon("assets/icons/ms_nav_home.svg", localizations!.getLocalization("home_bottom_nav"), 0), label: localizations!.getLocalization("home_bottom_nav")),
          BottomNavigationBarItem(
              icon: _buildIcon("assets/icons/ms_nav_courses.svg", "Social-v", 1), label: localizations!.getLocalization("courses_bottom_nav")),

          BottomNavigationBarItem(
              icon: _buildIcon("assets/icons/ms_nav_fav.svg", "M-Study", 2), label: localizations!.getLocalization("favorites_bottom_nav")),
          BottomNavigationBarItem(
              icon: _buildIcon("assets/icons/ms_nav_profile.svg", localizations!.getLocalization("profile_bottom_nav"), 3), label: localizations!.getLocalization("profile_bottom_nav")),
        ],

        elevation: 0.0,
        selectedFontSize: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: _selectedItemColor,
        unselectedItemColor: _unselectedItemColor,
        type: BottomNavigationBarType.fixed,
      ),
     // drawer: MyDrwaer(),
      drawer: Drawer(
        elevation: 8,
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[

                Container(
                  height: height*0.2,
                  color: mainColor,
                  child: Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(APP_ICON ,height: width*0.2,width: width*0.2,),
                              Text('Peacefulcities Community', style: TextStyle(color: Colors.white),)
                            ],
                          ),
                          Container()

                        ],
                      ),
                    ),
                  ),
                ),
                getDrawerItem(ic_notification,  language!.notifications, callback: () {
                  NotificationFragment().launch(context);
                }),


                getDrawerItem(ic_story,  language!.myStories, callback: () {
                  UserStoryScreen().launch(context);
                }),

                getDrawerItem(ic_plus, "New Post", callback: () {
                  AddPostScreen().launch(context);
                }),
                getDrawerItem(ic_two_user,  language!.friends, callback: () {
                  ProfileFriendsScreen().launch(context);
                }),
                getDrawerItem(ic_search,  language!.searchHere, callback: () {
                  SearchFragment().launch(context);
                }),
                getDrawerItem(ic_three_user,  language!.group, callback: () {
                  GroupScreen().launch(context);
                }),
                getDrawerItem(ic_store,  language!.shop, callback: () {

                  InitialShopScreen().launch(context);
                }),
                getDrawerItem(ic_story,  localizations!.getLocalization("courses_bottom_nav"), callback: () {

                  setState(() {
                    _selectedIndex = 0;
                    course_selected=true;
                    search_selected=false;
                    fav_selected=false;
                    scaffoldKey.currentState!.closeDrawer();

                  });


                }),
                getDrawerItem(ic_two_user,  localizations!.getLocalization("search_bottom_nav"), callback: () {
                  setState(() {
                    _selectedIndex = 0;
                    course_selected=false;
                    search_selected=true;
                    fav_selected=false;
                    scaffoldKey.currentState!.closeDrawer();

                  });

                }),
                getDrawerItem(ic_three_user,  localizations!.getLocalization("favorites_bottom_nav"), callback: () {

                  setState(() {
                    _selectedIndex = 0;
                    course_selected=false;
                    search_selected=false;
                    fav_selected=true;
                    scaffoldKey.currentState!.closeDrawer();

                  });
                }),



              ],
            ),
          ),
        ),
      ),
    );
  }




  Widget getDrawerItem(String icon, String name, {required VoidCallback callback}) {
    return InkWell(
      onTap: callback,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          children: <Widget>[
            icon != null ? Image.asset(icon, width: 20, height: 20) : Container(width: 20),
            SizedBox(width: 20),
            Text(name, style: TextStyle(color: mainColor),)
          ],
        ),
      ),
    );
  }


  void _onItemTapped(int value) {
    setState(() {

      _selectedIndex = value;

      if(_selectedIndex==0)
        {
          course_selected=false;
          search_selected=false;
          fav_selected=false;
          home_selected=true;
        }

      print(">>>>>>>>>>>>>>>>>>>>>>>>."+_selectedIndex.toString());


    });
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        if(course_selected)
        {
           return CoursesScreen((){});
         }
        else  if(search_selected)
        {
          return SearchScreen();
        }
        else  if(fav_selected)
        {
          return FavoritesScreen();
        }
        else
        {
          return   widget.optionsBean.app_view ? HomeSimpleScreen() : HomeScreen();
        }


      case 1:
        return  HomeFragment();


      case 2:
        return widget.optionsBean.app_view ? HomeSimpleScreen() : HomeScreen();
      case 3:
        return ProfileScreen(() {
          setState(() {
            _selectedIndex = 1;
          });
        });
      default:
        return Center(
          child: Text(
            "Not implemented!",
            textScaleFactor: 1.0,
          ),
        );
    }
  }


}
