import 'dart:async';
import 'package:app_diem_danh/model/user.dart';
import 'package:flutter/material.dart';
import 'package:slide_to_act_reborn/slide_to_act_reborn.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  String scanResult = " ";
  String schoolCode = " ";

  Color primary = const Color(0xffeef444c);
  Color primary1 = const Color.fromRGBO(80, 89, 201, 1);

  @override
  void initState() {
    super.initState();
    _getRecord();
    _getSchoolCode();
  }

  void _getSchoolCode() async{

    DocumentSnapshot snap = await FirebaseFirestore
        .instance.collection("Attributes").doc("School1").get();
    setState(() {
      schoolCode = snap['code'];
    });
  }

  Future<void> scanQRRandCheck() async {

    String result = " ";

    try{
      result = await FlutterBarcodeScanner.scanBarcode(
          "#ffffff",
          "Hủy",
          false,
          ScanMode.QR,
      );
    }catch(e){
    print("error");
    }
    setState(() {
      scanResult = result;
    });

    if(scanResult == schoolCode){
      if(User.lat != 0){
        _getLocation();

        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection("Student")
            .where('id', isEqualTo: User.studentId)
            .get();

        DocumentSnapshot snap2 = await FirebaseFirestore.instance
            .collection("Student")
            .doc(snap.docs[0].id)
            .collection("Record")
            .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
            .get();

        try{
          String checkIn = snap2['checkIn'];

          setState(() {
            checkOut = DateFormat('HH:mm').format(DateTime.now());
          });

          await FirebaseFirestore.instance
              .collection("Student")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .update({
            'date' : Timestamp.now(),
            'checkIn' : checkIn,
            'checkOut': DateFormat('HH:mm').format(DateTime.now()),
            'location' : location,
          });

        }catch(e){
          setState(() {
            checkIn = DateFormat('HH:mm').format(DateTime.now());
          });
          await FirebaseFirestore.instance
              .collection("Student")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .set({
            'date' : Timestamp.now(),
            'checkIn' : DateFormat('HH:mm').format(DateTime.now()),
            'checkOut': "--/--",
            'location' : location,
          });
        }
      }
      else{
        Timer(const Duration(seconds: 3), () async {
          _getLocation();

          QuerySnapshot snap = await FirebaseFirestore.instance
              .collection("Student")
              .where('id', isEqualTo: User.studentId)
              .get();

          DocumentSnapshot snap2 = await FirebaseFirestore.instance
              .collection("Student")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .get();

          try{
            String checkIn = snap2['checkIn'];

            setState(() {
              checkOut = DateFormat('HH:mm').format(DateTime.now());
            });

            await FirebaseFirestore.instance
                .collection("Student")
                .doc(snap.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .update({
              'date' : Timestamp.now(),
              'checkIn' : checkIn,
              'checkOut': DateFormat('HH:mm').format(DateTime.now()),
              'checkInLocation' : location,
            });

          }catch(e){
            setState(() {
              checkIn = DateFormat('HH:mm').format(DateTime.now());
            });
            await FirebaseFirestore.instance
                .collection("Student")
                .doc(snap.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .set({
              'date' : Timestamp.now(),
              'checkIn' : DateFormat('HH:mm').format(DateTime.now()),
              'checkOut': "--/--",
              'checkOutLocation' : location,
            });
          }
        });
      }
      showSuccessDialog(context);
    }
    else{
      showInvalidQRDialog(context);
    }
  }


  void _getLocation() async{
    List<Placemark> placemark = await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location = "${placemark[0].street},${placemark[0].administrativeArea},${placemark[0].postalCode}${placemark[0].country}";
    });
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Student")
          .where('id', isEqualTo: User.studentId)
          .get();
      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Student")
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
            child : Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top:32),
                  child: Text(
                    "Xin Chào,",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaRegular",
                      fontSize:screenWidth/20,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sinh Viên " + User.studentId,
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: "NexaBold",
                      fontSize:screenWidth/18,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top:32),
                  child: Text(
                    "Điểm danh hôm nay",
                    style: TextStyle(
                      fontFamily: "LexendBold",
                      fontSize:screenWidth/22,
                      color: primary,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top : 12, bottom:32 ),
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(2,2),
                      ),
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Check In",
                                style: TextStyle(
                                  fontFamily: "NexaRegular",
                                  fontSize: screenWidth/20,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                checkIn,
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: screenWidth/18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Check Out",
                                style: TextStyle(
                                  fontFamily: "NexaRegular",
                                  fontSize: screenWidth/20,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                checkOut,
                                style: TextStyle(
                                  fontFamily: "NexaBold",
                                  fontSize: screenWidth/18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      text: DateTime.now().day.toString(),
                      style: TextStyle(
                        color: primary,
                        fontSize: screenWidth/18,
                        fontFamily: "NexaBold",
                      ),
                      children: [
                        TextSpan(
                            text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth/ 20,
                            )
                        )
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('HH:mm:ss').format(DateTime.now()),
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth/20,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }
                ),
                checkOut == "--/--" ? Container(
                  margin: const EdgeInsets.only(top : 24),
                  child: Builder(
                    builder: (context){
                      final GlobalKey<SlideActionState> key = GlobalKey();
                      return SlideAction(
                        text: checkIn == "--/--" ? "Lướt để Check In" : "Lướt để Check Out",
                        textStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: screenWidth/20,
                          fontFamily: "LexendLight",
                        ),
                        outerColor: Colors.white,
                        innerColor: primary1,
                        key:key,
                        onSubmit: () async {
                          if(User.lat != 0){
                            _getLocation();

                            QuerySnapshot snap = await FirebaseFirestore.instance
                                .collection("Student")
                                .where('id', isEqualTo: User.studentId)
                                .get();

                            DocumentSnapshot snap2 = await FirebaseFirestore.instance
                                .collection("Student")
                                .doc(snap.docs[0].id)
                                .collection("Record")
                                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                .get();

                            try{
                              String checkIn = snap2['checkIn'];

                              setState(() {
                                checkOut = DateFormat('HH:mm').format(DateTime.now());
                              });

                              await FirebaseFirestore.instance
                                  .collection("Student")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .update({
                                'date' : Timestamp.now(),
                                'checkIn' : checkIn,
                                'checkOut': DateFormat('HH:mm').format(DateTime.now()),
                                'location' : location,
                              });

                            }catch(e){
                              setState(() {
                                checkIn = DateFormat('HH:mm').format(DateTime.now());
                              });
                              await FirebaseFirestore.instance
                                  .collection("Student")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .set({
                                'date' : Timestamp.now(),
                                'checkIn' : DateFormat('HH:mm').format(DateTime.now()),
                                'checkOut': "--/--",
                                'location' : location,
                              });
                            }
                            key.currentState!.reset();
                          }
                          else{
                            Timer(const Duration(seconds: 3), () async {
                              _getLocation();

                              QuerySnapshot snap = await FirebaseFirestore.instance
                                  .collection("Student")
                                  .where('id', isEqualTo: User.studentId)
                                  .get();

                              DocumentSnapshot snap2 = await FirebaseFirestore.instance
                                  .collection("Student")
                                  .doc(snap.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                  .get();

                              try{
                                String checkIn = snap2['checkIn'];

                                setState(() {
                                  checkOut = DateFormat('HH:mm').format(DateTime.now());
                                });

                                await FirebaseFirestore.instance
                                    .collection("Student")
                                    .doc(snap.docs[0].id)
                                    .collection("Record")
                                    .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                    .update({
                                  'date' : Timestamp.now(),
                                  'checkIn' : checkIn,
                                  'checkOut': DateFormat('HH:mm').format(DateTime.now()),
                                  'checkInLocation' : location,

                                });

                              }catch(e){
                                setState(() {
                                  checkIn = DateFormat('HH:mm').format(DateTime.now());
                                });
                                await FirebaseFirestore.instance
                                    .collection("Student")
                                    .doc(snap.docs[0].id)
                                    .collection("Record")
                                    .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                                    .set({
                                  'date' : Timestamp.now(),
                                  'checkIn' : DateFormat('HH:mm').format(DateTime.now()),
                                  'checkOut': "--/--",
                                  'checkOutLocation' : location,
                                });
                              }
                              key.currentState!.reset();
                            });
                          }

                        },
                      );
                    },
                  ),
                ) : Container(
                  margin: const EdgeInsets.only(top: 32, bottom: 32),
                  child: Center(
                    child: Text(
                        "Bạn đã hoàn thành điểm danh cho ngày hôm nay !",
                      style: TextStyle(
                        fontFamily: "LexendLight",
                        fontSize: screenWidth/20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                location != " " ? Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Text(
                    "Vị trí :" + location,
                  ),
                ): const SizedBox(
                ),
                GestureDetector(
                  onTap: (){
                    scanQRRandCheck();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 50),
                    height: screenWidth/2,
                    width: screenWidth/2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(2,2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.expand,
                              size: 70,
                              color: primary1,
                            ),
                            Icon(
                              FontAwesomeIcons.camera,
                              size: 25,
                              color: primary1,
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Text(
                            checkIn == "--/--" ? "Quét để Check In":"Quét để Check Out" ,
                            style: TextStyle(
                              fontFamily: "LexendLight",
                              fontSize: screenWidth/23,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }
}
void showInvalidQRDialog(BuildContext context) {
  Color primary1 = const Color.fromRGBO(80, 89, 201, 1);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Điểm danh không thành công !",
        style: TextStyle(
          fontFamily: "LexendBold",
          fontSize: 20,
          color: primary1,
        ),),
        content: Text("Mã QR không hợp lệ ! ",
          style: TextStyle(
            fontFamily: "Lexendlight",
            fontSize: 15,
          ),),
        actions: <Widget>[
          TextButton(
            child: Text("Đóng",
              style: TextStyle(
                color: primary1,
              ),),
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

