import 'package:flutter/material.dart';
import 'package:right_case/models/case_model.dart';
import 'package:right_case/resources/case_info_card.dart';

class CustomCasesCategoryView extends StatelessWidget {
  final String title;
  final List<CaseModel> cases;

  const CustomCasesCategoryView(
      {super.key, required this.title, required this.cases});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: cases.isEmpty
          ? const Center(child: Text("No cases found."))
          : ListView.builder(
              itemCount: cases.length,
              itemBuilder: (context, index) {
                return CaseInfoCard(clientCase: cases[index]);
              },
            ),
    );
  }
}
