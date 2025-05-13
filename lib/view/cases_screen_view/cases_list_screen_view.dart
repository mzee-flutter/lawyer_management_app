// screens/cases/cases_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../view_model/case_view_model.dart';

class CasesListScreen extends StatelessWidget {
  const CasesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseVM = context.watch<CaseViewModel>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final clientIdController = TextEditingController();
    final statusController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cases"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: ListView.builder(
        itemCount: caseVM.cases.length,
        itemBuilder: (context, index) {
          final caseItem = caseVM.cases[index];
          return ListTile(
            title: Text(caseItem.title),
            subtitle: Text(caseItem.status),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade800,
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Add Case"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: descController,
                    decoration:
                        const InputDecoration(labelText: 'Description')),
                TextField(
                    controller: clientIdController,
                    decoration: const InputDecoration(labelText: 'Client ID')),
                TextField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: 'Status')),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  caseVM.addCase(titleController.text, descController.text,
                      clientIdController.text, statusController.text);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cases_rounded, color: Colors.white),
                label: const Text(
                  'Add Case',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
        icon: const Icon(Icons.cases_rounded, color: Colors.white),
        label: const Text(
          'Add Case',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
