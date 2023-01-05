import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:exim/screens/search_boxDetails.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:connectivity/connectivity.dart';
import 'package:exim/constant/colors.dart';
import 'package:exim/models/getExportTypeWiseBoxesData_model.dart';
import 'package:exim/models/getExportTypeWiseBoxesResult_model.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'boxDetails.dart';
import 'drawer.dart';
import 'noInternet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:exim/models/validateScanBoxData_model.dart';
import 'directScan_boxRouteDetails.dart';

class DashPage extends StatefulWidget {
  final Function onPressed;

  DashPage({this.onPressed});

  @override
  _DashPageState createState() => _DashPageState();
}

class _DashPageState extends State<DashPage> {

  String userName = "";

  int selectedPos = 1;

  double bottomNavBarHeight = 50;

  List<TabItem> tabItems = List.of([
    new TabItem(Icons.person, "", Colors.white, ),
    new TabItem(Icons.home, "", Colors.white,),
    new TabItem(Icons.settings, "", Colors.white),
  ]);

  CircularBottomNavigationController _navigationController;

  void check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("*** _isConnected Dash page Load = $connectivityResult ****");
      Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
      /*Navigator.push(context,
          MaterialPageRoute(builder: (context) => NoInternetPage()));*/
    }
    else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
      print("*** _isConnected Dash page Load = $connectivityResult ****");


      final _prefs = await SharedPreferences.getInstance();
      userName = _prefs.getString('Username');
      print("*** _isConnected Dash page Load userName = $userName ****");

    }
  }


  int getExportTypeWiseBoxesListLenght;
  Map Json;
  List getExportTypeWiseBoxesDataList = List();
  List<GetExportTypeWiseBoxesResultModel> _resultGetExportTypeWiseBoxesResult;
  Future<GetExportTypeWiseBoxesDataModel> _resultGetExportTypeWiseBoxesData;
  Future<GetExportTypeWiseBoxesDataModel> getExportTypeWiseBoxes () async{
    print("Api getExportTypeWiseBoxes 1.........");
    try{
      print("Api getExportTypeWiseBoxes 1");
      final _prefs = await SharedPreferences.getInstance();
      String _API_Path = _prefs.getString('API_Path');
      String _Token = _prefs.getString('Token');
      debugPrint('Check getExportTypeWiseBoxes _API_Path $_API_Path ');
      debugPrint('Check getExportTypeWiseBoxes _Token $_Token ');

      final String apiUrl = "$_API_Path/Dashboard/GetExportTypeWiseBoxes";

      print("Api getExportTypeWiseBoxes 2");
      print("Api getExportTypeWiseBoxes _Token : $_Token");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {HttpHeaders.contentTypeHeader: 'application/json', 'x-access-token': _Token},
        body: json.encode({}),
      );

      print("Api getExportTypeWiseBoxes 3");

      print("Api getExportTypeWiseBoxes response code : ${response.statusCode}");

      if(response.statusCode == 200){

        print("Api getExportTypeWiseBoxes 4");

        final String responseString = response.body;

        Json = json.decode(responseString);
        debugPrint('Api getExportTypeWiseBoxes 6 Json ${Json}');

        getExportTypeWiseBoxesDataList = Json["Data"];
        setState(() {
          getExportTypeWiseBoxesListLenght = getExportTypeWiseBoxesDataList.length;

          _resultGetExportTypeWiseBoxesResult = Json["Data"].map<GetExportTypeWiseBoxesResultModel>((e) => GetExportTypeWiseBoxesResultModel.fromJson(e)).toList();
        });


        return getExportTypeWiseBoxesDataModelDataModelFromJson(responseString);
      }
      else{
        print("Api getExportTypeWiseBoxes 7");
        return null;
      }
    }
    catch (e) {
      print("Api getExportTypeWiseBoxes 8");

      print(e);
      return null;
    }
  }


  @override
  void initState() {
    _navigationController = new CircularBottomNavigationController(selectedPos);
    check();
    _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
    super.initState();
    // throw Exception("Testing is testing......");
  }

  Widget tab1() {
    return Container(
      color: appBgColor,
      child:
      FutureBuilder(
          future: _resultGetExportTypeWiseBoxesData,
          builder: (context, snapshot)
          {
            if (snapshot.hasData)
            {
              return  Center(
                child: ListView.builder(
                  itemCount: getExportTypeWiseBoxesDataList.length,
                  itemBuilder: (context, index) {
                    if(getExportTypeWiseBoxesDataList[index]['isImport'] == 0){
                      return Padding(
                      padding: const EdgeInsets.only(right:3,left:3,top:3),
                      child: InkWell(
                        onTap: () async{
                          var connectivityResult = await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.none) {
                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                            Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                          }
                          else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                            String exportType_value = getExportTypeWiseBoxesDataList[index]["ExportType_value"].toString();
                            String exportType = getExportTypeWiseBoxesDataList[index]["ExportType"].toString();
                            String boxCount = getExportTypeWiseBoxesDataList[index]["BoxCount"].toString();

                            Navigator.push(context, SlideLeftRoute(page: BoxDetailsPage(exportType_value:exportType_value, exportType:exportType, boxCount:boxCount))).then((value){
                              if(value == "success"){
                                check();
                                _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                              }
                            });
                          }
                        },
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(top:1,bottom: 1),
                            child: ListTile(
                              leading:  Image.asset(
                                "assets/normalExport.png",width: 40,height: 40,
                              ),
                              title: Text(getExportTypeWiseBoxesDataList[index]["ExportType"], style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                              subtitle: Text("${getExportTypeWiseBoxesDataList[index]["BoxCount"].toString()} Boxes", style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                              trailing:CircleAvatar(
                                radius: 15,
                                backgroundColor: routePageColor.withOpacity(0.7),
                                child: IconButton(
                                    iconSize: 18,
                                    padding: const EdgeInsets.only(left:6,right: 8),
                                    icon: const Icon(Icons.navigate_next,color: Color(0xFF383182),),
                                    onPressed: () async {
                                      var connectivityResult = await (Connectivity().checkConnectivity());
                                      if (connectivityResult == ConnectivityResult.none) {
                                        print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                        Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                      }
                                      else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                        print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                        String exportType_value = getExportTypeWiseBoxesDataList[index]["ExportType_value"].toString();
                                        String exportType = getExportTypeWiseBoxesDataList[index]["ExportType"].toString();
                                        String boxCount = getExportTypeWiseBoxesDataList[index]["BoxCount"].toString();

                                        Navigator.push(context, SlideLeftRoute(page: BoxDetailsPage(exportType_value:exportType_value, exportType:exportType, boxCount:boxCount))).then((value){
                                          if(value == "success"){
                                            check();
                                            _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                                          }
                                        });
                                      }
                                    }),
                              ),
                              /*
                               Ink(width: 30,
                                decoration:
                                const ShapeDecoration(
                                    shape: CircleBorder(),
                                    color: Color(0xFFfef0ec)
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.navigate_next),
                                  iconSize: 20,
                                  color: Color(0xFF383182),
                                  onPressed: () {},
                                ),
                              )

                              CircleAvatar(
                                radius: 20,
                                backgroundColor: routePageColor,
                                child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(Icons.navigate_next,color: Color(0xFF383182),),
                                    onPressed: () {
                                      // do something
                                    }),
                              ),*/
                             /* Image.asset(
                                "assets/nextArrow.png",width: 30,height: 30,
                              ),*/
                            ),
                          ),
                        ),
                      ),
                    );
                    }else{
                      return Container();
                    }
                  },
                ),
              );
            }
            else if (snapshot.hasError)
            {
              return Align(alignment: Alignment.center, child: Text(""));
            }

            return Center(child: SpinKitRotatingCircle(
              color: appColor,
              size: 30.0,
            ));


          }
      ),

    );
  }

  Widget tab1dummy() {
    return Container(
      color: appBgColor,
      child: Padding(
        padding: const EdgeInsets.only(top:8,left: 8,right: 8 ),
        child: Center(
          child: Text(
            'Export Boxes Not Found',
            style: TextStyle(fontSize: 22,color: appColor,fontFamily: "Poppins",
              fontWeight: FontWeight.w500,),
          ),
        ),
      ),
    );
  }

  Widget tab2() {
    return FutureBuilder(
          future: _resultGetExportTypeWiseBoxesData,
          builder: (context, snapshot)
          {
            if (snapshot.hasData)
            {
              return  Center(
                child: ListView.builder(
                  itemCount: getExportTypeWiseBoxesDataList.length,
                  itemBuilder: (context, index) {
                    if(getExportTypeWiseBoxesDataList[index]['isImport'] == 1){
                      return Padding(
                      padding: const EdgeInsets.only(right:3,left:3,top:3),
                      child: InkWell(
                        onTap: () async{
                          var connectivityResult = await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.none) {
                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                            Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                          }
                          else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                            String exportType_value = getExportTypeWiseBoxesDataList[index]["ExportType_value"].toString();
                            String exportType = getExportTypeWiseBoxesDataList[index]["ExportType"].toString();
                            String boxCount = getExportTypeWiseBoxesDataList[index]["BoxCount"].toString();

                            Navigator.push(context, SlideLeftRoute(page: BoxDetailsPage(exportType_value:exportType_value, exportType:exportType, boxCount:boxCount))).then((value){
                              if(value == "success"){
                                check();
                                _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                              }
                            });
                          }
                        },
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(top:1,bottom: 1),
                            child: ListTile(
                              leading:  Image.asset(
                                "assets/normalExport.png",width: 40,height: 40,
                              ),
                              title: Text(getExportTypeWiseBoxesDataList[index]["ExportType"], style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                              subtitle: Text("${getExportTypeWiseBoxesDataList[index]["BoxCount"].toString()} Boxes", style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                              trailing:CircleAvatar(
                                radius: 15,
                                backgroundColor: routePageColor.withOpacity(0.7),
                                child: IconButton(
                                    iconSize: 18,
                                    padding: const EdgeInsets.only(left:6,right: 8),
                                    icon: const Icon(Icons.navigate_next,color: Color(0xFF383182),),
                                    onPressed: () async {
                                      var connectivityResult = await (Connectivity().checkConnectivity());
                                      if (connectivityResult == ConnectivityResult.none) {
                                        print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                        Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                      }
                                      else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                        print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                        String exportType_value = getExportTypeWiseBoxesDataList[index]["ExportType_value"].toString();
                                        String exportType = getExportTypeWiseBoxesDataList[index]["ExportType"].toString();
                                        String boxCount = getExportTypeWiseBoxesDataList[index]["BoxCount"].toString();

                                        Navigator.push(context, SlideLeftRoute(page: BoxDetailsPage(exportType_value:exportType_value, exportType:exportType, boxCount:boxCount))).then((value){
                                          if(value == "success"){
                                            check();
                                            _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                                          }
                                        });
                                      }
                                    }),
                              ),
                              /*
                               Ink(width: 30,
                                decoration:
                                const ShapeDecoration(
                                    shape: CircleBorder(),
                                    color: Color(0xFFfef0ec)
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.navigate_next),
                                  iconSize: 20,
                                  color: Color(0xFF383182),
                                  onPressed: () {},
                                ),
                              )

                              CircleAvatar(
                                radius: 20,
                                backgroundColor: routePageColor,
                                child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(Icons.navigate_next,color: Color(0xFF383182),),
                                    onPressed: () {
                                      // do something
                                    }),
                              ),*/
                             /* Image.asset(
                                "assets/nextArrow.png",width: 30,height: 30,
                              ),*/
                            ),
                          ),
                        ),
                      ),
                    );
                 
                    }else{
                      return Container();
                    }
                  },
                ),
              );
            }
            else if (snapshot.hasError)
            {
              return Align(alignment: Alignment.center, child: Text(""));
            }

            return Center(child: SpinKitRotatingCircle(
              color: appColor,
              size: 30.0,
            ));


          }
      );
  }

  Widget tab3() {
    return FutureBuilder(
          future: _resultGetExportTypeWiseBoxesData,
          builder: (context, snapshot)
          {
            if (snapshot.hasData)
            {
              return  Center(
                child: ListView.builder(
                  itemCount: getExportTypeWiseBoxesDataList.length,
                  itemBuilder: (context, index) {
                    if(getExportTypeWiseBoxesDataList[index]['isImport'] == 2){
                      return Padding(
                      padding: const EdgeInsets.only(right:3,left:3,top:3),
                      child: InkWell(
                        onTap: () async{
                          var connectivityResult = await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.none) {
                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                            Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                          }
                          else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                            String exportType_value = getExportTypeWiseBoxesDataList[index]["ExportType_value"].toString();
                            String exportType = getExportTypeWiseBoxesDataList[index]["ExportType"].toString();
                            String boxCount = getExportTypeWiseBoxesDataList[index]["BoxCount"].toString();

                            Navigator.push(context, SlideLeftRoute(page: BoxDetailsPage(exportType_value:exportType_value, exportType:exportType, boxCount:boxCount))).then((value){
                              if(value == "success"){
                                check();
                                _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                              }
                            });
                          }
                        },
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.only(top:1,bottom: 1),
                            child: ListTile(
                              leading:  Image.asset(
                                "assets/normalExport.png",width: 40,height: 40,
                              ),
                              title: Text(getExportTypeWiseBoxesDataList[index]["ExportType"], style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                              subtitle: Text("${getExportTypeWiseBoxesDataList[index]["BoxCount"].toString()} Boxes", style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold,),),
                              trailing:CircleAvatar(
                                radius: 15,
                                backgroundColor: routePageColor.withOpacity(0.7),
                                child: IconButton(
                                    iconSize: 18,
                                    padding: const EdgeInsets.only(left:6,right: 8),
                                    icon: const Icon(Icons.navigate_next,color: Color(0xFF383182),),
                                    onPressed: () async {
                                      var connectivityResult = await (Connectivity().checkConnectivity());
                                      if (connectivityResult == ConnectivityResult.none) {
                                        print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                        Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                      }
                                      else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                        print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                        String exportType_value = getExportTypeWiseBoxesDataList[index]["ExportType_value"].toString();
                                        String exportType = getExportTypeWiseBoxesDataList[index]["ExportType"].toString();
                                        String boxCount = getExportTypeWiseBoxesDataList[index]["BoxCount"].toString();

                                        Navigator.push(context, SlideLeftRoute(page: BoxDetailsPage(exportType_value:exportType_value, exportType:exportType, boxCount:boxCount))).then((value){
                                          if(value == "success"){
                                            check();
                                            _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                                          }
                                        });
                                      }
                                    }),
                              ),
                              /*
                               Ink(width: 30,
                                decoration:
                                const ShapeDecoration(
                                    shape: CircleBorder(),
                                    color: Color(0xFFfef0ec)
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.navigate_next),
                                  iconSize: 20,
                                  color: Color(0xFF383182),
                                  onPressed: () {},
                                ),
                              )

                              CircleAvatar(
                                radius: 20,
                                backgroundColor: routePageColor,
                                child: IconButton(
                                    iconSize: 20,
                                    icon: const Icon(Icons.navigate_next,color: Color(0xFF383182),),
                                    onPressed: () {
                                      // do something
                                    }),
                              ),*/
                             /* Image.asset(
                                "assets/nextArrow.png",width: 30,height: 30,
                              ),*/
                            ),
                          ),
                        ),
                      ),
                    );
                 
                    }else{
                      return Container();
                    }
                  },
                ),
              );
            }
            else if (snapshot.hasError)
            {
              return Align(alignment: Alignment.center, child: Text(""));
            }

            return Center(child: SpinKitRotatingCircle(
              color: appColor,
              size: 30.0,
            ));


          }
      );
  }


  Widget child;

  Widget child1() {
    return Container(
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
              userName,
              style: TextStyle(color: Colors.black, fontFamily: "Poppins",
                  fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
  GlobalKey<LiquidPullToRefreshState>();

  static int refreshNum = 10; // number that changes when refreshed
  Stream<int> counterStream =
  Stream<int>.periodic(const Duration(seconds: 1), (x) => refreshNum);

  ScrollController _scrollController;

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
        check();
        _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Page Refreshed', style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white,letterSpacing: 0.1),),
        ),
      );
      // _resultGetBoxRouteDetailsData =  getBoxRouteDetails();
    });
  }

  Widget child2() {
    return LiquidPullToRefresh(
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
                topRight: Radius.circular(20),topLeft: Radius.circular(20),),  color: appBgColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top:30,right: 10, left: 10),
              child:DefaultTabController(
                length: 3,
                child: Scaffold(
                  key: _scaffoldKey,
                  resizeToAvoidBottomInset: false,
                  backgroundColor: appBgColor,
                  appBar: PreferredSize(
                    preferredSize: Size(double.infinity, 40),
                    child: AppBar(
                      backgroundColor: Color(0xfff7f7f7),elevation: 1,
                      automaticallyImplyLeading: false,
                       flexibleSpace: TabBar(
                        labelColor:  Colors.white,
                        unselectedLabelColor: Colors.black45,
                        isScrollable: false,
                        indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(2), // Creates border
                            color: appBtnColor), //Cha
                        tabs: [
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "EXPORTS",
                                style: TextStyle(fontSize: 22,fontFamily: "AlternateGothic",
                                    fontWeight: FontWeight.w500,letterSpacing: 1),
                              ),
                            ),
                          ),


                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "IMPORTS",
                                style: TextStyle(fontSize: 22,fontFamily: "AlternateGothic",
                                    fontWeight: FontWeight.w500,letterSpacing: 1),
                              ),
                            ),
                          ),
                          Tab(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "DTA",
                                style: TextStyle(fontSize: 22,fontFamily: "AlternateGothic",
                                    fontWeight: FontWeight.w500,letterSpacing: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      if (getExportTypeWiseBoxesListLenght == 0)
                      tab1dummy(),
                      if (getExportTypeWiseBoxesListLenght != 0)
                      tab1(),
                      tab2(),
                      tab3(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget child3() {
    return Container(
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
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Container(
              color: appColor,
              child: Padding(
                padding: const EdgeInsets.only(left:1, right:1, top:12, bottom:12),
                child: Text('Are you sure?',style: TextStyle(fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,fontSize: 18, color: Colors.white),textAlign:TextAlign.center ,),
              ),
            ),
            content: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text('You are going to exit the application!!', style: TextStyle(fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,fontSize: 16),),
            ),
            actions: <Widget>[

              TextButton(
                // color: Color(0xFF4938B4),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Yes',style: TextStyle(color: appColor,fontSize: 18, fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,),),
                ),
                onPressed: ()=> exit(0),

              ),
              TextButton(
                // color: Color(0xffd47fa6),
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



  String qrCodeResult = "";

  int index = 0;
  ValidateScanBoxDataModel _validateQRResult;
  String statusCode;
  Future<ValidateScanBoxDataModel> validateQR (String qrCodeResult) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      String _API_Path = _prefs.getString('API_Path');
      String _Token = _prefs.getString('Token');
      debugPrint('Check getBoxRouteDetails _API_Path $_API_Path ');
      debugPrint('Check getBoxRouteDetails _Token $_Token ');
      final String apiUrl = "$_API_Path/Dashboard/ValidateScanBox";
      debugPrint('Check validateQR qrCodeResult $qrCodeResult ');
      debugPrint('Check validateQR 1 ');
      debugPrint('Check validateQR apiUrl : $apiUrl ');


      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {HttpHeaders.acceptHeader: 'application/json', HttpHeaders.contentTypeHeader: 'application/json', 'x-access-token': _Token},
        body: json.encode(
            {
              "BoxQRCode": qrCodeResult,
            }),
      );
      debugPrint('Check validateQR 2');
      debugPrint('Check validateQR statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('Check validateQR 3');
        setState(() {
          statusCode = "200";
        });
        final String responseString = response.body;
        debugPrint('Check validateQR 4');
        debugPrint('Check validateQR responseString : $responseString');

        return validateScanBoxDataModelFromJson(responseString);
      }
      if (response.statusCode == 500) {
        setState(() {
          statusCode = "500";
        });
        final String responseString = response.body;
        debugPrint('Check mAuthenticate responseString $responseString ');
        return validateScanBoxDataModelFromJsonExe(responseString);
      }
      else {
        debugPrint('Check validateQR 5');

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Invalid Box', style: TextStyle(fontSize: 18,fontFamily: "Poppins",
        fontWeight: FontWeight.w500),));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  _displaySnackBarExe(BuildContext context, String exe) {
    final snackBar = SnackBar(
        content: Text(exe, style: TextStyle(fontSize: 18,fontFamily: "Poppins",
            fontWeight: FontWeight.w500),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    switch (selectedPos) {
      case 0:
        child = child1();
        break;
      case 1:
        child = child2();
        break;
      case 2:
        child = child3();
        break;
    }
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: appBgColor,
        appBar:
        PreferredSize(
          preferredSize: Size(double.infinity, 95),
          child: AppBar(
            backgroundColor: appbarColor,elevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(top:10),
                child: IconButton(
                  icon:  Image.asset(
                    "assets/drawer_ic.png",width: 30,height: 30,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            title:Padding(
              padding: const EdgeInsets.only(top:10),
              child: Text(
                "DASHBOARD", style: TextStyle(
                fontFamily: "AlternateGothic",
                fontWeight: FontWeight.w500,fontSize: 28,color: Colors.white,letterSpacing: 1),),
            ),
           actions: <Widget>[
              IconButton(
                icon:  Image.asset(
                  "assets/scanner.png",width: 30,height: 25,
                ),
                onPressed: () async{
                  await Permission.camera.request();
                  String codeSanner = await scanner.scan();
                  setState(() {
                    qrCodeResult = codeSanner.toString();
                  });
                  debugPrint('Check codeSanner === : $codeSanner');
                  if(codeSanner == null){
                    debugPrint('Check qrCodeResult ================= "": $qrCodeResult');
                  }
                  else if(codeSanner != null) {
                    debugPrint('Check qrCodeResult != "": $qrCodeResult');

                    final ValidateScanBoxDataModel validateQRresult = await validateQR(qrCodeResult);
                    debugPrint('2');

                    setState(() {
                      _validateQRResult = validateQRresult;
                    });
                    debugPrint('_validateQRResult : $_validateQRResult');

                    debugPrint('3');

                    if (validateQRresult == null) {
                      debugPrint('**');
                      _displaySnackBar(context);
                    }
                    else {
                      if(statusCode == "500"){
                        if (_validateQRResult.ExceptionMessage != "") {
                          debugPrint('statusCode : 500 *** ${_validateQRResult.ExceptionMessage}');

                          debugPrint('_displaySnackBarExe **');
                          String exe = _validateQRResult.ExceptionMessage;
                          _displaySnackBarExe(context, exe);
                          //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                        }
                      }
                      if(statusCode == "200"){
                        String Validate = "${_validateQRResult.Data[0].Validate.toString()}";

                        if(Validate == "1"){

                          String boxNo_Value = "${_validateQRResult.Data[0].BoxNo_Value.toString()}";
                          String boxNo = "${_validateQRResult.Data[0].BoxNo.toString()}";
                          String invoiceNo = "${_validateQRResult.Data[0].InvoiceNo.toString()}";
                          String custShortCode = "${_validateQRResult.Data[0].CustShortCode.toString()}";

                          debugPrint('boxNo_Value : $boxNo_Value');
                          debugPrint('boxNo : $boxNo');
                          debugPrint('invoiceNo : $invoiceNo');
                          debugPrint('custShortCode : $custShortCode');

                          Navigator.push(context, SlideLeftRoute(page: DirectScan_BoxRouteDetailsPage(boxNo_Value:boxNo_Value, boxNo:boxNo, invoiceNo:invoiceNo, custShortCode:custShortCode)));
                        }
                        if(Validate == "0"){
                          debugPrint('**');
                          String exe = "${_validateQRResult.Data[index].ScanMessage.toString()}";
                          _displaySnackBarExe(context,exe);
                        }

                      }
                      else{
                        debugPrint('**');
                        _displaySnackBar(context);
                      }

                    }

                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.search,size: 30,color: Colors.white,),
                onPressed: (){
                  Navigator.push(context, SlideLeftRoute(page: Search_BoxDetailsPage())).then((value){
                    if(value == "success"){
                      _resultGetExportTypeWiseBoxesData =  getExportTypeWiseBoxes();
                    }
                  });

                }
              ),
            ],

          ),),
        body: Stack(
          children: <Widget>[
            SizedBox(height: 5,),
            Padding(child: child, padding: EdgeInsets.only(bottom: bottomNavBarHeight),),
            Align(alignment: Alignment.bottomCenter, child: bottomNav())
          ],
        ),
        drawer: DrawerPage(),
      ),
    );
  }



  Widget bottomNav() {
    return CircularBottomNavigation(
      tabItems,
      controller: _navigationController,
      barHeight: bottomNavBarHeight,
      barBackgroundColor: Colors.white,
      normalIconColor: Colors.grey,circleSize: 70,iconsSize:30,
      selectedIconColor: Colors.black,
      animationDuration: Duration(milliseconds: 300),
      selectedCallback: (int selectedPos) {
        setState(() {
          this.selectedPos = selectedPos;
          print(_navigationController.value);
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
  }
}
