import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LecturerScreen extends StatefulWidget {
  @override
  _LecturerScreenState createState() => _LecturerScreenState();
}

class _LecturerScreenState extends State<LecturerScreen> {
  DateTime _selectedDate = DateTime.now();
  String filterType = 'Tất cả';

  Color primary = const Color(0xffeef444c);
  Color primary1 = const Color.fromRGBO(80, 89, 201, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách điểm danh', style: TextStyle(fontFamily: "LexendBold", fontSize: 20, color: primary1)),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Ngày điểm danh: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
              style: TextStyle(fontSize: 16, fontFamily: "NexaBold"),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.0), // Điều chỉnh độ cong của góc theo nhu cầu,
            ),
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(left: 20),
            child: DropdownButton<String>(
              value: filterType,
              onChanged: (String? newValue) {
                setState(() {
                  filterType = newValue!;
                });
              },
              style: TextStyle(color: Colors.blue), // Màu sắc của văn bản trong nút dropdown
              icon: Icon(Icons.arrow_drop_down, color: primary1), // Màu sắc của mũi tên dropdown
              elevation: 16, // Độ nổi bật của dropdown
              underline: Container(
                height: 2,
                color: primary1, // Màu sắc của đường underline
              ),
              items: <String>['Tất cả', 'Đã điểm danh', 'Chưa điểm danh']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: primary1, // Màu sắc của văn bản trong dropdown item
                    ),
                  ),
                );
              }).toList(),
            ),

          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("User").snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 100,
                    ),
                  );
                }
                List<DocumentSnapshot> documents = snapshot.data!.docs;

                List<DocumentSnapshot> filteredDocuments = documents
                    .where((doc) => doc['role'] == 'Student')
                    .toList();

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = filteredDocuments[index];
                    String studentId = document['id'];

                    // FutureBuilder cho dữ liệu điểm danh
                    return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("User")
                          .doc(document.id)
                          .collection("Record")
                          .where('date', isGreaterThanOrEqualTo: _selectedDate)
                          .where('date', isLessThan: _selectedDate.add(Duration(days: 1)))
                          .orderBy('date', descending: true)
                          .limit(1)
                          .get(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> recordSnapshot) {
                        if (recordSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            strokeWidth: 3,
                          );
                        }


                        if (recordSnapshot.hasError) {
                          return Text(
                            'Error: ${recordSnapshot.error}',
                            style: TextStyle(color: Colors.red),
                          );
                        }

                        // Explicit casting from QueryDocumentSnapshot to DocumentSnapshot
                        DocumentSnapshot<Object?>? record = recordSnapshot.data?.docs.isNotEmpty == true
                            ? recordSnapshot.data!.docs.first as DocumentSnapshot<Object?>?
                            : null;

                        bool isPresent = record != null;
                        if ((filterType == 'Tất cả') ||
                            (filterType == 'Đã điểm danh' && isPresent) ||
                            (filterType == 'Chưa điểm danh' && !isPresent)) {
                          String checkIn = isPresent ? record!['checkIn'] as String : 'Chưa điểm danh';
                          String checkOut = isPresent ? record!['checkOut'] as String : '';

                          return Card(
                            elevation: 1,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StudentDetailScreen(studentId: document.id),
                                  ),
                                );
                              },
                              title: Text(
                                '$studentId',
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "NexaBold"),
                              ),
                              subtitle: isPresent
                                  ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Check-In: $checkIn',
                                    style: TextStyle(
                                      color: primary1,
                                      fontFamily: "NexaRegular",
                                    ),
                                  ),
                                  Text(
                                    'Check-Out: $checkOut',
                                    style: TextStyle(
                                      color: primary1,
                                      fontFamily: "NexaRegular",
                                    ),
                                  ),
                                  if (record != null && record['attendancePic'] != null)
                                    Image.network(
                                      record['attendancePic'],
                                      width: 150, // Điều chỉnh kích thước của ảnh theo nhu cầu
                                      height: 150,
                                    ),
                                ],
                              )
                                  : Text(
                                'Chưa điểm danh',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontFamily: "NexaRegular",
                                ),
                              ),
                            ),
                          );

                        } else {
                          return Container(); // Trả về một container rỗng nếu không phù hợp với bộ lọc
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}

class StudentDetailScreen extends StatelessWidget {
  final String studentId;

  StudentDetailScreen({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection("User").doc(studentId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('Không tìm thấy thông tin sinh viên'),
            );
          }

          if (snapshot.data!.data() != null) {
            Map<String, dynamic> userData = snapshot.data!.data()! as Map<String, dynamic>;
            return SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Hình ảnh profile hoặc Icon nếu không có hình ảnh
                      userData['profilePic'] != null
                          ? Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(userData['profilePic']),
                          radius: 80, // Điều chỉnh kích thước của hình ảnh theo nhu cầu
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 100,
                        ),
                      ),
                      ListTileWithIcon(
                        icon: Icons.confirmation_number,
                        title: 'Mã sinh viên',
                        subtitle: '${userData['id']}',
                      ),
                      ListTileWithIcon(
                        icon: Icons.person,
                        title: 'Họ và tên',
                        subtitle: '${userData['fullName']}',
                      ),
                      ListTileWithIcon(
                        icon: Icons.email,
                        title: 'Email',
                        subtitle: '${userData['email']}',
                      ),
                      ListTileWithIcon(
                        icon: Icons.cake,
                        title: 'Ngày sinh',
                        subtitle: '${userData['birthDate']}',
                      ),
                      ListTileWithIcon(
                        icon: Icons.location_on,
                        title: 'Địa chỉ',
                        subtitle: '${userData['address']}',
                      ),
                      ListTileWithIcon(
                        icon: Icons.class_,
                        title: 'Lớp',
                        subtitle: '${userData['class']}',
                      ),
                      // Thêm các thông tin khác của sinh viên tương ứng
                    ],
                  ),
                ),
            );
          } else {
            return Center(
              child: Text('Dữ liệu trống'),
            );
          }
        },
      ),
    );
  }
}

class ListTileWithIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  ListTileWithIcon({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black26),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.blue)),
    );
  }
}



void main() {
  runApp(MaterialApp(
    home: LecturerScreen(),
  ));
}
