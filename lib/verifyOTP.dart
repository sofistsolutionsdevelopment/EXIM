import 'package:exim/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtp extends StatefulWidget {
  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();

  String _otpValue;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  _displaySnackBar(BuildContext context) {
    final snackBar = SnackBar(content: Text('Your Contact No is not Registered with us. Please Register yourself.', style: TextStyle(fontSize: 20),));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  final TextEditingController _controllerMobileNo = new TextEditingController();
  bool _isInAsyncCall = false;


  void rebuildPage() {
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);

    return Scaffold(
      key: _scaffoldKey,
      body: WillPopScope(
        onWillPop: (){
          //on Back button press, you can use WillPopScope for another purpose also.
          // Navigator.pop(context); //return data along with pop
          Navigator.of(context)
              .pushReplacement(new MaterialPageRoute(builder: (context) => LoginPage(onPressed: rebuildPage)));
          return new Future(() => false); //onWillPop is Future<bool> so return false
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
                      SizedBox(height: 300,),
                      Align(
                        alignment: Alignment.center,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.white
                            ),
                            child: Container(
                              width: 300.0,
                              height: 320.0,
                              child:   Padding(
                                padding: const EdgeInsets.only(left:35, right:15),
                                child: Form(
                                  key: _formStateKey,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 30),
                                        Text("OTP VERIFICATION", style: TextStyle(fontSize:22,color: Colors.indigo,fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w500,),),
                                        SizedBox(height: 20,),
                                        Text("Enter the OTP send to", style: TextStyle(fontSize:16,fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w500,),),
                                        SizedBox(height: 5,),
                                        Text("+91 9999999999", style: TextStyle(fontSize:20,fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w700,),),
                                        SizedBox(height: 40,),
                                        PinCodeTextField(
                                          length: 4,
                                          // obscureText: false,
                                          // animationType: AnimationType.fade,
                                          pinTheme: PinTheme(
                                              shape: PinCodeFieldShape.box,
                                              borderRadius: BorderRadius.circular(5),
                                              fieldHeight: 50,
                                              fieldWidth: 50,
                                              activeFillColor: Colors.grey,disabledColor:  Colors.yellow,inactiveColor: Colors.blueGrey,activeColor: Colors.white,selectedColor: Colors.white, inactiveFillColor: Colors.white, selectedFillColor: Color(0xff7c4f5f)
                                          ),
                                          // animationDuration: Duration(milliseconds: 300),
                                          backgroundColor: Colors.white,
                                          enableActiveFill: true,
                                          onChanged: (pin) {
                                            print("Changed: " + pin);
                                          },
                                          onCompleted: (pin) {
                                            print("Completed: " + pin);
                                            _otpValue = pin;
                                          },
                                          beforeTextPaste: (text) {
                                            print("Allowing to paste $text");
                                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                                            return true;
                                          },
                                        ),
                                        SizedBox(height: 20,),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: FittedBox(
                                                    fit:BoxFit.fitWidth,
                                                    child: Text(
                                                      "Didn’t Receive the OTP?",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontFamily: "Camphor",
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 20,
                                                        fontStyle: FontStyle.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                /* onTap: () async{
                                                      if (_formStateKey.currentState.validate()) {
                                                        _formStateKey.currentState.save();

                                                      }
                                                    },*/
                                                child: Container(
                                                  child: Align(
                                                    alignment: Alignment.center,
                                                    child: FittedBox(
                                                      fit:BoxFit.fitWidth,
                                                      child: Text(
                                                        "  Resend Code",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily: "Camphor",
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: 20,
                                                          fontStyle: FontStyle.normal,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
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
                            height: 560.0
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: (){
                              if (_formStateKey.currentState.validate()) {
                                _formStateKey.currentState.save();

                                setState(() {
                                  _isInAsyncCall = true;
                                });
                                final String otp = _otpValue;

                                debugPrint('otp : $otp');

                                setState(() {
                                  _isInAsyncCall = false;
                                });

                                /*String API_Path = "http://sofistsolutions.in/MedShortsAPI/API";

                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                prefs.setString('API_Path', API_Path);

                                                final ResultModel result = await validateUser(contactNo, token, imeiNo);
                                                debugPrint('Check Inserted result : $result');
                                                setState(() {
                                                  _result = result;
                                                });

                                                if (_result.Result == "Login Successfully")
                                                {
                                                  String Image_Path = "http://sofistsolutions.in/MedShortsAdmin/Images/";

                                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                                  prefs.setInt('id', _result.Id);
                                                  prefs.setString('contactNo', contactNo);
                                                  prefs.setString('token', token);
                                                  prefs.setString('imeiNo', imeiNo);
                                                  prefs.setString('image_Path', Image_Path);

                                                  debugPrint('SharedPreferences id: ${_result.Id}' );
                                                  debugPrint('SharedPreferences token: ${token}' );
                                                  debugPrint('SharedPreferences imeiNo: ${imeiNo}' );
                                                  _controllerMobileNo.clear();
                                                  _isInAsyncCall = false;
                                                  Navigator.push(context, SlideLeftRoute(page: VerifyOTPPage()));
                                                }
                                                else
                                                {
                                                  debugPrint('**');
                                                  _isInAsyncCall = false;
                                                  _displaySnackBar(context);
                                                }*/
                              }
                            },
                            child: Container(
                              height: 100,
                              width: 250,
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/next_btn.png",
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