import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Event {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  Event(this.title, this.description, this.startTime, this.endTime);
}

class TeacherEventScreen extends StatefulWidget {
  const TeacherEventScreen({Key? key});

  @override
  State<TeacherEventScreen> createState() => _TeacherEventScreenState();
}

class _TeacherEventScreenState extends State<TeacherEventScreen> {
  TimeOfDay selectedTimeOfDay = TimeOfDay.now();
  Color primary = const Color.fromRGBO(80, 89, 201, 1);
  DateTime today = DateTime.now();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime startTime = DateTime.now();
  DateTime endTime = DateTime.now();
  List<Event> events = [];
  List<DateTime> daysWithEvents = [];
  Map<DateTime, List<Widget>> eventIcons = {};

  // Initialize Firebase
  @override
  void initState() {
    super.initState();
    _loadEventsFromFirestore();
  }

  Future<void> _loadEventsFromFirestore() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Calendar').get();

    final loadedEvents = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title'] as String;
      final description = data['description'] as String;
      final startTime = (data['startTime'] as Timestamp).toDate();
      final endTime = (data['endTime'] as Timestamp).toDate();

      eventIcons[startTime] = [Icon(Icons.event, color: Colors.red)]; // Sử dụng biểu tượng hình sao màu đỏ// Sử dụng biểu tượng hình sao màu đỏ

      daysWithEvents.add(startTime);


      return Event(title, description, startTime, endTime);
    }).toList();

    setState(() {
      events = loadedEvents;
    });
  }

  List<Event> eventsForSelectedDate(DateTime selectedDate) {
    return events.where((event) =>
    event.startTime.year == selectedDate.year &&
        event.startTime.month == selectedDate.month &&
        event.startTime.day == selectedDate.day).toList();
  }

  void _onDaySelected(DateTime day, DateTime focusDay) {
    setState(() {
      today = day;
    });
  }

  void updateTime(TimeOfDay newTime) {
    setState(() {
      selectedTimeOfDay = newTime;
    });
  }

  void _deleteEvent(Event event) {
    setState(() {
      events.remove(event);
    });
  }

  Future<void> _showEventDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm lịch học'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Tên'),
                style: TextStyle(
                  fontFamily: "LexendBold",
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return ListTile(
                    title: Text(
                        'Bắt Đầu: ${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            startTime = DateTime(
                              today.year,
                              today.month,
                              today.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      },
                      child: Icon(Icons.more_time),
                    ),
                  );
                },
              ),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return ListTile(
                    title: Text(
                        'Kết thúc: ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            endTime = DateTime(
                              today.year,
                              today.month,
                              today.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      },
                      child: Icon(Icons.more_time),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text;
              final description = descriptionController.text;
              final event = Event(title, description, startTime, endTime);

              FirebaseFirestore.instance.collection('Calendar').add({
                'title': event.title,
                'description': event.description,
                'startTime': event.startTime,
                'endTime': event.endTime,
              });

              events.add(event);
              titleController.clear();
              descriptionController.clear();
              setState(() {
                startTime = DateTime.now();
                endTime = DateTime.now();
              });
              Navigator.of(context).pop();
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch dạy',
            style:TextStyle(
                fontFamily: "LexendBold"
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              locale: "en_US",
              focusedDay: today,
              rowHeight: 55,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 18.0),
                formatButtonTextStyle: TextStyle(fontSize: 14.0),
              ),

              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, today),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              onDaySelected: _onDaySelected,
              eventLoader: (day) {
                if (daysWithEvents.contains(day)) {
                  // Nếu ngày có sự kiện, trả về danh sách sự kiện cho ngày đó
                  return eventsForSelectedDate(day);
                }
                return []; // Trả về null nếu không có sự kiện nào
              },
            ),
            SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 32),
              height: 200,
              width: 320,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              padding: EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Lịch dạy ngày ${today.day}/${today.month}/${today.year}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (eventsForSelectedDate(today).isEmpty)
                    Center(child: Text('Lịch học trống')),
                  for (var event in eventsForSelectedDate(today))
                    ListTile(
                      title: Text(event.title),
                      subtitle: Text(
                          '${event.startTime.hour.toString().padLeft(2, '0')}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour.toString().padLeft(2, '0')}:${event.endTime.minute.toString().padLeft(2, '0')}'
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        alignment: Alignment.centerRight,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Xác nhận xóa lịch học',
                                  style: TextStyle(
                                      fontFamily: "LexendBold",
                                      fontSize: 20,
                                      color: primary
                                  )),
                              content: Text('Bạn có chắc chắn muốn xóa ?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteEvent(event);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
