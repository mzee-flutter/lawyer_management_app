import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_case/utils/routes/routes_names.dart';

class CasesListScreen extends StatelessWidget {
  const CasesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cases"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 100.h,
            width: 100.w,
            decoration: BoxDecoration(
                color: Colors.grey.shade300, shape: BoxShape.circle),
            child: Icon(
              Icons.report_problem_rounded,
              size: 40,
              color: Colors.grey.shade500,
            ),
          ),
          Center(
            child: Text(
              'Cases Not Found',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade800,
        icon: const Icon(Icons.cases_rounded, color: Colors.white),
        label: const Text(
          'Add Case',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.addCaseScreen);
        },
      ),
    );
  }
}
