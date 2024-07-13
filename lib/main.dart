import 'package:app_diem_danh/homescreen.dart';
import 'package:app_diem_danh/loginscreen.dart';
import 'package:app_diem_danh/model/user.dart';
import 'package:app_diem_danh/teacherHomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const KeyboardVisibilityProvider(
          child: AuthCheck(),
      ),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  void _getCurrentUser() async {
    sharedPreferences = await SharedPreferences.getInstance();

    try {
      if (sharedPreferences.getString('studentId') != null) {
        setState(() {
          User.studentId = sharedPreferences.getString('studentId')!;
          userAvailable = true;

          // Lấy và kiểm tra vai trò
          String role = sharedPreferences.getString('role') ?? ''; // Đảm bảo xử lý trường hợp null
          if (role == 'Teacher') {
            // Nếu vai trò là giáo viên, chuyển hướng đến TeacherHomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeacherHomeScreen()),
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        userAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return userAvailable ? const HomeScreen() : const LoginScreen();
  }
}

