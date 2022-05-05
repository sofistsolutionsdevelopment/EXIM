import 'package:exim/constant/colors.dart';
import 'package:exim/screens/profile.dart';
import 'package:flutter/material.dart';

import 'dash.dart';


class SettingPage extends StatefulWidget {
  final Function onPressed;

  SettingPage({this.onPressed});
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void rebuildPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        //on Back button press, you can use WillPopScope for another purpose also.
        // Navigator.pop(context); //return data along with pop
        Navigator.of(context)
            .pushReplacement(new MaterialPageRoute(builder: (context) => DashPage(onPressed: rebuildPage)));
        return new Future(() => false); //onWillPop is Future<bool> so return false
      },
      child: Scaffold(
        backgroundColor: appBgColor,
        appBar:   PreferredSize(
          preferredSize: Size(double.infinity, 95),
          child: AppBar(
            backgroundColor: appbarColor,elevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon:  Image.asset(
                  "assets/back.png",width: 25,height: 25,),
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacement(new MaterialPageRoute(builder: (context) => DashPage(onPressed: rebuildPage)));
                },
              ),
            ),
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child:Text("SETTING", style: TextStyle(
                  fontFamily: "AlternateGothic",
                  fontWeight: FontWeight.w500,fontSize: 32,color: Colors.white,letterSpacing: 1),),),
          ),),

        body: Container(
          color: appbarColor,
          child: Padding(
            padding: const EdgeInsets.all(0.1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),topLeft: Radius.circular(20),
                ),color: appBgColor,
              ),
              child: Center(
                child: Text(
                  "Version  :  1.0",
                  style: TextStyle(color: Colors.black, fontFamily: "Poppins",
                      fontWeight: FontWeight.w500, fontSize: 20),
                ),
              ),
            ),
          ),
        ),

        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                      onTap:(){
                        Navigator.of(context)
                            .pushReplacement(new MaterialPageRoute(builder: (context) => ProfilePage(onPressed: rebuildPage)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left:10),
                        child: Icon(Icons.person, color: Colors.grey, size: 30,),
                      ),
                    ),
                    InkWell(
                        onTap:(){
                          Navigator.of(context)
                              .pushReplacement(new MaterialPageRoute(builder: (context) => DashPage(onPressed: rebuildPage)));
                        },
                        child: Icon(Icons.home, color: Colors.grey,size: 30,)),
                    InkWell(
                      onTap:(){
                        Navigator.of(context)
                            .pushReplacement(new MaterialPageRoute(builder: (context) => SettingPage(onPressed: rebuildPage)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right:10),
                        child: Icon(Icons.settings, color: Colors.black,size: 30,),
                      ),
                    ),
                  ],
                ),
              ),
            ),


          ],
        ),

      ),
    );
  }
}
