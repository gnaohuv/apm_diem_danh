import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'loginscreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class SignUpScreeen extends StatefulWidget {
  const SignUpScreeen({super.key});

  @override
  State<SignUpScreeen> createState() => _SignUpScreeenState();
}

class _SignUpScreeenState extends State<SignUpScreeen> {
  bool loading = false;
  Color primary = const Color.fromRGBO(80, 89, 201, 1);
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;
  bool _obscure1 = true;
  bool _obscure2 = true;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    void toggleObscure1(bool newObscure) {
      setState(() {
        _obscure1 = newObscure;
      });
    }
    void toggleObscure2(bool newObscure) {
      setState(() {
        _obscure2 = newObscure;
      });
    }

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tạo tài khoản",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primary,
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth / 12,
                  vertical: screenHeight / 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    customFieldId("Mã sinh viên", idController, false),
                    customFieldId("Email", emailController, false),
                    customFieldPass(
                        "Mật khẩu", passController, _obscure1, toggleObscure1),
                    customFieldPass(
                        "Xác nhận mật khẩu", confirmPassController, _obscure2, toggleObscure2),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          loading = true;
                        });
                        if (idController.text.isEmpty) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Tài khoản không được để trống."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else if (emailController.text.isEmpty) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email không được để trống."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(emailController.text)) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email không hợp lệ."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        else if (passController.text.length < 6) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Mật khẩu phải có ít nhất 6 kí tự."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else if (!RegExp(r'(?=.*[A-Z])')
                            .hasMatch(passController.text)) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Mật khẩu phải chứa ít nhất một chữ in hoa."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else if (!RegExp(r'(?=.*\d)')
                            .hasMatch(passController.text)) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Mật khẩu phải chứa ít nhất một số."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])')
                            .hasMatch(passController.text)) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Mật khẩu phải chứa ít nhất một kí tự đặc biệt."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        else if (confirmPassController.text.isEmpty) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Trường xác nhận mật khẩu không được để trống."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        else if (passController.text != confirmPassController.text) {
                          setState(() {
                            loading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Xác nhận mật khẩu không trùng khớp."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        else {
                          try {
                            // Tạo salt ngẫu nhiên
                            String salt = _generateRandomSalt();

                            String hashedPassword =
                                _hashPassword(passController.text, salt);

                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password:
                                  hashedPassword,
                            );

                            User? user = FirebaseAuth.instance.currentUser;

                            String deviceToken = await _firebaseMessaging.getToken() ?? '';

                            await FirebaseFirestore.instance
                                .collection('User')
                                .doc(user!.uid)
                                .set({
                              'id': idController.text,
                              'password':
                                  hashedPassword, // Lưu chuỗi hash của mật khẩu
                              'salt': salt,
                              'role': 'Student',
                              'email': emailController.text,
                              'deviceToken': deviceToken,
                              // Thêm các trường thông tin khác nếu cần
                            });

                            // Đăng ký thành công, thực hiện chuyển hướng
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Column(
                                    children: [
                                      Icon(Icons.check_circle, color: primary,size: 50,),
                                      SizedBox(width: 10),
                                      Text("Đăng ký thành công",
                                        style: TextStyle(
                                          fontFamily: "NexaBold",
                                          fontSize: 20
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  content: Text("Bạn đã đăng ký thành công. Hãy đăng nhập để tiếp tục."
                                  ,
                                  style: TextStyle(
                                    fontFamily: "NexaRegular",
                                  ),
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Đóng thông báo
                                        Navigator.of(context).pop();

                                        // Chuyển hướng về màn hình đăng nhập
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginScreen()),
                                        );
                                      },
                                      child: Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );

                          } catch (e) {
                            // Xử lý lỗi từ Firebase và hiển thị thông báo phản hồi cho người dùng
                            setState(() {
                              loading = false;
                            });
                            // Hiển thị thông báo lỗi, ví dụ:
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Đăng ký không thành công. Vui lòng thử lại ."),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: 60,
                        width: screenWidth,
                        margin: EdgeInsets.only(top: screenHeight / 15),
                        decoration: BoxDecoration(
                            color: primary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30))),
                        child: Center(
                          child: Text(
                            "SIGN UP",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateRandomSalt() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
  String _hashPassword(String password, String salt) {
    final hashedPassword =
        sha256.convert(utf8.encode('$salt$password')).toString();
    return hashedPassword;
  }

  Widget customFieldId(
      String hint, TextEditingController controller, bool obscure) {
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

  Widget customFieldPass(String hint, TextEditingController controller,
      bool _obscure, Function(bool) onToggle) {
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
                    icon: (_obscure
                        ? Icon(Icons.visibility)
                        : Icon(Icons.visibility_off)),
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
