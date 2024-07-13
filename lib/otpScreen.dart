// import 'package:flutter/material.dart';
// import 'package:email_auth/email_auth.dart';
//
// class OtpScreen extends StatefulWidget {
//   final String email;
//   final Function onOtpVerified;
//
//   OtpScreen({required this.email, required this.onOtpVerified});
//
//   @override
//   _OtpScreenState createState() => _OtpScreenState();
// }
//
// class _OtpScreenState extends State<OtpScreen> {
//   TextEditingController _otpController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Nhập Mã OTP'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Mã OTP đã được gửi đến ${widget.email}',
//               style: TextStyle(fontSize: 18.0),
//             ),
//             SizedBox(height: 16.0),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Mã OTP',
//               ),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 _verifyOtp();
//               },
//               child: Text('Xác Thực'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _verifyOtp() async {
//     bool result = await EmailAuth.validateOtp(
//       recipientMail: widget.email,
//       userOtp: _otpController.text,
//     );
//
//     if (result) {
//       // Xác thực thành công
//       widget.onOtpVerified();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text('Mã OTP không đúng. Vui lòng thử lại.'),
//       ));
//     }
//   }
// }
