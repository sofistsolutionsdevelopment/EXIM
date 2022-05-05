import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:exim/screens/dash.dart';
import 'package:exim/screens/login.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoInternetPage extends StatefulWidget {
  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {


  Future<int> _checkIfLoggedIn() async {
    final _prefs = await SharedPreferences.getInstance();
    int _isLoggedIn = _prefs.getInt('MC_EmpCode');

    print('(Future) Is Logged In value from shared prefernces is: ' + _isLoggedIn.toString());

    return _isLoggedIn;
  }

  void check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
      print("*** _isConnected No Internet Connected page Load = $connectivityResult ****");
      int _isLoggedIn = await _checkIfLoggedIn();

      if (_isLoggedIn != null && _isLoggedIn > 0) {
        Navigator.pushReplacement(context, SlideLeftRoute(page: DashPage()));
      }
      else{
        Navigator.pushReplacement(context, SlideLeftRoute(page: LoginPage()));
      }

    }
  }

  Timer timer;

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => check());
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void rebuildPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context)
            .pushReplacement(new MaterialPageRoute(builder: (context) => DashPage(onPressed: rebuildPage)));
        return new Future(() => false); //onWillPop is Future<bool> so return false
      },
      child: Scaffold(
        body:Image.asset(
        "assets/noInternet.png",  fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),),
    );
  }
}
