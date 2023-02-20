import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import '../screens/noInternet.dart';
import '../transitions/slide_route.dart';

class CheckInternet {
  void check(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
    } else if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {}
  }
}
