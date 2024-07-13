import 'package:app_diem_danh/StudentList.dart';
import 'package:app_diem_danh/calendarscreen.dart';
import 'package:app_diem_danh/eventscreen.dart';
import 'package:app_diem_danh/loginscreen.dart';
import 'package:app_diem_danh/profilescreen.dart';
import 'package:app_diem_danh/services/location_service.dart';
import 'package:app_diem_danh/teacherEventScreen.dart';
import 'package:app_diem_danh/teacherprofilescreen.dart';
import 'package:app_diem_danh/teachertodayscreen.dart';
import 'package:app_diem_danh/todayscreen.dart';
import 'package:app_diem_danh/model/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';


class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primary1 = const Color(0xffeef444c);
  Color primary = const Color.fromRGBO(80, 89, 201, 1);

  int currentIndex = 1;

  List<IconData> navigationIcons = [
    FontAwesomeIcons.list,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();
    getId().then((value) {
      _getCredentials();
      _getProfilePic();
    });
  }

  void _getCredentials() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("User")
          .doc(User.id)
          .get();
      setState(() {
        User.canEdit = doc['canEdit'];
        User.fullName = doc['fullName'];
        User.email = doc['email'];
        User.birthDate = doc['birthDate'];
        User.address = doc['address'];
      });
    } catch (e) {
      return;
    }
  }

  void _getProfilePic() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("User")
        .doc(User.id)
        .get();
    setState(() {
      User.profilePicLink = doc['profilePic'];
    });
  }

  void _startLocationService() async {
    LocationService().initialize();

    LocationService().getLongitude().then((value) {
      setState(() {
        User.long = value!;
      });

      LocationService().getLatitude().then((value) {
        setState(() {
          User.lat = value!;
        });
      });
    });
  }

  Future<void> getId() async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("User")
        .where('id', isEqualTo: User.studentId)
        .get();

    setState(() {
      User.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          new LecturerScreen(),
          new TeacherTodayScreen(),
          new TeacherProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 24,
        ),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2, 3),
              )
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < navigationIcons.length; i++) ...<Expanded>{
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = i;
                        });
                      },
                      child: Container(
                        height: screenHeight,
                        width: screenWidth,
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                navigationIcons[i],
                                color: i == currentIndex ? primary : Colors.black54,
                                size: i == currentIndex ? 30 : 26,
                              ),
                              i == currentIndex
                                  ? Container(
                                margin: EdgeInsets.only(top: 6),
                                height: 3,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(40)),
                                  color: primary,
                                ),
                              )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    )),
              }
            ],
          ),
        ),
      ),
    );
  }
}
