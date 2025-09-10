import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view_model/calendar_view_model/calendar_view_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // DateTime _focusedDay = DateTime.now();
  // DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: const Text('Calendar'),
      ),
      body: Consumer<CalendarViewModel>(
        builder: (context, calendarVM, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: calendarVM.focusDay,
                selectedDayPredicate: (day) =>
                    isSameDay(calendarVM.selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  calendarVM.selectDay(selectedDay, focusedDay);

                  // You can show tasks or hearings for this day
                  // Navigator.push to day details page if needed
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (calendarVM.selectedDay != null)
                Text(
                  "Selected Day: ${DateFormat.yMMMd().format(calendarVM.selectedDay!.toLocal())}",
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          );
        },
      ),
    );
  }
}
