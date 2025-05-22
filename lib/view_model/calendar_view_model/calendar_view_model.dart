import 'package:flutter/cupertino.dart';

class CalendarViewModel with ChangeNotifier {
  DateTime _focusDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime get focusDay => _focusDay;
  DateTime? get selectedDay => _selectedDay;

  void selectDay(DateTime selectedDay, DateTime focusDay) {
    _selectedDay = selectedDay;
    _focusDay = focusDay;
    notifyListeners();
  }
}
