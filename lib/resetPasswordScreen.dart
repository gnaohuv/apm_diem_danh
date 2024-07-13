import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  Color primary = const Color.fromRGBO(80, 89, 201, 1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quên mật khẩu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Nhập địa chỉ email của bạn để đặt lại mật khẩu.",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "LexendBold"
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primary),
              ),

              onPressed: () {
                // Gửi yêu cầu đặt lại mật khẩu và hiển thị thông báo
                resetPassword(emailController.text);
              },
              child: Center(
              child: Text(
              "Gửi yêu cầu",
              style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Đã gửi yêu cầu đặt lại mật khẩu vào email của bạn."),
      ));
      // Sau khi gửi yêu cầu, quay trở lại màn hình đăng nhập
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Lỗi khi gửi yêu cầu đặt lại mật khẩu."),
      ));
      print(e.toString());
    }
  }
}
