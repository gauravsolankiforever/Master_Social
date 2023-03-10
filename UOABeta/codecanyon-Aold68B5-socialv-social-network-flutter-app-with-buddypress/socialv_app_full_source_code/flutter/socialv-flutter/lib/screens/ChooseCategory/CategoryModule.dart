import 'package:flutter/material.dart';
import 'package:socialv/configs.dart';

import '../../utils/colors.dart';
class CategotyModule extends StatefulWidget {
  const CategotyModule({Key? key}) : super(key: key);

  @override
  State<CategotyModule> createState() => _CategotyModuleState();
}

class _CategotyModuleState extends State<CategotyModule> {

  int category=1;
  int val = 1;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var roundDecorationApp=  BoxDecoration(

    border: Border.all(
    color: Colors.black,
    width: 1,
    ),
    );

    var roundDecorationAppSelected =  BoxDecoration(

    border: Border.all(
    color: appColorPrimary,
    width: 1,
    ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body:
          Container(
            height: height,
            width: width,
            margin: EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(

                          height: (width*0.4)-15,
                          width: (width*0.4)-15,
                          child: Stack(
                            children: [
                              Container(child:Image.asset(APP_ICON),)
                            ],
                          ),
                          decoration: roundDecorationAppSelected,

                        ),
                        Container(
                          height: (width*0.4)-15,
                          width: (width*0.4)-15,
                          child: Stack(
                            children: [
                              Image.asset("assets/icons/logo.png")
                            ],

                          ),
                          decoration: roundDecorationApp,
                        ),
                      ],
                    ),
                    Container(

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            width: (width*0.4)-15,

                            child:ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              title: Text("Social_V"),
                              leading: Radio(
                                  value: 1,
                                  groupValue: val,
                                  onChanged: (value)
                                  {
                                    setState(() {
                                      val=value as int;
                                    });
                                  }
                              ),
                            ),
                          ),


                          Container(
                            width: (width*0.4)-15,
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              title: Text("Master_Study"),
                              leading: Radio(
                                  value: 2,
                                  groupValue: val,
                                  onChanged: (value)
                                  {
                                    setState(() {
                                      val=value as int;
                                    });
                                  }
                              ),
                            ),
                          ),


                        ],
                      ),
                    ),
                  ],
                ),



                Container(
                  width: width,

                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(

                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child:Center(child: Text("Continue",style: TextStyle(fontSize: 15.0),)),

                  ),
                ),
                Container()

              ],

            ),
          ),
      ),
    );
  }
}
