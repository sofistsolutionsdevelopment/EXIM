import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:exim/constant/colors.dart';
import 'package:exim/models/getBoxDetailsData_model.dart';
import 'package:exim/models/getBoxDetailsResult_model.dart';
import 'package:exim/screens/profile.dart';
import 'package:exim/screens/setting.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'boxRouteDetails.dart';
import 'dash.dart';
import 'directScan_boxRouteDetails.dart';
import 'noInternet.dart';

class Search_BoxDetailsPage extends StatefulWidget {
  final Function onPressed;


  Search_BoxDetailsPage({this.onPressed,});
  @override
  _Search_BoxDetailsPageState createState() => _Search_BoxDetailsPageState();
}

class _Search_BoxDetailsPageState extends State<Search_BoxDetailsPage> {

  String _search = "-";
  TextEditingController searchController = TextEditingController();

  int getBoxDetailsListLenght;
  Map Json;
  List getBoxDetailsDataList = List();
  List<GetBoxDetailsResultModel> _resultGetBoxDetailsResult;
  Future<GetBoxDetailsDataModel> _resultGetBoxDetailsData;
  Future<GetBoxDetailsDataModel> getBoxDetails (String _search) async{
    print("Api getBoxDetails 1.........");
    try{
      print("Api getBoxDetails 1");
      final _prefs = await SharedPreferences.getInstance();
      String _API_Path = _prefs.getString('API_Path');
      String _Token = _prefs.getString('Token');
      debugPrint('Check getBoxDetails _API_Path $_API_Path ');
      debugPrint('Check getBoxDetails _Token $_Token ');
      debugPrint("_search : $_search");

      final String apiUrl = "$_API_Path/Dashboard/GetBoxDetailsForSearch";

      print("Api getBoxDetails 2");
      print("Api getBoxDetails _Token : $_Token");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {HttpHeaders.ACCEPT: 'application/json', HttpHeaders.contentTypeHeader: 'application/json', 'x-access-token': _Token},
        body: json.encode({
          "SearchValue": _search
        }),
      );

      print("Api getBoxDetails 3");

      print("Api getBoxDetails response code : ${response.statusCode}");

      if(response.statusCode == 200){

        print("Api getBoxDetails 4");

        final String responseString = response.body;

        Json = json.decode(responseString);
        debugPrint('Api getBoxDetails 6 Json ${Json}');

        getBoxDetailsDataList = Json["Data"];
        setState(() {
          getBoxDetailsListLenght = getBoxDetailsDataList.length;

          _resultGetBoxDetailsResult = Json["Data"].map<GetBoxDetailsResultModel>((e) => GetBoxDetailsResultModel.fromJson(e)).toList();
        });


        return getBoxDetailsDataModelFromJson(responseString);
      }
      else{
        print("Api getBoxDetails 7");
        return null;
      }
    }
    catch (e) {
      print("Api getBoxDetails 8");

      print(e);
      return null;
    }
  }

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

    }
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
        _search = "-";
        _resultGetBoxDetailsData =  getBoxDetails(_search);
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: const Text('Page Refreshed', style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,fontSize: 16,color: Colors.white,letterSpacing: 0.1),),
        ),
      );
      // _resultGetBoxRouteDetailsData =  getBoxRouteDetails();
    });
  }

  @override
  void initState() {
    check();
    _resultGetBoxDetailsData =  getBoxDetails(_search);
    _scrollController = ScrollController();
    super.initState();
  }

  void rebuildPage() {
    setState(() {});
  }
  double percentage;


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
        resizeToAvoidBottomPadding: false,
        backgroundColor: appBgColor,
        key: _scaffoldKey,
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
            title: Text(
              "", style: TextStyle(
                fontFamily: "AlternateGothic",
                fontWeight: FontWeight.w500,fontSize: 28,color: Colors.white,letterSpacing: 1),),
          ),),

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
                    topRight: Radius.circular(20),topLeft: Radius.circular(20),
                  ),color: appBgColor,
                ),
               child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    if (getBoxDetailsListLenght == 0)
                      Center(
                        child: Text(
                          'Boxes Details Not Found',
                          style: TextStyle(fontSize: 22,color: appColor,fontFamily: "Poppins",
                            fontWeight: FontWeight.w500,),
                        ),
                      ),
                    if (getBoxDetailsListLenght != 0)
                      SizedBox(height: 15,),
                    if (getBoxDetailsListLenght != 0)
                      Padding(
                        padding: const EdgeInsets.only(right:15, left:15),
                        child: TextField(
                          controller: searchController,
                          style: TextStyle(fontFamily: "Rubik",color: Colors.black,
                              fontWeight: FontWeight.w500,fontSize: 16),
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            hintText: "Search",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontFamily: "Rubik",
                                fontWeight: FontWeight.w500,fontSize: 14
                            ),

                              suffixIcon: InkWell(
                                    onTap: ()async{

                                      setState(() {
                                        _search = searchController.text.toString().trim();
                                        print("_search : $_search");
                                        _resultGetBoxDetailsData =  getBoxDetails(_search);
                                        _scrollController = ScrollController();
                                      });
                                      FocusScope.of(context).requestFocus(FocusNode());
                                    },
                                    child:IconButton(
                                      icon: new Icon(Icons.search),
                                      tooltip: 'Search',
                                    ),
                                  ),
                          ),
                          /* onSubmitted: (value) async{
                                setState(() {
                                  DateTime today = DateTime.now();
                                  _from = DateFormat('dd/MM/yyyy').format(today);
                                  _to = DateFormat('dd/MM/yyyy').format(today);
                                  String operation = "S";
                                  _stage = editingController.text.toString().trim();
                                  print("_stage : $_stage");
                                  _resultFollowUps = getFollowUps(_stage, operation, _from, _to);
                                });
                                FocusScope.of(context).requestFocus(FocusNode());
                            },*/
                          textInputAction: TextInputAction.search,

                        ),
                      ),
                    if (getBoxDetailsListLenght != 0)
                      SizedBox(height: 15,),
                    if (getBoxDetailsListLenght != 0)
                      Expanded(
                        child: FutureBuilder(
                            future: _resultGetBoxDetailsData,
                            builder: (context, snapshot)
                            {
                              if (snapshot.hasData)
                              {
                                return  ListView.builder(
                                  itemCount: getBoxDetailsDataList.length,
                                  itemBuilder: (context, index) {
                                    percentage = getBoxDetailsDataList[index]["RoutePerc"]/100;
                                    return Padding(
                                      padding: const EdgeInsets.only(top:0.0),
                                      child: InkWell(
                                        onTap: () async{
                                          var connectivityResult = await (Connectivity().checkConnectivity());
                                          if (connectivityResult == ConnectivityResult.none) {
                                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                            Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                          }
                                          else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                            print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                            String exportType_value = getBoxDetailsDataList[index]["ExportType_value"].toString();
                                            String exportType = getBoxDetailsDataList[index]["ExportType"].toString();
                                            String boxNo_Value = getBoxDetailsDataList[index]["BoxNo_value"].toString();
                                            String boxNo = getBoxDetailsDataList[index]["BoxNo"].toString();
                                            String invoiceNo = getBoxDetailsDataList[index]["InvoiceNo"].toString();
                                            String custShortCode = getBoxDetailsDataList[index]["CustShortCode"].toString();
                                           // String boxCount = widget.boxCount;
                                            Navigator.push(context, SlideLeftRoute(page: DirectScan_BoxRouteDetailsPage(boxNo_Value:boxNo_Value, boxNo:boxNo, invoiceNo:invoiceNo, custShortCode:custShortCode)));

                                          }
                                        },
                                        child:   Card(
                                        color: Colors.white,
                                        child:Padding(
                                          padding: const EdgeInsets.only(top:0,bottom: 2),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffe2e4f2)),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: <Widget>[
                                                        Text(getBoxDetailsDataList[index]["CustShortCode"], style:TextStyle(fontSize: 13, fontFamily: "Poppins",
                                                            fontWeight: FontWeight.w500,color: Colors.black),),
                                                        Text(getBoxDetailsDataList[index]["InvoiceNo"], style:TextStyle(fontSize: 13, fontFamily: "Poppins",
                                                            fontWeight: FontWeight.w500,color: Colors.black),),
                                                      ],
                                                    ),
                                                  )
                                              ),

                                              ListTile(
                                                leading:  Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      "assets/boxes.png",width: 40,height: 40,
                                                    ),
                                                    Image.asset(
                                                      "assets/verticalLine.png",width: 20,height: 45,
                                                    ),
                                                  ],
                                                ),
                                                title:   Column(  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(getBoxDetailsDataList[index]["BoxNo"], style:TextStyle(fontSize: 16,  fontFamily: "Poppins",
                                                        fontWeight: FontWeight.w500,color: appColor),),
                                                    Text(getBoxDetailsDataList[index]["StepCaption"], style:TextStyle(fontSize: 14,  fontFamily: "Poppins",
                                                        fontWeight: FontWeight.w500,color: appBtnColor),),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(getBoxDetailsDataList[index]["RouteDate"], style:TextStyle(fontSize: 12, fontFamily: "Poppins",
                                                        fontWeight: FontWeight.w500,color: Colors.black45),),
                                                    Text(getBoxDetailsDataList[index]["RouteTime"], style:TextStyle(fontSize: 12, fontFamily: "Poppins",
                                                        fontWeight: FontWeight.w500,color: Colors.black45),),
                                                  ],
                                                ),

                                                trailing:  Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      "assets/verticalLine.png",width: 20,height: 45,
                                                    ),
                                                    if(getBoxDetailsDataList[index]["RoutePerc"] == 100)
                                                      Image.asset(
                                                        "assets/100.png",width: 40,height: 40,
                                                      ),
                                                    if(getBoxDetailsDataList[index]["RoutePerc"] != 100)
                                                      CircularPercentIndicator(
                                                        radius: 45,
                                                        lineWidth: 2,
                                                        animation: true,
                                                        percent: percentage,
                                                        center:  Image.asset(
                                                          "assets/0.png",width: 25,height: 25,
                                                        ),
                                                        backgroundColor: Colors.grey[300],
                                                        circularStrokeCap: CircularStrokeCap.round,
                                                        progressColor: appBtnColor,
                                                      )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ),
                                    );
                                  },
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
                      ),
                  ],),),),
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
                        child: Icon(Icons.settings, color: Colors.grey,size: 30,),
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
