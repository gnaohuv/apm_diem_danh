import 'dart:async';
import 'package:app_diem_danh/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';


class TeacherTodayScreen extends StatefulWidget {
  const TeacherTodayScreen({super.key});

  @override
  State<TeacherTodayScreen> createState() => _TeacherTodayScreenState();
}

class _TeacherTodayScreenState extends State<TeacherTodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  String scanResult = " ";
  String schoolCode = " ";
  double YOUR_TARGET_LAT = 20.9809400673918;
  double YOUR_TARGET_LONG = 105.79560724379446;
  Color primary = const Color(0xffeef444c);
  Color primary1 = const Color.fromRGBO(80, 89, 201, 1);


  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _generateAndSaveSchoolCode() async {
    try {
      setState(() {
        String randomCode = randomAlphaNumeric(6); // Tạo mã ngẫu nhiên
        FirebaseFirestore.instance
            .collection("Attributes")
            .doc("School1")
            .update({'code': randomCode});
        schoolCode = randomCode;
      });
      Timer(Duration(seconds: 10), () {
        FirebaseFirestore.instance
            .collection("Attributes")
            .doc("School1")
            .update({'code': FieldValue.delete()});
        setState(() {
          FirebaseFirestore.instance
              .collection("Attributes")
              .doc("School1")
              .update({'code': ''}); // Cập nhật giá trị schoolCode thành rỗng
        });
      });
    } catch (e) {
      print('$e');
    }
  }
  // void _getSchoolCode() async {
  //   DocumentSnapshot snap = await FirebaseFirestore.instance
  //       .collection("Attributes")
  //       .doc("School1")
  //       .get();
  //   setState(() {
  //     schoolCode = snap['code'];
  //   });
  // }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("User")
          .where('id', isEqualTo: User.studentId)
          .get();
      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("User")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 32),
                  child: Text(
                    "Xin Chào,",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(bottom: 32),
                  child: Text(
                    "Giảng Viên " + User.studentId,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaBold",
                      fontSize: screenWidth / 18,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: DateTime.now().day.toString(),
                      style: TextStyle(
                        color: primary,
                        fontSize: screenWidth / 18,
                        fontFamily: "NexaBold",
                      ),
                      children: [
                        TextSpan(
                            text:
                            DateFormat(' MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth / 20,
                            ))
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 30),
                        child: Text(
                          DateFormat('HH:mm:ss').format(DateTime.now()),
                          style: TextStyle(
                            fontFamily: "NexaRegular",
                            fontSize: screenWidth / 20,
                            color: Colors.black54,
                          ),
                        ),
                      );
                    }),
                ElevatedButton(
                  onPressed: () {

                    _generateAndSaveSchoolCode();
                    _showQRDialog(schoolCode, context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white30, // Màu nền của nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.qrcode,
                        size: 70,
                        color: primary1,
                      ),
                      SizedBox(height: 10),
                      Text('Tạo mã QR',
                        style: TextStyle(
                          fontFamily: "LexendLight",
                          fontSize: screenWidth/23,
                          color: Colors.black54,
                        ),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            )));
  }
}
void _showQRDialog(String data,BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Quét Mã Để Điểm Danh",
          style: TextStyle(
              fontSize: 20,
              fontFamily: "NexaBold"
          ),
          textAlign: TextAlign.center,
        ),
        content: Container(
          height: 200,
          width: 200,
          alignment: Alignment.center,
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Đóng",
              style: TextStyle(
                fontFamily: "NexaBold",
              ),),
          ),
        ],
      );
    },
  );
}
void showOutOfRangeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Lỗi"),
        content: Text("Bạn đang ở quá xa lớp học."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Đóng"),
          ),
        ],
      );
    },
  );
}

void showInvalidQRDialog(BuildContext context) {
  Color primary1 = const Color.fromRGBO(80, 89, 201, 1);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Điểm danh không thành công !",
          style: TextStyle(
            fontFamily: "LexendBold",
            fontSize: 20,
            color: primary1,
          ),
        ),
        content: Text(
          "Mã QR không hợp lệ ! ",
          style: TextStyle(
            fontFamily: "Lexendlight",
            fontSize: 15,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              "Đóng",
              style: TextStyle(
                color: primary1,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
          ),
        ],
      );
    },
  );
}

void showSuccessDialog(BuildContext context) {
  Color primary1 = const Color.fromRGBO(80, 89, 201, 1);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Điểm danh thành công",
            style: TextStyle(
              fontFamily: "LexendBold",
              fontSize: 20,
              color: primary1,
            )),
        actions: <Widget>[
          TextButton(
            child: Text("Đóng"),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
          ),
        ],
      );
    },
  );
}
