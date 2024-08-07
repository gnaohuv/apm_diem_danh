import 'dart:io';
import 'package:app_diem_danh/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_diem_danh/loginscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary1 = const Color(0xffeef444c);
  Color primary = const Color.fromRGBO(80, 89, 201, 1);
  String birth = "Date of birth";

  TextEditingController fullNameController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${User.studentId.toLowerCase()}_profilepic.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) async {
      setState(() {
        User.profilePicLink = value;
      });

      await FirebaseFirestore.instance
          .collection("User")
          .doc(User.id)
          .update({
        'profilePic': value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin sinh viên',
            style:TextStyle(
                fontFamily: "LexendBold",
                color: primary
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Container(
            //   alignment: Alignment.centerLeft,
            //   margin: const EdgeInsets.only(top: 20, bottom: 20),
            //   child: Text(
            //     "Thông tin sinh viên",
            //     style: TextStyle(
            //         fontFamily: "LexendBold",
            //         fontSize: screenWidth / 17,
            //         color: primary
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                pickUploadProfilePic();
              },
              child: Container(
                margin: const EdgeInsets.only(top: 20, bottom: 24),
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: primary,
                ),
                child: Center(
                  child: User.profilePicLink == " "
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 80,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(User.profilePicLink),
                        ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Sinh viên ${User.studentId}",
                style: const TextStyle(
                  fontFamily: "NexaBold",
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            User.canEdit
                ? textField("Họ và Tên", "Full name", fullNameController)
                : field("Họ và Tên", User.fullName),
            field("Email", User.email),
            User.canEdit
                ? textField("Lớp", "Class",classController)
                : field("Lớp", User.clasS),
            User.canEdit
                ? GestureDetector(
                    onTap: () {
                      showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: primary,
                                  secondary: primary,
                                  onSecondary: Colors.black87,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                                textTheme: const TextTheme(
                                  headlineMedium: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                  labelSmall: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                  labelLarge: TextStyle(
                                    fontFamily: "NexaBold",
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          }).then((value) {
                        setState(() {
                          birth = DateFormat("dd/MM/yyyy").format(value!);
                        });
                      });
                    },
                    child: field("Ngày sinh", birth),
                  )
                : field("Ngày Sinh", User.birthDate),
            User.canEdit
                ? textField("Địa chỉ", "Address", addressController)
                : field("Địa chỉ", User.address),
            User.canEdit
                ? GestureDetector(
                    onTap: () async {
                      String fullName = fullNameController.text;
                      String clasS = classController.text;
                      String birthDate = birth;
                      String address = addressController.text;


                      if (User.canEdit) {
                        if (fullName.isEmpty) {
                          showSnackBar("Vui lòng điền họ tên !");
                        }
                        else if (clasS.isEmpty){
                          showSnackBar("Vui lòng điền lớp !");
                        } else if (birthDate.isEmpty) {
                          showSnackBar("Vui lòng điền thông tin ngày sinh!");
                        } else if (address.isEmpty) {
                          showSnackBar("Vui lòng điền thông tin địa chỉ!");
                        } else {
                          await FirebaseFirestore.instance
                              .collection("User")
                              .doc(User.id)
                              .update({
                            'fullName': fullName,
                            'class': clasS,
                            'birthDate': birthDate,
                            'address': address,
                            'canEdit': false,
                          }).then((value) {
                            setState(() {
                              User.canEdit = false;
                              User.fullName = fullName;
                              User.clasS = clasS;
                              User.birthDate = birthDate;
                              User.address = address;
                              print("hehe" + clasS);
                              print("huhu" + User.clasS);
                            });
                          });
                        }
                      } else {
                        showSnackBar(
                            "Bạn không được quyền sửa thông tin, vui lòng liên hệ đội ngũ hỗ trợ.");
                      }
                    },
                    child: Container(
                      height: kToolbarHeight,
                      width: screenWidth/1.2,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: primary,
                      ),
                      child: const Center(
                        child: Text(
                          "LƯU",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "LexendBold",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Container(
              margin: const EdgeInsets.only(top: 0),
              alignment: Alignment.center,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Hiển thị hộp thoại xác nhận trước khi thực hiện LogOut
                  showExitConfirmationDialog(context, () async {
                    SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                    sharedPreferences.clear();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  });
                },
                icon: const Icon(Icons.logout),
                label: const Text("Đăng Xuất"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  foregroundColor: primary1,
                  textStyle: TextStyle(
                    fontFamily: "NexaBold",
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget field(String title, String text) {
    Color primary = const Color.fromRGBO(80, 89, 201, 1);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "LexendBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          height: kToolbarHeight,
          width: screenWidth,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(left: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Color.fromRGBO(80, 89, 201, 1),
                fontFamily: "NexaBold",
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textField(
      String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "LexendBold",
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: "NexaBold",
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void showExitConfirmationDialog(BuildContext context, Function onConfirmed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
              'Xác nhận đăng xuất',
            style: TextStyle(
              color: primary,
              fontSize: 20,
              fontFamily: "LexendBold",
            ),
            textAlign: TextAlign.center,
          ),
          content: Text('Bạn có chắc chắn muốn thoát không?',
            style: TextStyle(
              color: Colors.black54,
              fontFamily: "LexendLight",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: Text('Không',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "LexendBold",
                ),),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
                onConfirmed(); // Gọi hàm callback khi người dùng xác nhận
              },
              child: Text('Có',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: "LexendBold",
                ),),
            ),
          ],
        );
      },
    );
  }
}
