import 'package:app_diem_danh/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary = const Color.fromRGBO(80, 89, 201, 1);
  Color primary1 = const Color(0xffeef444c);

  late SharedPreferences sharedPreferences;
  bool _obscure = true;

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
      body: SingleChildScrollView(
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
                vertical: screenHeight/30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  customFieldId("Tài khoản", idController, false),
                  customFieldPass("Mật khẩu", passController, _obscure, toggleObscure),
                  GestureDetector(
                    onTap: () async {
                      String id = idController.text.trim();
                      String password = passController.text.trim();

                      if (id.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Tài khoản không được để trống !"),
                        ));
                      } else if (password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Mật khẩu không được để trống !"),
                        ));
                      } else {
                        QuerySnapshot snap = await FirebaseFirestore.instance
                            .collection("Student").where('id', isEqualTo: id).get();

                        try{
                          if(password == snap.docs[0]['password']){
                            sharedPreferences = await SharedPreferences.getInstance();

                            sharedPreferences.setString('studentId', id).then((_){
                              Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                            });
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Mật khẩu sai !"),
                            ));
                          }
                        }catch(e){
                          String error = " ";

                          if(e.toString() == "RangeError (index): Invalid value: Valid value range is empty: 0") {
                            setState(() {
                              error = "Mã sinh viên không tồn tại!";
                            });
                          } else {
                            setState(() {
                              error = "Error occurred!";
                            });
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error),
                          ));
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
                  )
                ],
              ),
            ),
          ],
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
  Widget customFieldPass(
      String hint, TextEditingController controller, bool _obscure,Function(bool) onToggle) {
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
                    onPressed: (){
                      onToggle(!_obscure);
                    },
                    icon : (_obscure ? Icon(Icons.visibility) : Icon(Icons.visibility_off)),
                      color:Colors.grey,
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
