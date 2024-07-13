import 'dart:convert';
import 'package:app_diem_danh/homescreen.dart';
import 'package:app_diem_danh/resetPasswordScreen.dart';
import 'package:app_diem_danh/signupscreen.dart';
import 'package:app_diem_danh/teacherHomeScreen.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color.fromRGBO(80, 89, 201, 1);
  Color primary1 = const Color(0xffeef444c);
  late SharedPreferences sharedPreferences;
  bool _obscure = true;
  bool loading = false;
  EmailOTP myauth = EmailOTP();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  String _hashPassword(String password, String salt) {
    final hashedPassword = sha256.convert(utf8.encode('$salt$password')).toString();
    return hashedPassword;
  }

  bool _checkPassword(String enteredPassword, String storedHashedPassword, String salt) {
    final enteredPasswordHash = _hashPassword(enteredPassword, salt);
    return enteredPasswordHash == storedHashedPassword;
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Đã gửi yêu cầu đặt lại mật khẩu vào email của bạn."),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lỗi khi gửi yêu cầu đặt lại mật khẩu."),
      ));
      print(e.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    void toggleObscure(bool newObscure) {
      setState(() {
        _obscure = newObscure;
      });
    }
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: screenHeight / 3.5,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(70),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.library_add_check_rounded,
                    color: Colors.white,
                    size: screenWidth / 4,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: screenHeight / 15,
                  bottom: screenHeight / 20,
                ),
                child: Text(
                  "Đăng Nhập",
                  style: TextStyle(
                    fontSize: screenWidth / 16,
                    fontFamily: "LexendBold",
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth / 12,
                  vertical: screenHeight / 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customFieldId("Mã sinh viên", idController, false),
                    customFieldPass("Mật khẩu", passController, _obscure, toggleObscure),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(top: screenHeight / 300),

                        child: Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            fontFamily: "NexaBold",
                            color: primary1,
                            fontSize: screenWidth / 28,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          loading = true;
                        });

                        String id = idController.text.trim();
                        String password = passController.text.trim();

                        if (id.isEmpty || password.isEmpty) {
                          setState(() {
                            loading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Tài khoản và mật khẩu không được để trống !"),
                          ));
                        } else {
                          try {
                            QuerySnapshot snap = await FirebaseFirestore.instance
                                .collection("User")
                                .where('id', isEqualTo: id)
                                .get();

                            if (snap.docs.isNotEmpty) {
                              String storedHashedPassword = snap.docs[0]['password'];
                              String salt = snap.docs[0]['salt'];

                              if (_checkPassword(password, storedHashedPassword, salt)) {
                                myauth.setConfig(
                                    appEmail: "appdiemdanh@gmail.com",
                                    appName: "Email OTP",
                                    userEmail: snap.docs[0]['email'],
                                    otpLength: 6,
                                    otpType: OTPType.digitsOnly,
                                );
                                // Lấy Device Token hiện tại
                                String? deviceToken = await _firebaseMessaging.getToken();

                                // Lấy Device Token đã lưu trong Firestore khi đăng ký
                                String storedDeviceToken = snap.docs[0]['deviceToken'];

                                print("device " + deviceToken!);
                                print("stored " + storedDeviceToken);

                                // So sánh Device Token
                                if (deviceToken == storedDeviceToken) {
                                  if (await myauth.sendOTP() == true) {
                                    setState(() {
                                      loading = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OtpVerificationScreen(
                                          id: id,
                                          snap: snap,
                                          myauth: myauth,
                                        ),
                                      ),
                                    );
                                  } else {
                                    setState(() {
                                      loading = false;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Oops, OTP send failed"),
                                    ));
                                  }
                                } else {
                                  setState(() {
                                    loading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Tài khoản không được phép đăng nhập trên thiết bị này!"),
                                  ));
                                }
                              } else {
                                setState(() {
                                  loading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Mật khẩu sai !"),
                                ));
                              }
                            } else {
                              setState(() {
                                loading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Mã sinh viên không tồn tại!"),
                              ));
                            }
                          } catch (e) {
                            setState(() {
                              loading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Error occurred!"),
                            ));
                            print(e);
                          }
                        }
                      },
                      child: Container(
                        height: 60,
                        width: screenWidth,
                        margin: EdgeInsets.only(top: screenHeight / 15, bottom: screenHeight / 25),
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius: const BorderRadius.all(Radius.circular(30))),
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              fontFamily: "NexaBold",
                              fontSize: screenWidth / 25,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreeen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Chưa có tài khoản? ',
                          style: TextStyle(
                            fontFamily: "Lexendlight",
                            color: primary,
                            fontSize: screenWidth / 21,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Đăng ký',
                              style: TextStyle(
                                fontFamily: "NexaBold",
                                color: primary1,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth / 21,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "NexaBold",
        ),
      ),
    );
  }

  Widget customFieldId(String hint, TextEditingController controller, bool obscure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 8,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 35,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget customFieldPass(String hint, TextEditingController controller, bool _obscure, Function(bool) onToggle) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 8,
            child: Icon(
              Icons.lock,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 20),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: _obscure,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 35,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                  suffixIcon: IconButton(
                    onPressed: () {
                      onToggle(!_obscure);
                    },
                    icon: (_obscure ? Icon(Icons.visibility) : Icon(Icons.visibility_off)),
                    color: Colors.grey,
                    alignment: Alignment.centerRight,
                  ),
                ),
                maxLines: 1,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  final String id;
  final QuerySnapshot snap;
  final EmailOTP myauth;

  OtpVerificationScreen({required this.id, required this.snap, required this.myauth});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  TextEditingController otpController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Color primary = const Color.fromRGBO(80, 89, 201, 1);
    double screenWidth = 0;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Nhập mã OTP để đăng nhập",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "LexendBold"
                ),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: "Mã OTP",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(primary),

                ),
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });

                  if (await widget.myauth.verifyOTP(otp: otpController.text)) {
                    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                    sharedPreferences.setString('studentId', widget.id).then((_) {
                      String role = widget.snap.docs[0]['role'];
                      if (role == "Teacher") {
                        sharedPreferences.setString('role', role);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TeacherHomeScreen()));
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                      }
                    });
                  } else {
                    setState(() {
                      loading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Mã OTP không đúng!"),
                    ));
                  }
                },
                child: Center(
                  child: Text(
                    "Xác Nhận",
                    style: TextStyle(
                      fontFamily: "NexaBold",
                      fontSize: screenWidth / 25,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

