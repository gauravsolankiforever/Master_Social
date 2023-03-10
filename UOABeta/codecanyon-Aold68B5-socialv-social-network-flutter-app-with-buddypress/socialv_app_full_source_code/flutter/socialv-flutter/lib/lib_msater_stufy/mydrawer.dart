import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:socialv/lib_msater_stufy/ui/screens/courses/courses_screen.dart';
import 'package:socialv/main2.dart';
import 'package:socialv/utils/app_constants.dart';

class MyDrwaer extends StatefulWidget {
  //const MyDrwaer({Key? key}) : super(key: key);

  @override
  _MyDrwaerState createState() => _MyDrwaerState();
}

class _MyDrwaerState extends State<MyDrwaer> {
  get newestProducts => null;

  @override
  Widget build(BuildContext context) {
    return  myDrawer2(context);
  }

  Widget myDrawer2(context)
  {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      child: Drawer(
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



                getDrawerItem(ic_story,  language!.myStories, callback: () {}),
                getDrawerItem(ic_two_user,  language!.friends, callback: () {}),
                getDrawerItem(ic_three_user,  language!.group, callback: () {}),
                getDrawerItem(ic_store,  language!.shop, callback: () {}),
                getDrawerItem(ic_story,  localizations!.getLocalization("courses_bottom_nav"), callback: () {

                  CoursesScreen(() {
                    setState(() {
                    });
                  });
                }),
                getDrawerItem(ic_two_user,  localizations!.getLocalization("search_bottom_nav"), callback: () {}),
                getDrawerItem(ic_three_user,  localizations!.getLocalization("favorites_bottom_nav"), callback: () {}),

                // getDrawerItem(sh_side_icon1, sh_categories, callback: () {
                //
                //   //Navigator.push(context, MaterialPageRoute(builder: (context) => ShViewAllProductScreen(prodcuts: newestProducts, title: sh_lbl_newest_product)));
                //   Navigator.push(context, MaterialPageRoute(builder: (context) => ShViewAllProductScreen()));
                //
                //   // ShAccountScreen().launch(context);
                //
                //   /*bool isWishlist = launchScreen(context, ShAccountScreen.tag) ?? false;
                //     if (isWishlist) {
                //       selectedTab = 1;
                //       setState(() {});
                //     }*/
                //
                //
                // }),

                // getDrawerItem(sh_side_icon3, sh_view_cart, callback: () {
                //   // ShSettingsScreen().launch(context);
                //   SelectProductPlaceOrder().launch(context);
                // }),
                // getDrawerItem(sh_side_icon4, sh_lbl_logOut, callback: () {
                //
                //   showAlertDialog(context);
                //
                //   // ShSettingsScreen().launch(context);
                // }),
                // Container(
                //   padding: EdgeInsets.all(10),
                //   child: Column(
                //     children: <Widget>[
                //       Image.asset(ic_app_icon_rosetta2, width: 150,height:150 ,fit: BoxFit.fill,),
                //
                //       text("v 1.0", textColor: sh_textColorPrimary, fontSize: textSizeSmall)
                //     ],
                //   ),
                // ),

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
  // clearSession(context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //Return String
  //   prefs.remove('username');
  //   prefs.remove('password');
  //   prefs.remove('token');
  //   prefs.remove('activityflag');
  //   print("Clear Session Methode Called ");
  //
  //
  //   // Navigator.of(context, rootNavigator: true).pushReplacement(
  //   //     MaterialPageRoute(builder: (context) => LoginScreen()),);
  //
  //   Navigator.of(context, rootNavigator:
  //   true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
  //       LoginScreen()), (route) => false);
  //
  //
  //   //LoginScreen().launch(context);
  //
  // }

  // showAlertDialog(BuildContext context) {
  //   // set up the button
  //
  //   Widget cancelButton = RaisedButton(
  //     child: Text("yes"),
  //     textColor: Colors.white,
  //     color: Colors.green,
  //     onPressed: () {
  //       clearSession(context);
  //
  //
  //
  //     },
  //
  //   );
  //   Widget continueButton = RaisedButton(
  //     child: Text("No"),
  //     textColor: Colors.white,
  //     color: Colors.red,
  //     onPressed: () async {
  //       Navigator.pop(context);
  //       await Navigator.of(context)
  //           .push(new MaterialPageRoute(builder: (context) => LoginScreen()));
  //       setState((){});
  //
  //     },
  //   );
  //
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Log-out"),
  //     content: Text("Are you want to logout "),
  //     actions: [
  //
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }
}