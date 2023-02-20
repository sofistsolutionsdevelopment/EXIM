import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:exim/constant/colors.dart';
import 'package:exim/core/checkinternet.dart';
import 'package:exim/models/getExportTypeWiseBoxesData_model.dart';
import 'package:exim/models/getExportTypeWiseBoxesResult_model.dart';
import 'package:exim/screens/boxDetails.dart';
import 'package:exim/screens/dash.dart';
import 'package:exim/screens/noInternet.dart';
import 'package:exim/screens/profile.dart';
import 'package:exim/screens/setting.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompletedCancelBoxDetails extends StatefulWidget {
  final Function onPressed;
  final String exportType_value;
  final String exportType;
  final String boxCount;

  CompletedCancelBoxDetails(
      {this.onPressed, this.exportType_value, this.exportType, this.boxCount});

  @override
  State<CompletedCancelBoxDetails> createState() =>
      _CompletedCancelBoxDetailsState();
}

class _CompletedCancelBoxDetailsState extends State<CompletedCancelBoxDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  double percentage;
  static int refreshNum = 10; // number that changes when refreshed
  Stream<int> counterStream =
      Stream<int>.periodic(const Duration(seconds: 1), (x) => refreshNum);

  ScrollController _scrollController;

  int getExportTypeWiseBoxesListLenght;
  Map Json;
  List getExportTypeWiseBoxesDataList = List();
  List<GetExportTypeWiseBoxesResultModel> _resultGetExportTypeWiseBoxesResult;
  Future<GetExportTypeWiseBoxesDataModel> _resultGetExportTypeWiseBoxesData;
  Future<GetExportTypeWiseBoxesDataModel> getExportTypeWiseBoxes() async {
    print("Api getExportTypeWiseBoxes 1.........");
    try {
      print("Api getExportTypeWiseBoxes 1");
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint(
          'Check getExportTypeWiseBoxes _API_Path $APIPath/Dashboard/GetExportTypeWiseBoxesForCompletedAndCancelled ');
      debugPrint('Check getExportTypeWiseBoxes _Token $Token ');

      final String apiUrl =
          "$APIPath/Dashboard/GetExportTypeWiseBoxesForCompletedAndCancelled";

      print("Api getExportTypeWiseBoxes _Token : $Token");
      print(
          "Api getExportTypeWiseBoxes ExportType_value: ${widget.exportType_value}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({
          "ExportType_value": widget.exportType_value,
        }),
      );

      print("Api getExportTypeWiseBoxes 3");

      print(
          "Api getExportTypeWiseBoxes response code : ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Api getExportTypeWiseBoxes 4");

        final String responseString = response.body;

        Json = json.decode(responseString);
        debugPrint('Api getExportTypeWiseBoxes 6 Json $Json');

        getExportTypeWiseBoxesDataList = Json["Data"];
        setState(() {
          getExportTypeWiseBoxesListLenght =
              getExportTypeWiseBoxesDataList.length;

          _resultGetExportTypeWiseBoxesResult = Json["Data"]
              .map<GetExportTypeWiseBoxesResultModel>(
                  (e) => GetExportTypeWiseBoxesResultModel.fromJson(e))
              .toList();
        });

        return getExportTypeWiseBoxesDataModelDataModelFromJson(responseString);
      } else {
        print("Api getExportTypeWiseBoxes 7");
        return null;
      }
    } catch (e) {
      print("Api getExportTypeWiseBoxes 8");

      print(e);
      return null;
    }
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 1), () {
      completer.complete();
    });
    setState(() {
      refreshNum = Random().nextInt(100);
    });
    return completer.future.then<void>((_) {
      //Navigator.pushReplacement(context, SlideLeftRoute(page: BoxRouteDetailsPage(exportType_value:widget.exportType_value, exportType:widget.exportType, boxNo_Value:widget.boxNo_Value, boxNo:widget.boxNo, boxCount:widget.boxCount)));

      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => BoxRouteDetailsPage(exportType_value:widget.exportType_value, exportType:widget.exportType, boxNo_Value:widget.boxNo_Value, boxNo:widget.boxNo, boxCount:widget.boxCount)));

      setState(() {
        CheckInternet().check(context);
        _resultGetExportTypeWiseBoxesData = getExportTypeWiseBoxes();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Page Refreshed',
            style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.1),
          ),
        ),
      );
      // _resultGetBoxRouteDetailsData =  getBoxRouteDetails();
    });
  }

  void rebuildPage() {
    setState(() {});
  }

  @override
  void initState() {
    CheckInternet().check(context);
    _resultGetExportTypeWiseBoxesData = getExportTypeWiseBoxes();
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        //on Back button press, you can use WillPopScope for another purpose also.
        // Navigator.pop(context); //return data along with pop
        Navigator.pop(context);
        return new Future(
            () => false); //onWillPop is Future<bool> so return false
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: appBgColor,
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 95),
          child: AppBar(
            backgroundColor: appbarColor,
            elevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Image.asset(
                  "assets/back.png",
                  width: 25,
                  height: 25,
                ),
                onPressed: () {
                  Navigator.of(context).pop("success");
                },
              ),
            ),
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                widget.exportType.toUpperCase(),
                style: TextStyle(
                    fontFamily: "AlternateGothic",
                    fontWeight: FontWeight.w500,
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: 1),
              ),
            ),
          ),
        ),
        body: LiquidPullToRefresh(
          color: appbarColor,
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          child: Container(
            color: appbarColor,
            child: Padding(
              padding: const EdgeInsets.all(0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  color: appBgColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (getExportTypeWiseBoxesListLenght == 0)
                        Center(
                          child: Text(
                            'Boxes Details Not Found',
                            style: TextStyle(
                              fontSize: 22,
                              color: appColor,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (getExportTypeWiseBoxesListLenght != 0)
                        SizedBox(
                          height: 15,
                        ),
                      if (getExportTypeWiseBoxesListLenght != 0)
                        Text(
                          "Total ${widget.boxCount} Boxes",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: appBtnColor),
                        ),
                      if (getExportTypeWiseBoxesListLenght != 0)
                        SizedBox(
                          height: 15,
                        ),
                      // if (getBoxDetailsListLenght != 0)
                      Expanded(
                        child: FutureBuilder(
                            future: _resultGetExportTypeWiseBoxesData,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Center(
                                  child: ListView.builder(
                                    itemCount:
                                        getExportTypeWiseBoxesDataList.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            right: 3, left: 3, top: 3),
                                        child: InkWell(
                                          onTap: () async {
                                            var connectivityResult =
                                                await (Connectivity()
                                                    .checkConnectivity());
                                            if (connectivityResult ==
                                                ConnectivityResult.none) {
                                              print(
                                                  "*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                              Navigator.push(
                                                  context,
                                                  SlideLeftRoute(
                                                      page: NoInternetPage()));
                                            } else if (connectivityResult ==
                                                    ConnectivityResult.wifi ||
                                                connectivityResult ==
                                                    ConnectivityResult.mobile) {
                                              print(
                                                  "*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                              String exportTypeValue =
                                                  getExportTypeWiseBoxesDataList[
                                                              index]
                                                          ["ExportType_value"]
                                                      .toString();
                                              String exportType =
                                                  getExportTypeWiseBoxesDataList[
                                                          index]["ExportType"]
                                                      .toString();
                                              String boxCount =
                                                  getExportTypeWiseBoxesDataList[
                                                          index]["BoxCount"]
                                                      .toString();
                                              String section =
                                                  getExportTypeWiseBoxesDataList[
                                                          index]["section"]
                                                      .toString();

                                              Navigator.push(
                                                  context,
                                                  SlideLeftRoute(
                                                      page: BoxDetailsPage(
                                                    exportType_value:
                                                        exportTypeValue,
                                                    exportType: exportType,
                                                    boxCount: boxCount,
                                                    section: section,
                                                  ))).then((value) {
                                                if (value == "success") {
                                                  CheckInternet()
                                                      .check(context);
                                                  _resultGetExportTypeWiseBoxesData =
                                                      getExportTypeWiseBoxes();
                                                }
                                              });
                                            }
                                          },
                                          child: Card(
                                            color: Colors.white,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 1, bottom: 1),
                                              child: ListTile(
                                                leading: Image.asset(
                                                  "assets/normalExport.png",
                                                  width: 40,
                                                  height: 40,
                                                ),
                                                title: Text(
                                                  getExportTypeWiseBoxesDataList[
                                                      index]["ExportType"],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${getExportTypeWiseBoxesDataList[index]["BoxCount"].toString()} Boxes",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                trailing: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor:
                                                      routePageColor
                                                          .withOpacity(0.7),
                                                  child: IconButton(
                                                      iconSize: 18,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 6,
                                                              right: 8),
                                                      icon: const Icon(
                                                        Icons.navigate_next,
                                                        color:
                                                            Color(0xFF383182),
                                                      ),
                                                      onPressed: () async {
                                                        var connectivityResult =
                                                            await (Connectivity()
                                                                .checkConnectivity());
                                                        if (connectivityResult ==
                                                            ConnectivityResult
                                                                .none) {
                                                          print(
                                                              "*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                                          Navigator.push(
                                                              context,
                                                              SlideLeftRoute(
                                                                  page:
                                                                      NoInternetPage()));
                                                        } else if (connectivityResult ==
                                                                ConnectivityResult
                                                                    .wifi ||
                                                            connectivityResult ==
                                                                ConnectivityResult
                                                                    .mobile) {
                                                          print(
                                                              "*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                                          String
                                                              exportTypeValue =
                                                              getExportTypeWiseBoxesDataList[
                                                                          index]
                                                                      [
                                                                      "ExportType_value"]
                                                                  .toString();
                                                          String exportType =
                                                              getExportTypeWiseBoxesDataList[
                                                                          index]
                                                                      [
                                                                      "ExportType"]
                                                                  .toString();
                                                          String boxCount =
                                                              getExportTypeWiseBoxesDataList[
                                                                          index]
                                                                      [
                                                                      "BoxCount"]
                                                                  .toString();
                                                          String section =
                                                              getExportTypeWiseBoxesDataList[
                                                                          index]
                                                                      [
                                                                      "section"]
                                                                  .toString();

                                                          Navigator.push(
                                                              context,
                                                              SlideLeftRoute(
                                                                  page:
                                                                      BoxDetailsPage(
                                                                exportType_value:
                                                                    exportTypeValue,
                                                                exportType:
                                                                    exportType,
                                                                boxCount:
                                                                    boxCount,
                                                                section:
                                                                    section,
                                                              ))).then((value) {
                                                            if (value ==
                                                                "success") {
                                                              CheckInternet()
                                                                  .check(
                                                                      context);
                                                              _resultGetExportTypeWiseBoxesData =
                                                                  getExportTypeWiseBoxes();
                                                            }
                                                          });
                                                        }
                                                      }),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Align(
                                    alignment: Alignment.center,
                                    child: Text(""));
                              }

                              return Center(
                                  child: SpinKitRotatingCircle(
                                color: appColor,
                                size: 30.0,
                              ));
                            }),
                      ),
                    ],
                  ),
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
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(onPressed: rebuildPage)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              new MaterialPageRoute(
                                  builder: (context) =>
                                      DashPage(onPressed: rebuildPage)));
                        },
                        child: Icon(
                          Icons.home,
                          color: Colors.grey,
                          size: 30,
                        )),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                builder: (context) =>
                                    SettingPage(onPressed: rebuildPage)));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.settings,
                          color: Colors.grey,
                          size: 30,
                        ),
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
