import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:exim/models/getDDLFailureReasonsData_model.dart';
import 'package:exim/models/getDDLFailureReasonsResult_model.dart';
import 'package:exim/models/saveData_model.dart';
import 'package:exim/models/validateScanBoxData_model.dart';
import 'package:exim/screens/profile.dart';
import 'package:exim/screens/setting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:connectivity/connectivity.dart';
import 'package:exim/constant/colors.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:exim/models/getBoxRouteDetailsData_model.dart';
import 'package:exim/models/getBoxRouteDetailsResult_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dash.dart';
import 'noInternet.dart';

class DirectScan_BoxRouteDetailsPage extends StatefulWidget {
  final Function onPressed;
  final String boxNo_Value;
  final String boxNo;
  final String invoiceNo;
  final String custShortCode;

  DirectScan_BoxRouteDetailsPage(
      {this.onPressed,
      this.boxNo_Value,
      this.boxNo,
      this.invoiceNo,
      this.custShortCode});

  @override
  _DirectScan_BoxRouteDetailsPageState createState() =>
      _DirectScan_BoxRouteDetailsPageState();
}

class _DirectScan_BoxRouteDetailsPageState
    extends State<DirectScan_BoxRouteDetailsPage> {
  int getBoxRouteDetailsListLenght;
  Map RouteJson;
  List getBoxRouteDetailsDataList = List();
  List<GetBoxRouteDetailsResultModel> _resultGetBoxRouteDetailsResult;
  Future<GetBoxRouteDetailsDataModel> _resultGetBoxRouteDetailsData;
  Future<GetBoxRouteDetailsDataModel> getBoxRouteDetails() async {
    print("Api getBoxRouteDetails 1.........");
    try {
      print("Api getBoxRouteDetails 1");
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint('Check getBoxRouteDetails _API_Path $APIPath ');
      debugPrint('Check getBoxRouteDetails _Token $Token ');

      final String apiUrl = "$APIPath/Dashboard/GetBoxRouteDetails";

      print("Api getBoxRouteDetails 2");
      print("Api getBoxRouteDetails _Token : $Token");
      print(
          "Api getBoxRouteDetails  widget.boxNo_Value : ${widget.boxNo_Value}");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({
          "BoxNo_Value": widget.boxNo_Value,
        }),
      );

      print("Api getBoxRouteDetails 3");

      print("Api getBoxDetails response code : ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Api getBoxDetails 4");

        final String responseString = response.body;

        RouteJson = json.decode(responseString);
        debugPrint('Api getBoxRouteDetails 6 RouteJson $RouteJson');

        getBoxRouteDetailsDataList = RouteJson["Data"];
        setState(() {
          getBoxRouteDetailsListLenght = getBoxRouteDetailsDataList.length;

          _resultGetBoxRouteDetailsResult = RouteJson["Data"]
              .map<GetBoxRouteDetailsResultModel>(
                  (e) => GetBoxRouteDetailsResultModel.fromJson(e))
              .toList();
        });

        return getBoxRouteDetailsDataModelFromJson(responseString);
      } else {
        print("Api getBoxRouteDetails 7");
        return null;
      }
    } catch (e) {
      print("Api getBoxRouteDetails 8");

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
    } else if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      print("*** _isConnected Dash page Load = $connectivityResult ****");
    }
  }

  String qrCodeResult = "";
  String confirmValue;
  String logicalValue;
  String valueText;
  String _inputValue;
  final TextEditingController _controllerInputValue =
      new TextEditingController();

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
        _resultGetBoxRouteDetailsData = getBoxRouteDetails();
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

  @override
  void initState() {
    check();
    _resultGetBoxRouteDetailsData = getBoxRouteDetails();
    _scrollController = ScrollController();
    super.initState();
  }

  void rebuildPage() {
    setState(() {});
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _displaySnackBarInputValue(BuildContext context) {
    final snackBar = SnackBar(
        content: Text(
      'Enter AWB Number',
      style: TextStyle(fontSize: 18),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool swipeRight = false;
  bool swipeLeft = false;

  int index = 0;
  ValidateScanBoxDataModel _validateQRResult;
  String statusCode;
  Future<ValidateScanBoxDataModel> validateQR(String qrCodeResult) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint('Check getBoxRouteDetails _API_Path $APIPath ');
      debugPrint('Check getBoxRouteDetails _Token $Token ');
      final String apiUrl = "$APIPath/Dashboard/ValidateScanBox";
      debugPrint('Check validateQR qrCodeResult $qrCodeResult ');
      debugPrint('Check validateQR 1 ');
      debugPrint('Check validateQR apiUrl : $apiUrl ');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({
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
      } else {
        debugPrint('Check validateQR 5');

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  int saveIndex = 0;
  SaveDataModel _saveResult;
  String saveStatusCode;
  Future<SaveDataModel> save(
      String routeCode,
      String boxNoValue,
      String stepCode,
      String inputValue,
      String inputDDLValue,
      String compCode) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint('Check save _API_Path $APIPath ');
      debugPrint('Check save _Token $Token ');
      final String apiUrl = "$APIPath/Dashboard/SaveBoxDetails";
      debugPrint('Check save 1 ');
      debugPrint('Check save apiUrl : $apiUrl ');
      debugPrint('Check save routeCode : $routeCode');
      debugPrint('Check save stepCode : $stepCode ');
      debugPrint('Check save inputValue : $inputValue ');
      debugPrint('Check save compCode : $compCode ');
      debugPrint('Check save boxNo_Value : ${widget.boxNo_Value} ');
      debugPrint('Check save inputDDLValue : $inputDDLValue ');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({
          "@RouteCode": routeCode,
          "@BoxNo_value": widget.boxNo_Value,
          "@stepCode": stepCode,
          "@InputValue": inputValue,
          "@InputDDLValue": inputDDLValue,
          "@CompCode": compCode
        }),
      );
      debugPrint('Check save 2');
      debugPrint('Check save statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('Check save 3');
        setState(() {
          statusCode = "200";
        });
        final String responseString = response.body;
        debugPrint('Check save 4');
        debugPrint('Check save responseString : $responseString');

        return saveModelFromJson(responseString);
      }
      if (response.statusCode == 500) {
        setState(() {
          statusCode = "500";
        });
        final String responseString = response.body;
        debugPrint('Check mAuthenticate responseString $responseString ');
        return saveDataModelFromJsonExe(responseString);
      } else {
        debugPrint('Check save 5');

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _qrScanSuccess(
      BuildContext context,
      String routeCode,
      String boxNoValue,
      String stepCode,
      String inputDDLValue,
      String compCode) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Enter AWB Number Below',
              style: TextStyle(
                  fontFamily: "AlternateGothic",
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                  letterSpacing: 1,
                  color: appColor),
            ),
            content: TextFormField(
              textAlign: TextAlign.center,
              controller: _controllerInputValue,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              decoration: InputDecoration(
                fillColor: appBgColor,
                filled: true,
                counterText: "",
                border: InputBorder.none,
                hintText: "",
                hintStyle: TextStyle(
                    fontFamily: "AlternateGothic",
                    fontWeight: FontWeight.w500,
                    fontSize: 26,
                    letterSpacing: 2),
              ),
              style: TextStyle(
                  fontFamily: "AlternateGothic",
                  fontWeight: FontWeight.w500,
                  fontSize: 26,
                  letterSpacing: 2,
                  color: appColor),
              //  textInputAction: TextInputAction.search,
            ),
            actions: <Widget>[
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.red,
                    ),
                    textStyle: MaterialStateProperty.all(TextStyle(
                      color: Colors.white,
                    )),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    )),
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    fontFamily: "AlternateGothic",
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              SizedBox(
                width: 40,
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Colors.green,
                    ),
                    textStyle: MaterialStateProperty.all(
                        TextStyle(color: Colors.white)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    )),
                child: Text(
                  'SAVE',
                  style: TextStyle(
                    fontFamily: "AlternateGothic",
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () async {
                  if (_controllerInputValue.text == "") {
                    _controllerInputValue.clear();
                    _displaySnackBarInputValue(context);
                  } else {
                    setState(() {
                      _inputValue = _controllerInputValue.text;
                      print(
                          "_controllerInputValue : ${_controllerInputValue.text}");
                      print("_inputValue : $_inputValue");

                      String inputValue = _inputValue;

                      debugPrint('_qrScanSuccess routeCode : $routeCode');
                      debugPrint('_qrScanSuccess boxNo_value : $boxNoValue');
                      debugPrint('_qrScanSuccess stepCode : $stepCode');
                      debugPrint('_qrScanSuccess inputValue : $inputValue');
                      debugPrint(
                          '_qrScanSuccess inputDDLValue : $inputDDLValue');
                      debugPrint('_qrScanSuccess compCode : $compCode');
                    });

                    final SaveDataModel saveresult = await save(
                        routeCode,
                        boxNoValue,
                        stepCode,
                        _inputValue,
                        inputDDLValue,
                        compCode);
                    debugPrint('2');

                    setState(() {
                      _saveResult = saveresult;
                    });
                    debugPrint('saveresult : $saveresult');

                    debugPrint('_saveResult : $_saveResult');

                    debugPrint('3');

                    if (saveresult == null) {
                      debugPrint('**');
                      Navigator.pop(context);
                      _displaySnackBar(context);
                    } else {
                      if (statusCode == "500") {
                        if (_saveResult.ExceptionMessage != "") {
                          debugPrint(
                              'statusCode : 500 *** ${_saveResult.ExceptionMessage}');

                          debugPrint('_displaySnackBarExe **');
                          String exe = _saveResult.ExceptionMessage;
                          _displaySnackBarExe(context, exe);
                          _controllerInputValue.clear();
                          Navigator.pop(context);
                          //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                        }
                      }
                      if (statusCode == "200") {
                        _controllerInputValue.clear();
                        Navigator.pop(context);
                        _resultGetBoxRouteDetailsData = getBoxRouteDetails();
                      }
                    }
                  }
                },
              ),
            ],
          );
        });
  }

  int getDDLFailureReasonsListLenght;
  Map getDDLFailureReasonsJson;
  List getDDLFailureReasonsDataList = List();
  List<GetDDLFailureReasonsResultModel> _resultGetDDLFailureReasonsResult;
  Future<GetDDLFailureReasonsDataModel> _resultGetDDLFailureReasonsData;
  Future<GetDDLFailureReasonsDataModel> getDDL() async {
    print("Api getDDL 1.........");
    try {
      print("Api getDDL 1");
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint('Check getDDL _API_Path $APIPath ');
      debugPrint('Check getDDL _Token $Token ');

      final String apiUrl = "$APIPath/Dashboard/GetDDLFailureReasons";

      print("Api getDDL 2");
      print("Api getDDL _Token : $Token");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({}),
      );

      print("Api getDDL 3");

      print("Api getDDL response code : ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Api getDDL 4");

        final String responseString = response.body;

        getDDLFailureReasonsJson = json.decode(responseString);
        debugPrint(
            'Api getDDL 6 getDDLFailureReasonsJson $getDDLFailureReasonsJson');

        getDDLFailureReasonsDataList = getDDLFailureReasonsJson["Data"];
        setState(() {
          getDDLFailureReasonsListLenght = getDDLFailureReasonsDataList.length;

          _resultGetDDLFailureReasonsResult = getDDLFailureReasonsJson["Data"]
              .map<GetDDLFailureReasonsResultModel>(
                  (e) => GetDDLFailureReasonsResultModel.fromJson(e))
              .toList();
        });

        return getDDLFailureReasonsDataModelFromJson(responseString);
      } else {
        print("Api getDDL 7");
        return null;
      }
    } catch (e) {
      print("Api getDDL 8");

      print(e);
      return null;
    }
  }

  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(
        content: Text(
      'Invalid Box',
      style: TextStyle(
          fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w500),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _displaySnackBarExe(BuildContext context, String exe) {
    final snackBar = SnackBar(
        content: Text(
      exe,
      style: TextStyle(
          fontSize: 18, fontFamily: "Poppins", fontWeight: FontWeight.w500),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> AlertToSave(String routeCode, String boxNoValue, String stepCode,
      String inputValue, String inputDDLValue, String compCode) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              color: appColor,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 1, right: 1, top: 12, bottom: 12),
                child: Text(
                  'EXIM',
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            content: Text(
              'Do you want to save?',
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                  fontSize: 18),
            ),
            actions: <Widget>[
              TextButton(
                  // color: Color(0xFF4938B4),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: appColor,
                        fontSize: 18,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final SaveDataModel saveresult = await save(
                        routeCode,
                        boxNoValue,
                        stepCode,
                        inputValue,
                        inputDDLValue,
                        compCode);
                    debugPrint('2');

                    setState(() {
                      _saveResult = saveresult;
                    });
                    debugPrint('saveresult : $saveresult');

                    debugPrint('_saveResult : $_saveResult');

                    debugPrint('3');

                    if (saveresult == null) {
                      debugPrint('**');
                      _displaySnackBar(context);
                      setState(() {
                        swipeLeft = false;
                        swipeRight = false;
                      });
                      _resultGetBoxRouteDetailsData = getBoxRouteDetails();
                      Navigator.of(context).pop();
                    } else {
                      if (statusCode == "500") {
                        if (_saveResult.ExceptionMessage != "") {
                          debugPrint(
                              'statusCode : 500 *** ${_saveResult.ExceptionMessage}');

                          debugPrint('_displaySnackBarExe **');
                          String exe = _saveResult.ExceptionMessage;
                          _displaySnackBarExe(context, exe);
                          setState(() {
                            swipeLeft = false;
                            swipeRight = false;
                          });
                          _resultGetBoxRouteDetailsData = getBoxRouteDetails();
                          Navigator.of(context).pop();
                          //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                        }
                      }
                      if (statusCode == "200") {
                        setState(() {
                          swipeLeft = false;
                          swipeRight = false;
                        });
                        _resultGetBoxRouteDetailsData = getBoxRouteDetails();
                        Navigator.of(context).pop();
                      }
                    }
                  }),
              TextButton(
                // color: Color(0xffd47fa6),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: appColor,
                      fontSize: 18,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    swipeLeft = false;
                    swipeRight = false;
                  });
                  _resultGetBoxRouteDetailsData = getBoxRouteDetails();
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        });
  }

  bool IsScanRequired;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushReplacement(new MaterialPageRoute(
            builder: (context) => DashPage(onPressed: rebuildPage)));
        return new Future(
            () => false); //onWillPop is Future<bool> so return false
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: appBgColor,
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
                  Navigator.of(context).pushReplacement(new MaterialPageRoute(
                      builder: (context) => DashPage(onPressed: rebuildPage)));
                },
              ),
            ),
            title: Text(
              "",
              style: TextStyle(
                  fontFamily: "AlternateGothic",
                  fontWeight: FontWeight.w500,
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 1),
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
                      if (getBoxRouteDetailsListLenght == 0)
                        Center(
                          child: Text(
                            'Boxes Route Details Not Found',
                            style: TextStyle(
                              fontSize: 20,
                              color: appColor,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (getBoxRouteDetailsListLenght != 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Container(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 18,
                                          bottom: 18,
                                          right: 5,
                                          left: 5),
                                      child: Text(
                                        "Box No ",
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 22,
                                            letterSpacing: 1),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                //SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                Container(
                                    width: MediaQuery.of(context).size.width,
                                    color: routePageColor,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 18,
                                          bottom: 18,
                                          right: 5,
                                          left: 20),
                                      child: Text(
                                        "${widget.boxNo}",
                                        style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 22,
                                            letterSpacing: 1,
                                            color: appColor),
                                        textAlign: TextAlign.left,
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      if (getBoxRouteDetailsListLenght != 0)
                        SizedBox(
                          height: 10,
                        ),
                      if (getBoxRouteDetailsListLenght != 0)
                        Expanded(
                          child: FutureBuilder(
                              future: _resultGetBoxRouteDetailsData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Center(
                                    child: ListView.builder(
                                      itemCount:
                                          getBoxRouteDetailsDataList.length,
                                      itemBuilder: (context, index) {
                                        IsScanRequired =
                                            getBoxRouteDetailsDataList[index]
                                                ["IsScanRequired"];

                                        print(getBoxRouteDetailsDataList[index]
                                            ["IsScanRequired"]);
                                        print(
                                            "IsScanRequired ********************** $IsScanRequired");

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Confirm" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    false) //// This is for Confirm FALSE
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: InkWell(
                                                  onTap: () async {
                                                    var connectivityResult =
                                                        await (Connectivity()
                                                            .checkConnectivity());
                                                    if (connectivityResult ==
                                                        ConnectivityResult
                                                            .none) {
                                                      print(
                                                          "*** _isConnected Box Route Details = $connectivityResult ****");
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
                                                          "*** _isConnected Box Route Details = $connectivityResult ****");
                                                      //// String exportType_value = getBoxRouteDetailsDataList[index]["ExportType_value"].toString();
                                                      // String exportType = getBoxRouteDetailsDataList[index]["ExportType"].toString();
                                                      // String boxNo_Value = getBoxRouteDetailsDataList[index]["BoxNo_Value"].toString();

                                                      print(
                                                          getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"]);
                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"] ==
                                                          true) {
                                                        await Permission.camera
                                                            .request();
                                                        String codeSanner =
                                                            await scanner
                                                                .scan();
                                                        setState(() {
                                                          qrCodeResult =
                                                              codeSanner
                                                                  .toString();
                                                        });
                                                        debugPrint(
                                                            'Check codeSanner === : $codeSanner');
                                                        if (codeSanner ==
                                                            null) {
                                                          debugPrint(
                                                              'Check qrCodeResult ================= "": $qrCodeResult');
                                                        } else if (codeSanner !=
                                                            null) {
                                                          debugPrint(
                                                              'Check qrCodeResult != "": $qrCodeResult');

                                                          final ValidateScanBoxDataModel
                                                              validateQRresult =
                                                              await validateQR(
                                                                  qrCodeResult);
                                                          debugPrint('2');

                                                          setState(() {
                                                            _validateQRResult =
                                                                validateQRresult;
                                                          });
                                                          debugPrint(
                                                              '_validateQRResult : $_validateQRResult');

                                                          debugPrint('3');

                                                          if (validateQRresult ==
                                                              null) {
                                                            debugPrint('**');
                                                            _displaySnackBar(
                                                                context);
                                                          } else {
                                                            if (statusCode ==
                                                                "500") {
                                                              if (_validateQRResult
                                                                      .ExceptionMessage !=
                                                                  "") {
                                                                debugPrint(
                                                                    'statusCode : 500 *** ${_validateQRResult.ExceptionMessage}');

                                                                debugPrint(
                                                                    '_displaySnackBarExe **');
                                                                String exe =
                                                                    _validateQRResult
                                                                        .ExceptionMessage;
                                                                _displaySnackBarExe(
                                                                    context,
                                                                    exe);
                                                                //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                                                              }
                                                            }
                                                            if (statusCode ==
                                                                "200") {
                                                              String Validate =
                                                                  "${_validateQRResult.Data[0].Validate.toString()}";

                                                              if (Validate ==
                                                                  "1") {
                                                                String
                                                                    routeCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "RouteCode"]
                                                                        .toString();
                                                                String
                                                                    boxNoValue =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "BoxNo_value"]
                                                                        .toString();
                                                                String
                                                                    stepCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "StepCode"]
                                                                        .toString();
                                                                String
                                                                    inputValue =
                                                                    "Yes";
                                                                String
                                                                    inputDDLValue =
                                                                    "";
                                                                String
                                                                    compCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "CompCode"]
                                                                        .toString();

                                                                debugPrint(
                                                                    'routeCode : $routeCode');
                                                                debugPrint(
                                                                    'boxNo_value : $boxNoValue');
                                                                debugPrint(
                                                                    'stepCode : $stepCode');
                                                                debugPrint(
                                                                    'inputValue : $inputValue');
                                                                debugPrint(
                                                                    'inputDDLValue : $inputDDLValue');

                                                                AlertToSave(
                                                                    routeCode,
                                                                    boxNoValue,
                                                                    stepCode,
                                                                    inputValue,
                                                                    inputDDLValue,
                                                                    compCode);
                                                              }
                                                              if (Validate ==
                                                                  "0") {
                                                                debugPrint(
                                                                    '**');
                                                                _displaySnackBar(
                                                                    context);
                                                              }
                                                            } else {
                                                              debugPrint('**');
                                                              _displaySnackBar(
                                                                  context);
                                                            }
                                                          }
                                                        }
                                                      }

                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"] ==
                                                          false) {
                                                        String routeCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "RouteCode"]
                                                                .toString();
                                                        String boxNoValue =
                                                            getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "BoxNo_value"]
                                                                .toString();
                                                        String stepCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index]
                                                                    ["StepCode"]
                                                                .toString();
                                                        String inputValue =
                                                            "Yes";
                                                        String inputDDLValue =
                                                            "";
                                                        String compCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index]
                                                                    ["CompCode"]
                                                                .toString();

                                                        debugPrint(
                                                            'routeCode : $routeCode');
                                                        debugPrint(
                                                            'boxNo_value : $boxNoValue');
                                                        debugPrint(
                                                            'stepCode : $stepCode');
                                                        debugPrint(
                                                            'inputValue : $inputValue');
                                                        debugPrint(
                                                            'inputDDLValue : $inputDDLValue');

                                                        AlertToSave(
                                                            routeCode,
                                                            boxNoValue,
                                                            stepCode,
                                                            inputValue,
                                                            inputDDLValue,
                                                            compCode);
                                                      }
                                                    }
                                                  },
                                                  child: Card(
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color(
                                                                        0xffe2e4f2)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    widget
                                                                        .custShortCode,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                        .invoiceNo,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                        ListTile(
                                                          title: Text(
                                                            //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                            getBoxRouteDetailsDataList[
                                                                    index]
                                                                ["StepCaption"],
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    appColor),
                                                          ),
                                                          subtitle: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Text(
                                                                //"21-2-2022",
                                                                getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "RouteDate"],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        "Poppins",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black45),
                                                              ),
                                                              SizedBox(
                                                                width: 100,
                                                              ),
                                                              Text(
                                                                //"10:30 AM",
                                                                getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "RouteTime"],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        "Poppins",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black45),
                                                              ),
                                                            ],
                                                          ),
                                                          trailing: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Image.asset(
                                                                "assets/verticalLine.png",
                                                                width: 20,
                                                                height: 45,
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Image.asset(
                                                                "assets/-0.png",
                                                                width: 40,
                                                                height: 40,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        /* if (getBoxRouteDetailsDataList[
                                                                    index][
                                                                "ProcessingTime"] !=
                                                            null)
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                        if (getBoxRouteDetailsDataList[
                                                                    index][
                                                                "ProcessingTime"] !=
                                                            null)
                                                          Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color:
                                                                          routePageColor),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child: Center(
                                                                  child: Text(
                                                                    "Processing Timing ${getBoxRouteDetailsDataList[index]["ProcessingTime"].toString()} mins",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .redAccent),
                                                                  ),
                                                                ),
                                                              )) */
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Confirm" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    true) //// This is for Confirm TRUE
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: Card(
                                                  color: Colors.white,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Color(
                                                                      0xffe2e4f2)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  widget
                                                                      .custShortCode,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Text(
                                                                  widget
                                                                      .invoiceNo,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                      ListTile(
                                                        title: Text(
                                                          //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                          getBoxRouteDetailsDataList[
                                                                  index]
                                                              ["StepCaption"],
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  "Poppins",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: appColor),
                                                        ),
                                                        subtitle: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              //'"21-2-2022",
                                                              getBoxRouteDetailsDataList[
                                                                      index]
                                                                  ["RouteDate"],
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black45),
                                                            ),
                                                            SizedBox(
                                                              width: 100,
                                                            ),
                                                            Text(
                                                              //"10:30 AM",
                                                              getBoxRouteDetailsDataList[
                                                                      index]
                                                                  ["RouteTime"],
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black45),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Image.asset(
                                                              "assets/verticalLine.png",
                                                              width: 20,
                                                              height: 45,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Image.asset(
                                                              "assets/100.png",
                                                              width: 40,
                                                              height: 40,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "ProcessingTime"] !=
                                                          null)
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "ProcessingTime"] !=
                                                          null)
                                                        Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color:
                                                                        routePageColor),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Center(
                                                                child: Text(
                                                                  "Processing Timing ${getBoxRouteDetailsDataList[index]["ProcessingTime"].toString()} mins",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .redAccent),
                                                                ),
                                                              ),
                                                            ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Logical" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    false) //// This is for Logical
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    color: Colors.white,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color(
                                                                        0xffe2e4f2)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    widget
                                                                        .custShortCode,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                        .invoiceNo,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                        Slidable(
                                                          actionPane:
                                                              SlidableDrawerActionPane(),
                                                          actionExtentRatio:
                                                              0.25,
                                                          child: Container(
                                                            color: Colors.white,
                                                            child: ListTile(
                                                              leading: Icon(
                                                                Icons
                                                                    .navigate_before,
                                                                size: 25,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                              title: Text(
                                                                //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                                getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "StepCaption"],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        "Poppins",
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color:
                                                                        appColor),
                                                              ),
                                                              subtitle: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    //"21-2-2022",
                                                                    getBoxRouteDetailsDataList[
                                                                            index]
                                                                        [
                                                                        "RouteDate"],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black45),
                                                                  ),
                                                                  Text(
                                                                    //"10:30 AM",
                                                                    getBoxRouteDetailsDataList[
                                                                            index]
                                                                        [
                                                                        "RouteTime"],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black45),
                                                                  ),
                                                                ],
                                                              ),
                                                              trailing: Icon(
                                                                Icons
                                                                    .navigate_next,
                                                                size: 25,
                                                                color: Colors
                                                                    .black54,
                                                              ),
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            InkWell(
                                                              child:
                                                                  Image.asset(
                                                                "assets/green.png",
                                                              ),
                                                              onTap: () async {
                                                                print(
                                                                    'Callback from Swipe To Right');

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
                                                                  setState(() {
                                                                    swipeLeft =
                                                                        false;
                                                                    swipeRight =
                                                                        true;
                                                                  });

                                                                  print(
                                                                      'getBoxRouteDetailsDataList[index]["IsScanRequired"] : ${getBoxRouteDetailsDataList[index]["IsScanRequired"]}');

                                                                  if (getBoxRouteDetailsDataList[
                                                                              index]
                                                                          [
                                                                          "IsScanRequired"] ==
                                                                      true) {
                                                                    await Permission
                                                                        .camera
                                                                        .request();
                                                                    String
                                                                        codeSanner =
                                                                        await scanner
                                                                            .scan();
                                                                    setState(
                                                                        () {
                                                                      qrCodeResult =
                                                                          codeSanner
                                                                              .toString();
                                                                    });
                                                                    debugPrint(
                                                                        'Check codeSanner === : $codeSanner');
                                                                    if (codeSanner ==
                                                                        null) {
                                                                      debugPrint(
                                                                          'Check qrCodeResult ================= "": $qrCodeResult');
                                                                      setState(
                                                                          () {
                                                                        swipeLeft =
                                                                            false;
                                                                        swipeRight =
                                                                            false;
                                                                      });
                                                                    } else if (codeSanner !=
                                                                        null) {
                                                                      debugPrint(
                                                                          'Check qrCodeResult != "": $qrCodeResult');

                                                                      final ValidateScanBoxDataModel
                                                                          validateQRresult =
                                                                          await validateQR(
                                                                              qrCodeResult);
                                                                      debugPrint(
                                                                          '2');

                                                                      setState(
                                                                          () {
                                                                        _validateQRResult =
                                                                            validateQRresult;
                                                                      });
                                                                      debugPrint(
                                                                          '_validateQRResult : $_validateQRResult');

                                                                      debugPrint(
                                                                          '3');

                                                                      if (validateQRresult ==
                                                                          null) {
                                                                        debugPrint(
                                                                            '**');
                                                                        _displaySnackBar(
                                                                            context);
                                                                      } else {
                                                                        if (statusCode ==
                                                                            "500") {
                                                                          if (_validateQRResult.ExceptionMessage !=
                                                                              "") {
                                                                            debugPrint('statusCode : 500 *** ${_validateQRResult.ExceptionMessage}');

                                                                            debugPrint('_displaySnackBarExe **');
                                                                            String
                                                                                exe =
                                                                                _validateQRResult.ExceptionMessage;
                                                                            _displaySnackBarExe(context,
                                                                                exe);
                                                                            //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                                                                          }
                                                                        }
                                                                        if (statusCode ==
                                                                            "200") {
                                                                          String
                                                                              Validate =
                                                                              "${_validateQRResult.Data[0].Validate.toString()}";

                                                                          if (Validate ==
                                                                              "1") {
                                                                            String
                                                                                routeCode =
                                                                                getBoxRouteDetailsDataList[index]["RouteCode"].toString();
                                                                            String
                                                                                boxNoValue =
                                                                                getBoxRouteDetailsDataList[index]["BoxNo_value"].toString();
                                                                            String
                                                                                stepCode =
                                                                                getBoxRouteDetailsDataList[index]["StepCode"].toString();
                                                                            String
                                                                                inputValue =
                                                                                "Yes";
                                                                            String
                                                                                inputDDLValue =
                                                                                "";
                                                                            String
                                                                                compCode =
                                                                                getBoxRouteDetailsDataList[index]["CompCode"].toString();

                                                                            debugPrint('routeCode : $routeCode');
                                                                            debugPrint('boxNo_value : $boxNoValue');
                                                                            debugPrint('stepCode : $stepCode');
                                                                            debugPrint('inputValue : $inputValue');
                                                                            debugPrint('inputDDLValue : $inputDDLValue');

                                                                            AlertToSave(
                                                                                routeCode,
                                                                                boxNoValue,
                                                                                stepCode,
                                                                                inputValue,
                                                                                inputDDLValue,
                                                                                compCode);
                                                                          }
                                                                          if (Validate ==
                                                                              "0") {
                                                                            debugPrint('**');
                                                                            _displaySnackBar(context);
                                                                          }
                                                                        } else {
                                                                          debugPrint(
                                                                              '**');
                                                                          _displaySnackBar(
                                                                              context);
                                                                        }
                                                                      }
                                                                    }
                                                                  }

                                                                  if (getBoxRouteDetailsDataList[
                                                                              index]
                                                                          [
                                                                          "IsScanRequired"] ==
                                                                      false) {
                                                                    String
                                                                        routeCode =
                                                                        getBoxRouteDetailsDataList[index]["RouteCode"]
                                                                            .toString();
                                                                    String
                                                                        boxNoValue =
                                                                        getBoxRouteDetailsDataList[index]["BoxNo_value"]
                                                                            .toString();
                                                                    String
                                                                        stepCode =
                                                                        getBoxRouteDetailsDataList[index]["StepCode"]
                                                                            .toString();
                                                                    String
                                                                        inputValue =
                                                                        "Yes";
                                                                    String
                                                                        inputDDLValue =
                                                                        "";
                                                                    String
                                                                        compCode =
                                                                        getBoxRouteDetailsDataList[index]["CompCode"]
                                                                            .toString();

                                                                    debugPrint(
                                                                        'routeCode : $routeCode');
                                                                    debugPrint(
                                                                        'boxNo_value : $boxNoValue');
                                                                    debugPrint(
                                                                        'stepCode : $stepCode');
                                                                    debugPrint(
                                                                        'inputValue : $inputValue');
                                                                    debugPrint(
                                                                        'inputDDLValue : $inputDDLValue');

                                                                    AlertToSave(
                                                                        routeCode,
                                                                        boxNoValue,
                                                                        stepCode,
                                                                        inputValue,
                                                                        inputDDLValue,
                                                                        compCode);
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                          secondaryActions: <
                                                              Widget>[
                                                            InkWell(
                                                              child:
                                                                  Image.asset(
                                                                "assets/red.png",
                                                              ),
                                                              onTap: () async {
                                                                print(
                                                                    'Callback from Swipe To Left');

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

                                                                  setState(() {
                                                                    swipeRight =
                                                                        false;
                                                                    swipeLeft =
                                                                        true;
                                                                  });
                                                                  print(getBoxRouteDetailsDataList[
                                                                          index]
                                                                      [
                                                                      "IsScanRequired"]);
                                                                  print(
                                                                      "IsScanRequired ***************** $IsScanRequired");
                                                                  if (getBoxRouteDetailsDataList[
                                                                              index]
                                                                          [
                                                                          "IsScanRequired"] ==
                                                                      true) {
                                                                    await Permission
                                                                        .camera
                                                                        .request();
                                                                    String
                                                                        codeSanner =
                                                                        await scanner
                                                                            .scan();
                                                                    setState(
                                                                        () {
                                                                      qrCodeResult =
                                                                          codeSanner
                                                                              .toString();
                                                                    });
                                                                    debugPrint(
                                                                        'Check codeSanner === : $codeSanner');
                                                                    if (codeSanner ==
                                                                        null) {
                                                                      debugPrint(
                                                                          'Check qrCodeResult ================= "": $qrCodeResult');
                                                                      setState(
                                                                          () {
                                                                        swipeLeft =
                                                                            false;
                                                                        swipeRight =
                                                                            false;
                                                                      });
                                                                    } else if (codeSanner !=
                                                                        null) {
                                                                      debugPrint(
                                                                          'Check qrCodeResult != "": $qrCodeResult');

                                                                      final ValidateScanBoxDataModel
                                                                          validateQRresult =
                                                                          await validateQR(
                                                                              qrCodeResult);
                                                                      debugPrint(
                                                                          '2');

                                                                      setState(
                                                                          () {
                                                                        _validateQRResult =
                                                                            validateQRresult;
                                                                      });
                                                                      debugPrint(
                                                                          '_validateQRResult : $_validateQRResult');

                                                                      debugPrint(
                                                                          '3');

                                                                      if (validateQRresult ==
                                                                          null) {
                                                                        debugPrint(
                                                                            '**');
                                                                        _displaySnackBar(
                                                                            context);
                                                                      } else {
                                                                        if (statusCode ==
                                                                            "500") {
                                                                          if (_validateQRResult.ExceptionMessage !=
                                                                              "") {
                                                                            debugPrint('statusCode : 500 *** ${_validateQRResult.ExceptionMessage}');

                                                                            debugPrint('_displaySnackBarExe **');
                                                                            String
                                                                                exe =
                                                                                _validateQRResult.ExceptionMessage;
                                                                            _displaySnackBarExe(context,
                                                                                exe);
                                                                            //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                                                                          }
                                                                        }
                                                                        if (statusCode ==
                                                                            "200") {
                                                                          String
                                                                              Validate =
                                                                              "${_validateQRResult.Data[0].Validate.toString()}";

                                                                          if (Validate ==
                                                                              "1") {
                                                                            String
                                                                                routeCode =
                                                                                getBoxRouteDetailsDataList[index]["RouteCode"].toString();
                                                                            String
                                                                                boxNoValue =
                                                                                getBoxRouteDetailsDataList[index]["BoxNo_value"].toString();
                                                                            String
                                                                                stepCode =
                                                                                getBoxRouteDetailsDataList[index]["StepCode"].toString();
                                                                            String
                                                                                inputValue =
                                                                                "No";
                                                                            String
                                                                                inputDDLValue =
                                                                                "";
                                                                            String
                                                                                compCode =
                                                                                getBoxRouteDetailsDataList[index]["CompCode"].toString();

                                                                            debugPrint('routeCode : $routeCode');
                                                                            debugPrint('boxNo_value : $boxNoValue');
                                                                            debugPrint('stepCode : $stepCode');
                                                                            debugPrint('inputValue : $inputValue');
                                                                            debugPrint('inputDDLValue : $inputDDLValue');

                                                                            AlertToSave(
                                                                                routeCode,
                                                                                boxNoValue,
                                                                                stepCode,
                                                                                inputValue,
                                                                                inputDDLValue,
                                                                                compCode);
                                                                          }
                                                                          if (Validate ==
                                                                              "0") {
                                                                            debugPrint('**');
                                                                            _displaySnackBar(context);
                                                                          }
                                                                        } else {
                                                                          debugPrint(
                                                                              '**');
                                                                          _displaySnackBar(
                                                                              context);
                                                                        }
                                                                      }
                                                                    }
                                                                  }

                                                                  if (getBoxRouteDetailsDataList[
                                                                              index]
                                                                          [
                                                                          "IsScanRequired"] ==
                                                                      false) {
                                                                    String
                                                                        routeCode =
                                                                        getBoxRouteDetailsDataList[index]["RouteCode"]
                                                                            .toString();
                                                                    String
                                                                        boxNoValue =
                                                                        getBoxRouteDetailsDataList[index]["BoxNo_value"]
                                                                            .toString();
                                                                    String
                                                                        stepCode =
                                                                        getBoxRouteDetailsDataList[index]["StepCode"]
                                                                            .toString();
                                                                    String
                                                                        inputValue =
                                                                        "No";
                                                                    String
                                                                        inputDDLValue =
                                                                        "";
                                                                    String
                                                                        compCode =
                                                                        getBoxRouteDetailsDataList[index]["CompCode"]
                                                                            .toString();

                                                                    debugPrint(
                                                                        'routeCode : $routeCode');
                                                                    debugPrint(
                                                                        'boxNo_value : $boxNoValue');
                                                                    debugPrint(
                                                                        'stepCode : $stepCode');
                                                                    debugPrint(
                                                                        'inputValue : $inputValue');
                                                                    debugPrint(
                                                                        'inputDDLValue : $inputDDLValue');

                                                                    AlertToSave(
                                                                        routeCode,
                                                                        boxNoValue,
                                                                        stepCode,
                                                                        inputValue,
                                                                        inputDDLValue,
                                                                        compCode);
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            /* Padding(
                                                  padding: const EdgeInsets.only(top:5.0),
                                                  child:
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: SwipeTo(
                                                      child: Card(
                                                        color: Colors.white,
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
                                                                      Text(widget.custShortCode, style:TextStyle(fontSize: 13, fontFamily: "Poppins",
                                                                          fontWeight: FontWeight.w500,color: Colors.black),),
                                                                      Text(widget.invoiceNo, style:TextStyle(fontSize: 13, fontFamily: "Poppins",
                                                                          fontWeight: FontWeight.w500,color: Colors.black),),
                                                                    ],
                                                                  ),
                                                                )
                                                            ),
                                                            ListTile(
                                                              title:  Text(//"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                                getBoxRouteDetailsDataList[index]["StepCaption"],
                                                                style:TextStyle(fontSize: 16,  fontFamily: "Poppins",
                                                                    fontWeight: FontWeight.w500,color: appColor),),
                                                             leading:  Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               crossAxisAlignment: CrossAxisAlignment.center,
                                                               mainAxisSize: MainAxisSize.min,
                                                               children: <Widget>[
                                                                 if(swipeRight  == false)
                                                                   Padding(
                                                                     padding: const EdgeInsets.only(top:5),
                                                                     child: Icon(Icons.navigate_before,size: 25,color: Colors.black54,),
                                                                   ),
                                                                 if(swipeRight  == true)
                                                                   Image.asset(
                                                                     "assets/green.png",width: 45,height: 55,
                                                                   ),
                                                               ],
                                                             ),
                                                             subtitle:    Row(
                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                               crossAxisAlignment: CrossAxisAlignment.start,
                                                               children: <Widget>[
                                                                 Text(//"21-2-2022",
                                                                   getBoxRouteDetailsDataList[index]["RouteDate"],
                                                                   style:TextStyle(fontSize: 12, fontFamily: "Poppins",
                                                                       fontWeight: FontWeight.w500,color: Colors.black45),),
                                                                 SizedBox(width: 100,),
                                                                 Text(//"10:30 AM",
                                                                   getBoxRouteDetailsDataList[index]["RouteTime"],
                                                                   style:TextStyle(fontSize: 12, fontFamily: "Poppins",
                                                                       fontWeight: FontWeight.w500,color: Colors.black45),),
                                                               ],
                                                             ),
                                                             trailing: Row(
                                                               mainAxisSize: MainAxisSize.min,
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               crossAxisAlignment: CrossAxisAlignment.center,
                                                               children: <Widget>[
                                                                 if(swipeLeft  == false)
                                                                   Icon(Icons.navigate_next,size: 25,color: Colors.black54,),
                                                                 if(swipeLeft  == true)
                                                                   Image.asset(
                                                                     "assets/red.png",width: 45,height: 55,
                                                                   ),
                                                               ],
                                                             ),

                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      onLeftSwipe: () async{
                                                        print('Callback from Swipe To Left');

                                                        var connectivityResult = await (Connectivity().checkConnectivity());
                                                        if (connectivityResult == ConnectivityResult.none) {
                                                          print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                                          Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                                        }
                                                        else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                                          print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");

                                                          setState(() {
                                                            swipeRight = false;
                                                            swipeLeft = true;
                                                          });
                                                          print(getBoxRouteDetailsDataList[index]["IsScanRequired"]);
                                                          print("IsScanRequired ***************** $IsScanRequired");
                                                          if(getBoxRouteDetailsDataList[index]["IsScanRequired"] == true){
                                                            await Permission.camera.request();
                                                            String codeSanner = await scanner.scan();
                                                            setState(() {
                                                              qrCodeResult = codeSanner.toString();
                                                            });
                                                            debugPrint('Check codeSanner === : $codeSanner');
                                                            if(codeSanner == null){
                                                              debugPrint('Check qrCodeResult ================= "": $qrCodeResult');
                                                              setState(() {
                                                                swipeLeft = false;
                                                                swipeRight = false;
                                                              });
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
                                                                    String routeCode = getBoxRouteDetailsDataList[index]["RouteCode"].toString();
                                                                    String boxNo_value = getBoxRouteDetailsDataList[index]["BoxNo_value"].toString();
                                                                    String stepCode = getBoxRouteDetailsDataList[index]["StepCode"].toString();
                                                                    String inputValue = "No";
                                                                    String inputDDLValue = "";
                                                                    String compCode = getBoxRouteDetailsDataList[index]["CompCode"].toString();

                                                                    debugPrint('routeCode : $routeCode');
                                                                    debugPrint('boxNo_value : $boxNo_value');
                                                                    debugPrint('stepCode : $stepCode');
                                                                    debugPrint('inputValue : $inputValue');
                                                                    debugPrint('inputDDLValue : $inputDDLValue');

                                                                    AlertToSave(routeCode, boxNo_value, stepCode, inputValue, inputDDLValue, compCode);


                                                                    /*  final SaveDataModel saveresult = await save(routeCode, boxNo_value, stepCode, inputValue, inputDDLValue, compCode);
                                                                                debugPrint('2');

                                                                                setState(() {
                                                                                  _saveResult = saveresult;
                                                                                });
                                                                                debugPrint('saveresult : $saveresult');

                                                                                debugPrint('_saveResult : $_saveResult');

                                                                                debugPrint('3');

                                                                                if (saveresult == null) {
                                                                                  debugPrint('**');
                                                                                  _displaySnackBar(context);
                                                                                }
                                                                                else {
                                                                                  if(statusCode == "200"){
                                                                                    _resultGetBoxRouteDetailsData =  getBoxRouteDetails();
                                                                                  }
                                                                                  else{
                                                                                    debugPrint('***');
                                                                                    _displaySnackBar(context);
                                                                                  }

                                                                                }*/
                                                                  }
                                                                  if(Validate == "0"){
                                                                    debugPrint('**');
                                                                    _displaySnackBar(context);
                                                                  }

                                                                }
                                                                else{
                                                                  debugPrint('**');
                                                                  _displaySnackBar(context);
                                                                }

                                                              }

                                                            }
                                                          }


                                                          if(getBoxRouteDetailsDataList[index]["IsScanRequired"] == false){
                                                            String routeCode = getBoxRouteDetailsDataList[index]["RouteCode"].toString();
                                                            String boxNo_value = getBoxRouteDetailsDataList[index]["BoxNo_value"].toString();
                                                            String stepCode = getBoxRouteDetailsDataList[index]["StepCode"].toString();
                                                            String inputValue = "No";
                                                            String inputDDLValue = "";
                                                            String compCode = getBoxRouteDetailsDataList[index]["CompCode"].toString();

                                                            debugPrint('routeCode : $routeCode');
                                                            debugPrint('boxNo_value : $boxNo_value');
                                                            debugPrint('stepCode : $stepCode');
                                                            debugPrint('inputValue : $inputValue');
                                                            debugPrint('inputDDLValue : $inputDDLValue');

                                                            AlertToSave(routeCode, boxNo_value, stepCode, inputValue, inputDDLValue, compCode);

                                                          }

                                                        }
                                                      },
                                                      onRightSwipe: () async{
                                                        print('Callback from Swipe To Right');

                                                        var connectivityResult = await (Connectivity().checkConnectivity());
                                                        if (connectivityResult == ConnectivityResult.none) {
                                                          print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                                          Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                                        }
                                                        else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                                          print("*** _isConnected Dash Cancelled Exports btn = $connectivityResult ****");
                                                          setState(() {
                                                            swipeLeft = false;
                                                            swipeRight = true;
                                                          });

                                                          print('getBoxRouteDetailsDataList[index]["IsScanRequired"] : ${getBoxRouteDetailsDataList[index]["IsScanRequired"]}');


                                                          if(getBoxRouteDetailsDataList[index]["IsScanRequired"] == true){
                                                            await Permission.camera.request();
                                                            String codeSanner = await scanner.scan();
                                                            setState(() {
                                                              qrCodeResult = codeSanner.toString();
                                                            });
                                                            debugPrint('Check codeSanner === : $codeSanner');
                                                            if(codeSanner == null){
                                                              debugPrint('Check qrCodeResult ================= "": $qrCodeResult');
                                                              setState(() {
                                                                swipeLeft = false;
                                                                swipeRight = false;
                                                              });
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
                                                                    String routeCode = getBoxRouteDetailsDataList[index]["RouteCode"].toString();
                                                                    String boxNo_value = getBoxRouteDetailsDataList[index]["BoxNo_value"].toString();
                                                                    String stepCode = getBoxRouteDetailsDataList[index]["StepCode"].toString();
                                                                    String inputValue = "Yes";
                                                                    String inputDDLValue = "";
                                                                    String compCode = getBoxRouteDetailsDataList[index]["CompCode"].toString();

                                                                    debugPrint('routeCode : $routeCode');
                                                                    debugPrint('boxNo_value : $boxNo_value');
                                                                    debugPrint('stepCode : $stepCode');
                                                                    debugPrint('inputValue : $inputValue');
                                                                    debugPrint('inputDDLValue : $inputDDLValue');

                                                                    AlertToSave(routeCode, boxNo_value, stepCode, inputValue, inputDDLValue, compCode);
                                                                  }
                                                                  if(Validate == "0"){
                                                                    debugPrint('**');
                                                                    _displaySnackBar(context);
                                                                  }

                                                                }
                                                                else{
                                                                  debugPrint('**');
                                                                  _displaySnackBar(context);
                                                                }

                                                              }

                                                            }
                                                          }


                                                          if(getBoxRouteDetailsDataList[index]["IsScanRequired"] == false){
                                                            String routeCode = getBoxRouteDetailsDataList[index]["RouteCode"].toString();
                                                            String boxNo_value = getBoxRouteDetailsDataList[index]["BoxNo_value"].toString();
                                                            String stepCode = getBoxRouteDetailsDataList[index]["StepCode"].toString();
                                                            String inputValue = "Yes";
                                                            String inputDDLValue = "";
                                                            String compCode = getBoxRouteDetailsDataList[index]["CompCode"].toString();

                                                            debugPrint('routeCode : $routeCode');
                                                            debugPrint('boxNo_value : $boxNo_value');
                                                            debugPrint('stepCode : $stepCode');
                                                            debugPrint('inputValue : $inputValue');
                                                            debugPrint('inputDDLValue : $inputDDLValue');

                                                            AlertToSave(routeCode, boxNo_value, stepCode, inputValue, inputDDLValue, compCode);

                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),*/
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Logical" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    true &&
                                                getBoxRouteDetailsDataList[
                                                        index]["InputValue"] ==
                                                    "Yes") //// This is to show Enter Logical Data is YES
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 7),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Color(
                                                                      0xffe2e4f2)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  widget
                                                                      .custShortCode,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Text(
                                                                  widget
                                                                      .invoiceNo,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                      FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.25,
                                                              child:
                                                                  Image.asset(
                                                                "assets/green.png",
                                                              ),
                                                            ),
                                                            //SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                                            Container(
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                color:
                                                                    routePageColor,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 15,
                                                                      bottom:
                                                                          15,
                                                                      right: 5,
                                                                      left: 20),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "StepCaption"],
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                "Poppins",
                                                                            fontWeight: FontWeight
                                                                                .w500,
                                                                            fontSize:
                                                                                20,
                                                                            letterSpacing:
                                                                                1,
                                                                            color:
                                                                                appColor),
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                        //"21-2-2022",
                                                                        getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "RouteDate"],
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                "Poppins",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Colors.black45),
                                                                      ),
                                                                      if (getBoxRouteDetailsDataList[index]
                                                                              [
                                                                              "ProcessingTime"] !=
                                                                          null)
                                                                        Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width,
                                                                            decoration: BoxDecoration(color: routePageColor),
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.all(5),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Processing Timing ${getBoxRouteDetailsDataList[index]["ProcessingTime"].toString()} mins",
                                                                                  style: TextStyle(fontSize: 13, fontFamily: "Poppins", fontWeight: FontWeight.w500, color: Colors.redAccent),
                                                                                ),
                                                                              ),
                                                                            ))
                                                                    ],
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Logical" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    true &&
                                                getBoxRouteDetailsDataList[
                                                        index]["InputValue"] ==
                                                    "No") //// This is to show Enter Logical Data is NO
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 7),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Color(
                                                                      0xffe2e4f2)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  widget
                                                                      .custShortCode,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                Text(
                                                                  widget
                                                                      .invoiceNo,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      fontFamily:
                                                                          "Poppins",
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ],
                                                            ),
                                                          )),
                                                      FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                //SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                                                Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    color:
                                                                        routePageColor,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              15,
                                                                          bottom:
                                                                              15,
                                                                          right:
                                                                              5,
                                                                          left:
                                                                              20),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            getBoxRouteDetailsDataList[index]["StepCaption"],
                                                                            style: TextStyle(
                                                                                fontFamily: "Poppins",
                                                                                fontWeight: FontWeight.w500,
                                                                                fontSize: 20,
                                                                                letterSpacing: 1,
                                                                                color: appColor),
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8),
                                                                          Text(
                                                                            //"21-2-2022",
                                                                            getBoxRouteDetailsDataList[index]["RouteDate"],
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                fontFamily: "Poppins",
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Colors.black45),
                                                                          ),
                                                                          if (getBoxRouteDetailsDataList[index]["ProcessingTime"] !=
                                                                              null)
                                                                            Container(
                                                                                width: MediaQuery.of(context).size.width,
                                                                                decoration: BoxDecoration(color: routePageColor),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(5),
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      "Processing Timing ${getBoxRouteDetailsDataList[index]["ProcessingTime"].toString()} mins",
                                                                                      style: TextStyle(fontSize: 13, fontFamily: "Poppins", fontWeight: FontWeight.w500, color: Colors.redAccent),
                                                                                    ),
                                                                                  ),
                                                                                ))
                                                                        ],
                                                                      ),
                                                                    )),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.25,
                                                                  child: Image
                                                                      .asset(
                                                                    "assets/red.png",
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            /*  if (getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "ProcessingTime"] !=
                                                                null)
                                                              SizedBox(
                                                                height: 5,
                                                              ), */
                                                            if (getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "ProcessingTime"] !=
                                                                null)
                                                              Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color:
                                                                              routePageColor),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(5),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "Processing Timing ${getBoxRouteDetailsDataList[index]["ProcessingTime"].toString()} mins",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                            fontFamily:
                                                                                "Poppins",
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            color: Colors.redAccent),
                                                                      ),
                                                                    ),
                                                                  ))
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Input Text" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    false) //// This is for Input
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: InkWell(
                                                  onTap: () async {
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

                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"] ==
                                                          true) {
                                                        await Permission.camera
                                                            .request();
                                                        String codeSanner =
                                                            await scanner
                                                                .scan();
                                                        setState(() {
                                                          qrCodeResult =
                                                              codeSanner
                                                                  .toString();
                                                        });
                                                        debugPrint(
                                                            'Check codeSanner === : $codeSanner');
                                                        if (codeSanner ==
                                                            null) {
                                                          debugPrint(
                                                              'Check qrCodeResult ================= "": $qrCodeResult');
                                                        } else if (codeSanner !=
                                                            null) {
                                                          debugPrint(
                                                              'Check qrCodeResult != "": $qrCodeResult');

                                                          final ValidateScanBoxDataModel
                                                              validateQRresult =
                                                              await validateQR(
                                                                  qrCodeResult);
                                                          debugPrint('2');

                                                          setState(() {
                                                            _validateQRResult =
                                                                validateQRresult;
                                                          });
                                                          debugPrint(
                                                              '_validateQRResult : $_validateQRResult');

                                                          debugPrint('3');

                                                          if (validateQRresult ==
                                                              null) {
                                                            debugPrint('**');
                                                            _displaySnackBar(
                                                                context);
                                                          } else {
                                                            if (statusCode ==
                                                                "500") {
                                                              if (_validateQRResult
                                                                      .ExceptionMessage !=
                                                                  "") {
                                                                debugPrint(
                                                                    'statusCode : 500 *** ${_validateQRResult.ExceptionMessage}');

                                                                debugPrint(
                                                                    '_displaySnackBarExe **');
                                                                String exe =
                                                                    _validateQRResult
                                                                        .ExceptionMessage;
                                                                _displaySnackBarExe(
                                                                    context,
                                                                    exe);
                                                                //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                                                              }
                                                            }
                                                            if (statusCode ==
                                                                "200") {
                                                              String Validate =
                                                                  "${_validateQRResult.Data[0].Validate.toString()}";

                                                              if (Validate ==
                                                                  "1") {
                                                                String
                                                                    routeCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "RouteCode"]
                                                                        .toString();
                                                                String
                                                                    boxNoValue =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "BoxNo_value"]
                                                                        .toString();
                                                                String
                                                                    stepCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "StepCode"]
                                                                        .toString();
                                                                String
                                                                    inputDDLValue =
                                                                    "";
                                                                String
                                                                    compCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "CompCode"]
                                                                        .toString();

                                                                debugPrint(
                                                                    'routeCode : $routeCode');
                                                                debugPrint(
                                                                    'boxNo_value : $boxNoValue');
                                                                debugPrint(
                                                                    'stepCode : $stepCode');
                                                                debugPrint(
                                                                    'inputDDLValue : $inputDDLValue');

                                                                _qrScanSuccess(
                                                                    context,
                                                                    routeCode,
                                                                    boxNoValue,
                                                                    stepCode,
                                                                    inputDDLValue,
                                                                    compCode);
                                                              }
                                                              if (Validate ==
                                                                  "0") {
                                                                debugPrint(
                                                                    '**');
                                                                _displaySnackBar(
                                                                    context);
                                                              }
                                                            } else {
                                                              debugPrint('**');
                                                              _displaySnackBar(
                                                                  context);
                                                            }
                                                          }
                                                        }
                                                      }

                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"] ==
                                                          false) {
                                                        String routeCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "RouteCode"]
                                                                .toString();
                                                        String boxNoValue =
                                                            getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "BoxNo_value"]
                                                                .toString();
                                                        String stepCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index]
                                                                    ["StepCode"]
                                                                .toString();
                                                        String inputDDLValue =
                                                            "";
                                                        String compCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index]
                                                                    ["CompCode"]
                                                                .toString();

                                                        debugPrint(
                                                            'routeCode : $routeCode');
                                                        debugPrint(
                                                            'boxNo_value : $boxNoValue');
                                                        debugPrint(
                                                            'stepCode : $stepCode');
                                                        debugPrint(
                                                            'inputDDLValue : $inputDDLValue');

                                                        _qrScanSuccess(
                                                            context,
                                                            routeCode,
                                                            boxNoValue,
                                                            stepCode,
                                                            inputDDLValue,
                                                            compCode);
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Card(
                                                      color: Colors.white,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Color(
                                                                          0xffe2e4f2)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      widget
                                                                          .custShortCode,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily:
                                                                              "Poppins",
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Text(
                                                                      widget
                                                                          .invoiceNo,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily:
                                                                              "Poppins",
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 15,
                                                                    bottom: 15,
                                                                    right: 10,
                                                                    left: 10),
                                                            child: Text(
                                                              //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                              getBoxRouteDetailsDataList[
                                                                      index][
                                                                  "StepCaption"],
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      appColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Input Text" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    true) //// This is to show Enter Input Data
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color(
                                                                        0xffe2e4f2)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    widget
                                                                        .custShortCode,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                        .invoiceNo,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 15,
                                                                  bottom: 15,
                                                                  right: 10,
                                                                  left: 10),
                                                          child: Text(
                                                            //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                            getBoxRouteDetailsDataList[
                                                                    index]
                                                                ["InputValue"],
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    appColor),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                    index]["Action"] ==
                                                "End") //// This is for END
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    color: Colors.green,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color(
                                                                        0xffe2e4f2)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    widget
                                                                        .custShortCode,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                        .invoiceNo,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 15,
                                                                  bottom: 15,
                                                                  right: 10,
                                                                  left: 10),
                                                          child: Text(
                                                            //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                            getBoxRouteDetailsDataList[
                                                                    index]
                                                                ["StepCaption"],
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Input DDL" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    false) //// This is for Drowpdown false
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: InkWell(
                                                  onTap: () async {
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

                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"] ==
                                                          true) {
                                                        await Permission.camera
                                                            .request();
                                                        String codeSanner =
                                                            await scanner
                                                                .scan();
                                                        setState(() {
                                                          qrCodeResult =
                                                              codeSanner
                                                                  .toString();
                                                        });
                                                        debugPrint(
                                                            'Check codeSanner === : $codeSanner');
                                                        if (codeSanner ==
                                                            null) {
                                                          debugPrint(
                                                              'Check qrCodeResult ================= "": $qrCodeResult');
                                                        } else if (codeSanner !=
                                                            null) {
                                                          debugPrint(
                                                              'Check qrCodeResult != "": $qrCodeResult');

                                                          final ValidateScanBoxDataModel
                                                              validateQRresult =
                                                              await validateQR(
                                                                  qrCodeResult);
                                                          debugPrint('2');

                                                          setState(() {
                                                            _validateQRResult =
                                                                validateQRresult;
                                                          });
                                                          debugPrint(
                                                              '_validateQRResult : $_validateQRResult');

                                                          debugPrint('3');

                                                          if (validateQRresult ==
                                                              null) {
                                                            debugPrint('**');
                                                            _displaySnackBar(
                                                                context);
                                                          } else {
                                                            if (statusCode ==
                                                                "500") {
                                                              if (_validateQRResult
                                                                      .ExceptionMessage !=
                                                                  "") {
                                                                debugPrint(
                                                                    'statusCode : 500 *** ${_validateQRResult.ExceptionMessage}');

                                                                debugPrint(
                                                                    '_displaySnackBarExe **');
                                                                String exe =
                                                                    _validateQRResult
                                                                        .ExceptionMessage;
                                                                _displaySnackBarExe(
                                                                    context,
                                                                    exe);
                                                                //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                                                              }
                                                            }
                                                            if (statusCode ==
                                                                "200") {
                                                              String Validate =
                                                                  "${_validateQRResult.Data[0].Validate.toString()}";

                                                              if (Validate ==
                                                                  "1") {
                                                                String
                                                                    routeCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "RouteCode"]
                                                                        .toString();
                                                                String
                                                                    boxNoValue =
                                                                    widget
                                                                        .boxNo_Value;
                                                                String
                                                                    stepCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "StepCode"]
                                                                        .toString();
                                                                String
                                                                    inputValue =
                                                                    "";
                                                                String
                                                                    compCode =
                                                                    getBoxRouteDetailsDataList[index]
                                                                            [
                                                                            "CompCode"]
                                                                        .toString();

                                                                debugPrint(
                                                                    'routeCode : $routeCode');
                                                                debugPrint(
                                                                    'boxNo_value : $boxNoValue');
                                                                debugPrint(
                                                                    'stepCode : $stepCode');
                                                                debugPrint(
                                                                    'inputValue : $inputValue');

                                                                showConfirmationDialog(
                                                                    context,
                                                                    routeCode,
                                                                    boxNoValue,
                                                                    stepCode,
                                                                    inputValue,
                                                                    compCode);
                                                              }
                                                              if (Validate ==
                                                                  "0") {
                                                                debugPrint(
                                                                    '**');
                                                                _displaySnackBar(
                                                                    context);
                                                              }
                                                            } else {
                                                              debugPrint('**');
                                                              _displaySnackBar(
                                                                  context);
                                                            }
                                                          }
                                                        }
                                                      }

                                                      if (getBoxRouteDetailsDataList[
                                                                  index][
                                                              "IsScanRequired"] ==
                                                          false) {
                                                        String routeCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index][
                                                                    "RouteCode"]
                                                                .toString();
                                                        String boxNoValue =
                                                            widget.boxNo_Value;
                                                        String stepCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index]
                                                                    ["StepCode"]
                                                                .toString();
                                                        String inputValue = "";
                                                        String compCode =
                                                            getBoxRouteDetailsDataList[
                                                                        index]
                                                                    ["CompCode"]
                                                                .toString();

                                                        debugPrint(
                                                            'routeCode : $routeCode');
                                                        debugPrint(
                                                            'boxNo_value : $boxNoValue');
                                                        debugPrint(
                                                            'stepCode : $stepCode');
                                                        debugPrint(
                                                            'inputValue : $inputValue');

                                                        showConfirmationDialog(
                                                            context,
                                                            routeCode,
                                                            boxNoValue,
                                                            stepCode,
                                                            inputValue,
                                                            compCode);
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Card(
                                                      color: Colors.white,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Color(
                                                                          0xffe2e4f2)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      widget
                                                                          .custShortCode,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily:
                                                                              "Poppins",
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Text(
                                                                      widget
                                                                          .invoiceNo,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          fontFamily:
                                                                              "Poppins",
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 15,
                                                                    bottom: 15,
                                                                    right: 10,
                                                                    left: 10),
                                                            child: Text(
                                                              //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                              getBoxRouteDetailsDataList[
                                                                      index][
                                                                  "StepCaption"],
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      "Poppins",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      appColor),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (getBoxRouteDetailsDataList[
                                                        index]["Action"] ==
                                                    "Input DDL" &&
                                                getBoxRouteDetailsDataList[
                                                            index]
                                                        ["IsStepComplete"] ==
                                                    true) //// This is for Drowpdown  true
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    color: Colors.white,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color(
                                                                        0xffe2e4f2)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    widget
                                                                        .custShortCode,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Text(
                                                                    widget
                                                                        .invoiceNo,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontFamily:
                                                                            "Poppins",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 15,
                                                                  bottom: 15,
                                                                  right: 10,
                                                                  left: 10),
                                                          child: Text(
                                                            //"cjnjvnjhcvjhxjhvhbdsjhvb",
                                                            getBoxRouteDetailsDataList[
                                                                    index][
                                                                "InputDDLValue"],
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    "Poppins",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    appColor),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
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

  showConfirmationDialog(BuildContext context, String routeCode,
      String boxNoValue, String stepCode, String inputValue, String compCode) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
            routeCode: routeCode,
            boxNo_value: boxNoValue,
            stepCode: stepCode,
            inputValue: inputValue,
            compCode: compCode,
            boxNo_Value: widget.boxNo_Value,
            boxNo: widget.boxNo);
      },
    );
  }
}

class CustomDialog extends StatefulWidget {
  final String routeCode;
  final String boxNo_value;
  final String stepCode;
  final String inputValue;
  final String compCode;
  final Function onPressed;
  final String exportType_value;
  final String exportType;
  final String boxNo_Value;
  final String boxNo;
  final String boxCount;

  CustomDialog(
      {this.routeCode,
      this.boxNo_value,
      this.stepCode,
      this.inputValue,
      this.compCode,
      this.onPressed,
      this.exportType_value,
      this.exportType,
      this.boxNo_Value,
      this.boxNo,
      this.boxCount});

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  int getDDLFailureReasonsListLenght;
  Map getDDLFailureReasonsJson;
  List getDDLFailureReasonsDataList = List();
  List<GetDDLFailureReasonsResultModel> _resultGetDDLFailureReasonsResult;
  Future<GetDDLFailureReasonsDataModel> _resultGetDDLFailureReasonsData;
  Future<GetDDLFailureReasonsDataModel> getDDL() async {
    print("Api getDDL 1.........");
    try {
      print("Api getDDL 1");
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint('Check getDDL _API_Path $APIPath ');
      debugPrint('Check getDDL _Token $Token ');

      final String apiUrl = "$APIPath/Dashboard/GetDDLFailureReasons";

      print("Api getDDL 2");
      print("Api getDDL _Token : $Token");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({}),
      );

      print("Api getDDL 3");

      print("Api getDDL response code : ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Api getDDL 4");

        final String responseString = response.body;

        getDDLFailureReasonsJson = json.decode(responseString);
        debugPrint(
            'Api getDDL 6 getDDLFailureReasonsJson $getDDLFailureReasonsJson');

        getDDLFailureReasonsDataList = getDDLFailureReasonsJson["Data"];

        for (var i = 0; i < getDDLFailureReasonsDataList.length; i++) {
          getDDLFailureReasonsDataList[i]['IsChecked'] = false;
        }
        debugPrint(
            'Api getDDL 6.1 getDDLFailureReasonsJson $getDDLFailureReasonsDataList');
        setState(() {
          getDDLFailureReasonsListLenght = getDDLFailureReasonsDataList.length;

          _resultGetDDLFailureReasonsResult = getDDLFailureReasonsJson["Data"]
              .map<GetDDLFailureReasonsResultModel>(
                  (e) => GetDDLFailureReasonsResultModel.fromJson(e))
              .toList();
        });

        return getDDLFailureReasonsDataModelFromJson(responseString);
      } else {
        print("Api getDDL 7");
        return null;
      }
    } catch (e) {
      print("Api getDDL 8");

      print(e);
      return null;
    }
  }

  bool chechBox = false;

  String inputCheckBoxValue = "";

  String statusCode;
  int saveIndex = 0;
  SaveDataModel _saveResult;
  String saveStatusCode;
  Future<SaveDataModel> save(
      String routeCode,
      String boxNoValue,
      String stepCode,
      String inputDDLValue,
      String inputValue,
      String compCode) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      String APIPath = _prefs.getString('API_Path');
      String Token = _prefs.getString('Token');
      debugPrint('Check save _API_Path $APIPath ');
      debugPrint('Check save _Token $Token ');
      final String apiUrl = "$APIPath/Dashboard/SaveBoxDetails";
      debugPrint('Check save 1 ');
      debugPrint('Check save apiUrl : $apiUrl ');

      debugPrint('Check save routeCode $routeCode ');
      debugPrint('Check save boxNo_value $boxNoValue ');
      debugPrint('Check save stepCode $stepCode ');
      debugPrint('Check save inputValue $inputValue ');
      debugPrint('Check save inputDDLValue $inputDDLValue ');
      debugPrint('Check save compCode $compCode ');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-access-token': Token
        },
        body: json.encode({
          "@RouteCode": routeCode,
          "@BoxNo_value": boxNoValue,
          "@stepCode": stepCode,
          "@InputValue": inputValue,
          "@InputDDLValue": inputDDLValue,
          "@compCode": compCode
        }),
      );
      debugPrint('Check save 2');
      debugPrint('Check save statusCode : ${response.statusCode}');
      if (response.statusCode == 200) {
        debugPrint('Check save 3');
        setState(() {
          statusCode = "200";
        });
        final String responseString = response.body;
        debugPrint('Check save 4');
        debugPrint('Check save responseString : $responseString');

        return saveModelFromJson(responseString);
      }
      if (response.statusCode == 500) {
        setState(() {
          statusCode = "500";
        });
        final String responseString = response.body;
        debugPrint('Check mAuthenticate responseString $responseString ');
        return saveDataModelFromJsonExe(responseString);
      } else {
        debugPrint('Check save 5');

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  void initState() {
    _resultGetDDLFailureReasonsData = getDDL();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Failure Reason',
          style: TextStyle(
              fontSize: 18,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              color: appColor)),
      content: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: FutureBuilder(
                future: _resultGetDDLFailureReasonsData,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text(''));
                  }
                  if (snapshot.hasData) {
                    return ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: getDDLFailureReasonsDataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    getDDLFailureReasonsDataList[index]
                                        ["FailureReason"],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w500,
                                        color: appColor),
                                  ),
                                  trailing: Checkbox(
                                    //title: Text(_resultServices[index].Service,style: TextStyle(fontSize:16, fontFamily: "Camphor",
                                    // fontWeight: FontWeight.w700,color: Colors.black),),
                                    value: getDDLFailureReasonsDataList[index]
                                        ["IsChecked"],
                                    activeColor: appColor,
                                    checkColor: Colors.white,
                                    onChanged: (val) {
                                      setState(
                                        () {
                                          // getDDLFailureReasonsDataList[index]["IsChecked"] = val;

                                          for (var i = 0;
                                              i <
                                                  getDDLFailureReasonsDataList
                                                      .length;
                                              i++) {
                                            if (getDDLFailureReasonsDataList[
                                                    index] ==
                                                getDDLFailureReasonsDataList[
                                                    i]) {
                                              getDDLFailureReasonsDataList[i]
                                                  ['IsChecked'] = true;

                                              inputCheckBoxValue =
                                                  getDDLFailureReasonsDataList[
                                                      index]["FailureReason"];

                                              print(
                                                  "inputCheckBoxValue : $inputCheckBoxValue");
                                            } else {
                                              getDDLFailureReasonsDataList[i]
                                                  ['IsChecked'] = false;
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                      child: SpinKitRotatingCircle(
                    color: appColor,
                    size: 50.0,
                  ));
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.red,
              ),
              textStyle: MaterialStateProperty.all(TextStyle(
                color: Colors.white,
              )),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: "AlternateGothic",
              fontWeight: FontWeight.w500,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
        SizedBox(
          width: 40,
        ),
        TextButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Colors.green,
              ),
              textStyle: MaterialStateProperty.all(TextStyle(
                color: Colors.white,
              )),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              )),
          child: Text(
            'SAVE',
            style: TextStyle(
              fontFamily: "AlternateGothic",
              fontWeight: FontWeight.w500,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
          onPressed: () async {
            setState(() {
              debugPrint('_qrScanSuccess routeCode : ${widget.routeCode}');
              debugPrint('_qrScanSuccess boxNo_value : ${widget.boxNo_value}');
              debugPrint('_qrScanSuccess stepCode : ${widget.stepCode}');
              debugPrint('_qrScanSuccess inputValue : ${widget.inputValue}');
              debugPrint('_qrScanSuccess inputDDLValue : $inputCheckBoxValue');
            });

            final SaveDataModel saveresult = await save(
                widget.routeCode,
                widget.boxNo_value,
                widget.stepCode,
                inputCheckBoxValue,
                widget.inputValue,
                widget.compCode);
            debugPrint('2');

            setState(() {
              _saveResult = saveresult;
            });
            debugPrint('saveresult : $saveresult');

            debugPrint('_saveResult : $_saveResult');

            debugPrint('3');

            if (saveresult == null) {
              debugPrint('**');
              Navigator.pop(context);
              // _displaySnackBar(context);
            } else {
              if (statusCode == "500") {
                if (_saveResult.ExceptionMessage != "") {
                  debugPrint(
                      'statusCode : 500 *** ${_saveResult.ExceptionMessage}');

                  debugPrint('_displaySnackBarExe **');
                  String exe = _saveResult.ExceptionMessage;
                  Toast.show(exe, context,
                      duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

                  Navigator.pop(context);
                  //  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => DashPage()));
                }
              }
              if (statusCode == "200") {
                Navigator.pushReplacement(
                    context,
                    SlideLeftRoute(
                        page: DirectScan_BoxRouteDetailsPage(
                            boxNo_Value: widget.boxNo_Value,
                            boxNo: widget.boxNo)));
              }
            }
          },
        ),
      ],
    );
  }
}
