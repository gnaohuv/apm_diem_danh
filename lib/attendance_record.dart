import 'package:intl/intl.dart';

class AttendanceRecord {
  final DateTime date;
  final String checkIn;
  final String checkOut;

  AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
  });
}
