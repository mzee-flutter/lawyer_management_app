import 'package:flutter/material.dart';

class CustomCasesCategoryView extends StatelessWidget {
  const CustomCasesCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("customCasesCategoryView")),
        body: const Center(child: Text("No cases found.")));
  }
}
