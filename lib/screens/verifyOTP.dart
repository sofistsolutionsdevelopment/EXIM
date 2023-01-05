import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:exim/constant/colors.dart';
import 'package:exim/models/verifyOTPData_model.dart';
import 'package:exim/screens/dash.dart';
import 'package:exim/screens/login.dart';
import 'package:exim/transitions/slide_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'noInternet.dart';
import 'package:exim/models/loginData_model.dart';

class VerifyOtp extends StatefulWidget {
  final contactNo;
  final devideId;
  final deviceName;
  final mac;
  final imei;
  final token;

  VerifyOtp(
      {this.contactNo,
      this.devideId,
      this.deviceName,
      this.mac,
      this.imei,
      this.token});

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  String _otpValue;
  int secondsRemaining = 30;
  bool enableResend = false;
  Timer timer;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _controllerMobileNo = new TextEditingController();
  bool _isInAsyncCall = false;

  void rebuildPage() {
    setState(() {});
  }

  String contactNo;
  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("*** _isConnected VerifyOTP page Laod = $connectivityResult ****");
      Navigator.push(context, SlideLeftRoute(page: NoInternetPage()));
      /*Navigator.push(context,
          MaterialPageRoute(builder: (context) => NoInternetPage()));*/
    } else if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      print("*** _isConnected VerifyOTP page Laod = $connectivityResult ****");
      setState(() {
        contactNo = prefs.getString('MobileNumber');
      });
    }
  }

  int index = 0;
  VerifyDataModel _verifyOTPResult;
  String statusCode;
  Future<VerifyDataModel> verifyOTP(String otp) async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      String _API_Path = _prefs.getString('API_Path');
      String _EmpCode = _prefs.getInt('EmpCode').toString();
      String _DeviceId = _prefs.getString('DeviceId');

      debugPrint('Check verifyOTP _API_Path $_API_Path ');
      final String apiUrl = "$_API_Path/Authentication/ValidateOTP";
      debugPrint('Check verifyOTP otp $otp ');
      debugPrint('Check verifyOTP _EmpCode $_EmpCode ');
      debugPrint('Check verifyOTP _DeviceId $_DeviceId ');
      debugPrint('Check verifyOTP 1 ');
      debugPrint('Check verifyOTP apiUrl : $apiUrl ');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json'
        },
        body: json.encode(
            {"EmpCode": _EmpCode, "DeviceId": _DeviceId, "EnteredOTP": otp}),
      );
      debugPrint('Check verifyOTP 2');
      if (response.statusCode == 200) {
        debugPrint('Check verifyOTP 3');
        setState(() {
          statusCode = "200";
        });
        final String responseString = response.body;
        debugPrint('Check verifyOTP 4');
        debugPrint('Check verifyOTP responseString : $responseString');

        return verifydataModelFromJson(responseString);
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
        debugPrint('Check verifyOTP 5');

        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  _displaySnackBarExe(BuildContext context, String exe) {
    final snackBar = SnackBar(
        content: Text(
      exe,
      style: TextStyle(fontSize: 20),
    ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<LoginDataModel> resentOtp(
    String contactNo,
    String devideId,
    String deviceName,
    String mac,
    String imei,
    String token,
  ) async {
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
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json'
        },
        body: json.encode({
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
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
    super.initState();
  }

  void _resendCode() {
    //other code here
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
      resentOtp(widget.contactNo, widget.devideId, widget.deviceName,
          widget.mac, widget.imei, widget.token);
    });
  }

  @override
  dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);

    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: () {
          //on Back button press, you can use WillPopScope for another purpose also.
          // Navigator.pop(context); //return data along with pop
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (context) => LoginPage(onPressed: rebuildPage)));
          return new Future(
              () => false); //onWillPop is Future<bool> so return false
        },
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
                      SizedBox(
                        height: 325,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white,
                              boxShadow: [
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Form(
                                  key: _formStateKey,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 30),
                                        Text(
                                          "OTP VERIFICATION",
                                          style: TextStyle(
                                              fontSize: 28,
                                              color: appColor,
                                              fontFamily: "AlternateGothic",
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 2),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          "Enter the OTP sent to",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black45,
                                              letterSpacing: 0.5),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "+91 $contactNo",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: "Poppins",
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              letterSpacing: 0.5),
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15, left: 15),
                                          child: PinCodeTextField(
                                            appContext: context,
                                            length: 4,
                                            // obscureText: false,
                                            // animationType: AnimationType.fade,
                                            pinTheme: PinTheme(
                                                shape: PinCodeFieldShape.box,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                fieldHeight: 50,
                                                fieldWidth: 50,
                                                activeFillColor: appBgColor,
                                                inactiveColor: Colors.blueGrey,
                                                activeColor: Colors.white,
                                                selectedColor: Colors.white,
                                                inactiveFillColor: Colors.white,
                                                selectedFillColor: Colors.grey),
                                            // animationDuration: Duration(milliseconds: 300),
                                            backgroundColor: Colors.white,
                                            textStyle: TextStyle(
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                                fontSize: 22,
                                                letterSpacing: 2),
                                            enableActiveFill: true,
                                            onChanged: (pin) {
                                              print("Changed: " + pin);
                                            },
                                            onCompleted: (pin) {
                                              print("Completed: " + pin);
                                              _otpValue = pin;
                                            },
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9]')),
                                            ],
                                            beforeTextPaste: (text) {
                                              print("Allowing to paste $text");
                                              //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                              //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                              return true;
                                            },
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                      "Don’t receive the OTP?",
                                                      style: TextStyle(
                                                          color: Colors.black45,
                                                          fontFamily: "Poppins",
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16,
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          letterSpacing: 0.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // ArgonTimerButton(
                                              //   elevation: 0,
                                              //   initialTimer: 30, // Optional
                                              //   height: 40,
                                              //   width: 120,
                                              //   minWidth: MediaQuery.of(context)
                                              //           .size
                                              //           .width *
                                              //       0.30,
                                              //   color: Colors.white,
                                              //   borderRadius: 5.0,
                                              //   child: Text(
                                              //     "Resend OTP",
                                              //     style: TextStyle(
                                              //             color: Colors.black,
                                              //             fontFamily: "Poppins",
                                              //             fontWeight: FontWeight.w500,
                                              //             fontSize: 16,
                                              //             fontStyle: FontStyle.normal,letterSpacing: 0.5
                                              //           ),
                                              //   ),
                                              //   loader: (timeLeft) {
                                              //     return Text(
                                              //       "Wait | $timeLeft",
                                              //       style: TextStyle(
                                              //           color: Colors.black,
                                              //           fontSize: 18,
                                              //           fontWeight:
                                              //               FontWeight.w700),
                                              //     );
                                              //   },
                                              //   onTap: (startTimer, btnState) {
                                              //     if (btnState ==
                                              //         ButtonState.Idle) {
                                              //       startTimer(30);
                                              //       resentOtp(widget.contactNo,widget.devideId,widget.deviceName,widget.mac,widget.imei,widget.token);
                                              //     }
                                              //   },
                                              // ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        InkWell(
                                          onTap: enableResend  ? ()  async {
                                            _resendCode();
                                          }:null,
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 5,top: 5),
                                            width: 130,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(5)),
                                              border: Border.all(width: 1,color: enableResend ?Colors.black : Colors.grey,)
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  "RESEND OTP",
                                                  style: TextStyle(
                                                      color: enableResend ?Colors.black : Colors.grey,
                                                      fontFamily: "Poppins",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      letterSpacing: 0.5),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'after $secondsRemaining seconds',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),
                      //second item in the column is a transparent space of 20
                    ],
                  ),
                  //for the button i create another column
                  Column(children: <Widget>[
                    //first element in column is the transparent offset
                    Container(height: 620.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          if (_formStateKey.currentState.validate()) {
                            _formStateKey.currentState.save();

                            var connectivityResult =
                                await (Connectivity().checkConnectivity());
                            if (connectivityResult == ConnectivityResult.none) {
                              print(
                                  "*** _isConnected VerifyOTP btn = $connectivityResult ****");
                              Navigator.push(context,
                                  SlideLeftRoute(page: NoInternetPage()));
                            } else if (connectivityResult ==
                                    ConnectivityResult.wifi ||
                                connectivityResult ==
                                    ConnectivityResult.mobile) {
                              print(
                                  "*** _isConnected VerifyOTP btn = $connectivityResult ****");

                              setState(() {
                                _isInAsyncCall = true;
                              });
                              final String otp = _otpValue;
                              // final String otp = "9999";
                              debugPrint('otp : $otp');

                              debugPrint('1');

                              final VerifyDataModel result =
                                  await verifyOTP(otp);
                              debugPrint('2');

                              setState(() {
                                _verifyOTPResult = result;
                              });
                              debugPrint('result : $result');

                              debugPrint(
                                  '_verifyOTPResult : $_verifyOTPResult');

                              debugPrint('3');

                              if (statusCode == "200") {
                                String Status =
                                    "${_verifyOTPResult.Data[index].Status.toString()}";

                                if (Status == "1") {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setInt('MC_EmpCode',
                                      _verifyOTPResult.Data[index].MC_EmpCode);
                                  prefs.setString('Token',
                                      _verifyOTPResult.Data[index].Token);
                                  prefs.setString('Username',
                                      _verifyOTPResult.Data[index].Username);
                                  prefs.setInt(
                                      'ReadOnlyUser',
                                      _verifyOTPResult
                                          .Data[index].ReadOnlyUser);

                                  debugPrint(
                                      'Check 2.1 MC_EmpCode  : ${_verifyOTPResult.Data[index].MC_EmpCode}');
                                  debugPrint(
                                      'Check 2.1 Token : ${_verifyOTPResult.Data[index].Token}');
                                  debugPrint(
                                      'Check 2.1 Username : ${_verifyOTPResult.Data[index].Username}');
                                  debugPrint(
                                      'Check 2.1 ReadOnlyUser : ${_verifyOTPResult.Data[index].ReadOnlyUser}');
                                  debugPrint('4.1');

                                  debugPrint(
                                      '****************************************');
                                  setState(() {
                                    _isInAsyncCall = false;
                                  });
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              DashPage()));
                                }
                                if (Status == "0") {
                                  debugPrint('_displaySnackBarExe **');
                                  String exe =
                                      _verifyOTPResult.Data[index].Message;
                                  setState(() {
                                    _isInAsyncCall = false;
                                  });
                                  _displaySnackBarExe(context, exe);
                                }
                              } else {
                                debugPrint('***');
                                String exe =
                                    _verifyOTPResult.Data[index].Message;
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
                  ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
