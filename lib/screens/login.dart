import 'dart:async';
import 'dart:convert';
import 'package:exim/screens/verifyOTP.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:device_id/device_id.dart';
import 'package:device_info/device_info.dart';
import 'package:exim/constant/colors.dart';
import 'package:exim/models/loginData_model.dart';
import 'package:exim/screens/noInternet.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter/material.dart';
import 'package:get_mac/get_mac.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  final Function onPressed;

  LoginPage({ this.onPressed });
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  String _contactNo;
  String _password;

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String tokenValue = '';
  String _platformImei = '';
  String uniqueId = "";


  //LoginResultModel _result;

  _registerOnFirebase() {
    // _firebaseMessaging.subscribeToTopic('all');
    FirebaseMessaging.instance.getToken().then((token)
    {
          debugPrint("token is ======="+token);
      if (token != null)
      {
        update(token);
      }
    }
    );
  }

  update(String token) {
    print(token);
    // DatabaseReference databaseReference = new FirebaseDatabase().reference();
    //databaseReference.child('fcm-token/${token}').set({"token": token});
    tokenValue = token;
    setState(() {});
  }

  Future<void> initPlatformState() async {
    String platformImei;
    String idunique;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei =
      await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      List<String> multiImei = await ImeiPlugin.getImeiMulti();
      print(multiImei);
      idunique = await ImeiPlugin.getId();
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
      uniqueId = idunique;
    });
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
                child: Text('EXIM',style: TextStyle(fontFamily: "Poppins",
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
                //color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Yes',style: TextStyle(color:appColor,fontSize: 16,  fontFamily: "Poppins",
                    fontWeight: FontWeight.w900,),),
                ),
                onPressed: ()=> exit(0),

              ),
              TextButton(
                // color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('No',style: TextStyle(color:appColor,fontSize: 16, fontFamily: "Poppins",
                    fontWeight: FontWeight.w900,),),
                ),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),

            ],
          );
        });
  }

  String _platformMACID = '';

  Future<void> initPlatformMACState() async {
    String platformVersion;
    try {
      platformVersion = await GetMac.macAddress;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
    }
    print("MAC-: " + platformVersion);
    if (!mounted) return;
    setState(() {
      _platformMACID = platformVersion;
    });
  }

  String _deviceName = '';
  String _deviceVersion = '';
  String _identifier = '';
  String _devideId = '';

  Future<void> getDeviceDetails() async {
    String deviceName;
    String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceName = build.model;
        deviceVersion = build.version.toString();
        identifier = build.androidId;  //UUID for Android

        print("deviceName : *** $deviceName");
        print("deviceVersion : *** $deviceVersion");
        print("identifier : *** $identifier");

      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceName = data.name;
        deviceVersion = data.systemVersion;
        identifier = data.identifierForVendor;  //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
    if (!mounted) return;
    setState(() {
      _deviceName = deviceName;
      _deviceVersion = deviceVersion;
      _identifier = identifier;
    });
  }

  void check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("*** _isConnected Login page Load = $connectivityResult ****");
      Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
      /*Navigator.push(context,
          MaterialPageRoute(builder: (context) => NoInternetPage()));*/
    }
    else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
      print("*** _isConnected Login page Load = $connectivityResult ****");
      _registerOnFirebase();
      initPlatformState();
      initPlatformMACState();
      getDeviceDetails();
      _devideId = await DeviceId.getID;

    }
  }

  int index = 0;
  LoginDataModel _loginResult;
  String statusCode;
  Future<LoginDataModel> mAuthenticate(String contactNo, String devideId, String deviceName, String mac, String imei, String token,) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      String _API_Path = _prefs.getString('API_Path');
      debugPrint('Check mAuthenticate _API_Path $_API_Path ');
      final String apiUrl = "$_API_Path/Authentication/MobileAuthentication";
      debugPrint('Check mAuthenticate contactNo $contactNo ');
      debugPrint('Check mAuthenticate devideId $devideId ');
      debugPrint('Check mAuthenticate deviceName $deviceName ');
      debugPrint('Check mAuthenticate mac $mac ');
      debugPrint('Check mAuthenticate imei $imei ');
      debugPrint('Check mAuthenticate token $token ');
      debugPrint('Check mAuthenticate 1 ');
      debugPrint('Check mAuthenticate apiUrl : $apiUrl ');


      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.acceptHeader: 'application/json'},
        body: json.encode(
            {
              "MobileNumber": contactNo,
              "DeviceId": devideId,
              "Firmware": "",
              "DeviceName": deviceName,
              "MAC": mac,
              "IMEI": imei,
              "GoogleToken": token
            }),
      );
      debugPrint('Check mAuthenticate 2');
      if (response.statusCode == 200) {
        debugPrint('Check mAuthenticate 3');
        setState(() {
          statusCode = "200";
        });
        final String responseString = response.body;
        debugPrint('Check mAuthenticate 4');
        debugPrint('Check mAuthenticate responseString : $responseString');

        return loginDataModelFromJson(responseString);
      }
      /* if (response.statusCode == 500) {
        setState(() {
          statusCode = "500";
        });
        final String responseString = response.body;
        debugPrint('Check mAuthenticate responseString $responseString ');
        return dataModelFromJsonExe(responseString);
      }*/
      else {
        debugPrint('Check mAuthenticate 5');

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }


  @override
  void initState() {
    check();
    super.initState();
    
  }


  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _displaySnackBarExe(BuildContext context, String exe) {
    final snackBar = SnackBar(
        content: Text(exe, style: TextStyle(fontSize: 20),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  final TextEditingController _controllerMobileNo = new TextEditingController();
  bool _isInAsyncCall = false;




  @override
  Widget build(BuildContext context) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);

    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          // demo of some additional parameters
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  //First thing in the stack is the background
                  //For the backgroud i create a column
                  Column(
                    children: <Widget>[
                      //first element in the column is the white background (the Image.asset in your case)
                      SizedBox(height: 325,),
                      Align(
                        alignment: Alignment.center,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white, boxShadow: [
                              BoxShadow(
                                color: Color(0xffbfbfbf),
                                blurRadius: 4,
                                spreadRadius: 0.5,
                                offset: Offset(0, 0.5),
                              ),
                            ],
                            ),
                            child: Container(
                              width: 320.0,
                              height: 340.0,
                              child:   Padding(
                                padding: const EdgeInsets.only(left:15, right:15),
                                child: Form(
                                  key: _formStateKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 25),
                                      Text("OTP VERIFICATION", style: TextStyle(fontSize:28,color: appColor,fontFamily: "AlternateGothic",
                                          fontWeight: FontWeight.w700,letterSpacing: 2),),
                                      SizedBox(height: 15,),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text("We will send You an One Time Password", style: TextStyle(fontSize:16,fontFamily: "Poppins",
                                            fontWeight: FontWeight.w500,color: Colors.black45,letterSpacing: 0.5),),
                                      ),
                                      SizedBox(height: 2,),
                                      Text("on this Mobile Number", style: TextStyle(fontSize:16,fontFamily: "Poppins",
                                          fontWeight: FontWeight.w500,color: Colors.black45,letterSpacing: 0.5),),
                                      SizedBox(height: 50,),
                                      Text("Enter Your Mobile Number", style: TextStyle(fontSize:16,fontFamily: "Poppins",
                                          fontWeight: FontWeight.w500,color: Colors.black45,letterSpacing: 0.5),),
                                      SizedBox(height: 10,),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom:8, left:5, right:5),
                                        child: Card(
                                          color: appBgColor,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right:8, left: 8, top:5, bottom: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width * 0.2,
                                                  child: Text("+91", style: TextStyle(fontFamily: "AlternateGothic",
                                                      fontWeight: FontWeight.w500,fontSize: 26, letterSpacing: 3),textAlign: TextAlign.center,),
                                                ),
                                                //SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                                                Expanded(
                                                  child:  TextFormField(
                                                    onSaved: (value) {
                                                      _contactNo = value;
                                                    },
                                                    textAlign: TextAlign.center,
                                                    controller: _controllerMobileNo,
                                                    maxLength: 10,
                                                    keyboardType: TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                    ],
                                                    decoration: InputDecoration(
                                                      counterText: "",
                                                      border: InputBorder.none,
                                                      hintText: "9999999999",
                                                      hintStyle: TextStyle(fontFamily: "AlternateGothic",
                                                          fontWeight: FontWeight.w500, fontSize: 26, letterSpacing: 3, color: Color(0xffd0d0d0)),
                                                    ),
                                                    validator: (value) {
                                                      if (value.length == 0 || value.isEmpty) {
                                                        return "Mobile No can not be empty";
                                                      }
                                                      else if (!regExp.hasMatch(value)) {
                                                        return 'Please Enter valid Mobile No';
                                                      }
                                                      return null;
                                                    },
                                                    style: TextStyle(fontFamily: "AlternateGothic",
                                                        fontWeight: FontWeight.w500, fontSize: 26, letterSpacing: 3 ),
                                                    //  textInputAction: TextInputAction.search,
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),

                            )
                        ),
                      ),
                      //second item in the column is a transparent space of 20

                    ],
                  ),
                  //for the button i create another column
                  Column(
                      children:<Widget>[
                        //first element in column is the transparent offset
                        Container(
                            height: 620.0
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: ()async{
                              if (_formStateKey.currentState.validate()) {
                                _formStateKey.currentState.save();

                                var connectivityResult = await (Connectivity().checkConnectivity());
                                if (connectivityResult == ConnectivityResult.none) {
                                  print("*** _isConnected Login btn = $connectivityResult ****");
                                  Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
                                }
                                else if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
                                  print("*** _isConnected Login btn = $connectivityResult ****");
                                  setState(() {
                                    _isInAsyncCall = true;
                                  });

                                  String phnNo = "+91$_contactNo";
                                  print("******************$_contactNo");

                                  final String contactNo = _contactNo;
                                  final String mac = _platformMACID;
                                  final String imei = _platformImei;
                                  final String deviceVersion = _deviceVersion;
                                  final String deviceName = _deviceName;
                                  final String identifier = _identifier;
                                  final String devideId = _devideId;
                                  final String token = tokenValue;

                                  debugPrint('contactNo : ${contactNo}' );
                                  debugPrint('mac : ${mac}' );
                                  debugPrint('imei : ${imei}' );
                                  debugPrint('deviceVersion : ${deviceVersion}' );
                                  debugPrint('deviceName : ${deviceName}' );
                                  debugPrint('identifier : ${identifier}' );
                                  debugPrint('devideId : ${devideId}' );
                                  debugPrint('token : ${token}' );

                                  String API_Path = "http://mindtechsolutions.com/tester/EximApi/API";

                                  // String API_Path = "http://mindtechsolutions.com/tester/EximApiDev/API";


                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString('API_Path', API_Path);

                                  debugPrint('1');

                                  final LoginDataModel result = await mAuthenticate(contactNo, devideId, deviceName, mac, imei, token);
                                  debugPrint('2');

                                  setState(() {
                                    _loginResult = result;
                                  });
                                  debugPrint('result : $result');

                                  debugPrint('_loginResult : $_loginResult');

                                  debugPrint('3');

                                  if(statusCode == "200"){
                                    String Status = "${_loginResult.Data[index].Status.toString()}";

                                    if(Status == "1"){
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setInt('EmpCode', _loginResult.Data[index].EmpCode);
                                      prefs.setInt('MCUserCode', _loginResult.Data[index].MCUserCode);
                                      prefs.setString('MobileNumber', _loginResult.Data[index].MobileNumber);
                                      prefs.setString('DeviceId', _devideId);

                                      debugPrint('Check 2.1 EmpCode  : ${_loginResult.Data[index].EmpCode}');
                                      debugPrint('Check 2.1 MCUserCode : ${_loginResult.Data[index].MCUserCode}');
                                      debugPrint('Check 2.1 MobileNumber   : ${_loginResult.Data[index].MobileNumber}');
                                      debugPrint('Check 2.1 DeviceId   : $_devideId');

                                      debugPrint('4.1');

                                      debugPrint('****************************************');
                                      setState(() {
                                        _isInAsyncCall = false;
                                      });
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => VerifyOtp(contactNo: contactNo,devideId: devideId,deviceName: deviceName,mac: mac,imei: imei,token: token,)));
                                    }
                                    if(Status == "0"){
                                      debugPrint('_displaySnackBarExe **');
                                      String exe = _loginResult.Data[index].Message;
                                      setState(() {
                                        _isInAsyncCall = false;
                                      });
                                      _displaySnackBarExe(context, exe);
                                    }

                                  }
                                  else{
                                    debugPrint('***');
                                    String exe = _loginResult.Data[index].Message;
                                    setState(() {
                                      _isInAsyncCall = false;
                                    });
                                    _displaySnackBarExe(context, exe);
                                  }

                                }
                              }
                            },
                            child: Container(
                              height: 90,
                              width: 180,
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/btn.png",
                              ),
                            ),
                          ),
                        ),
                      ]
                  )
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}