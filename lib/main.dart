import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:exim/screens/dash.dart';
import 'package:exim/screens/login.dart';
import 'package:exim/screens/noInternet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding().ensureVisualUpdate();
  WidgetsFlutterBinding.ensureInitialized();

  
  Widget _defaultPage = LoginPage();

  Future<int> _checkIfLoggedIn() async {
    final _prefs = await SharedPreferences.getInstance();
    int _isLoggedIn = _prefs.getInt('MC_EmpCode');

    print('(Future) Is Logged In value from shared prefernces is: ' + _isLoggedIn.toString());

    return _isLoggedIn;
  }


  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
  bool _isConnected = await check();

  if (_isConnected == true) {

    print("*** _isConnected App Start = $_isConnected ****");

    int _isLoggedIn = await _checkIfLoggedIn();

    if (_isLoggedIn != null && _isLoggedIn > 0) {
      _defaultPage = DashPage();
    }
    else{
      _defaultPage = LoginPage();
    }
  }
  if (_isConnected == false) {

    print("*** _isConnected App Start = $_isConnected ****");

    _defaultPage = NoInternetPage();
  }

  await runZonedGuarded(()async{
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(
    MaterialApp(
      home: _defaultPage,
      title: 'EXIM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    ),
  );

  }, (error,stackTrace){
    print(error);
    FirebaseCrashlytics.instance.recordError(error, stackTrace,fatal: true);
  });
  

  
}

