import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialv/main2.dart';

class MyAppBar extends StatelessWidget

{
  bool homeback;
  String title;

  MyAppBar(this.homeback,this.title);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                  Scaffold.of(context).openEndDrawer();
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
}