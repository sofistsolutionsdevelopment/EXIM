
import 'package:exim/constant/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dash.dart';
import 'login.dart';

class DrawerPage extends StatefulWidget {
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

  Future<bool> _logOut() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              color: appColor,
              child: Padding(
                padding: const EdgeInsets.only(left:1, right:1, top:12, bottom:12),
                child: Text('Are you sure?',style: TextStyle(fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,fontSize: 18, color: Colors.white),textAlign:TextAlign.center ,),
              ),
            ),
            content:Text('You really want to Logout ?',style: TextStyle(fontFamily: "Poppins",
                fontWeight: FontWeight.w500,fontSize: 16),),
            actions: <Widget>[

              TextButton(
                //color: Color(0xFF4938B4),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Yes',style: TextStyle(color: appColor,fontSize: 18, fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,),),
                ),
                onPressed: () async{
                  final _prefs = await SharedPreferences.getInstance();
                  _prefs.clear();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                // onPressed: ()=> exit(0),

              ),
              TextButton(
                //color: Color(0xffd47fa6),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('No',style: TextStyle(color: appColor,fontSize: 18, fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,),),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: new ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 100,
            color: appBgColor,
            child: DrawerHeader(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[
                     appColor,appColor
                    ])
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('MENUS', style: TextStyle(color: Colors.white, fontSize: 25,fontFamily: "AlternateGothic",
                      fontWeight: FontWeight.w500,letterSpacing: 1.5),),
                    InkWell(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close,color: Colors.white, size: 30,)),
                  ],
                ),),
          ),
          new Container(
            child: Column(
              children: <Widget>[


                ListTile(
                  dense: true,
                  onTap: () async {
                    _logOut();
                  },
                  leading: Container(
                    width: 15,height: 15,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: appBtnColor
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20)),color: routePageColor
                      ),

                  ),/*Image.asset(
                    "assets/bullet.png",width: 20,height: 20,
                  ),*/
                  trailing: Padding(
                    padding: const EdgeInsets.only(right:2),
                    child: Icon(Icons.arrow_forward_ios,size: 20,),
                  ),
                  title: Text('Logout',style: TextStyle(fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,fontSize: 20),),
                ),

              ],
            ),
          ),



        ],
      ),

    );

  }



}

