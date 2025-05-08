// screens/clients/clients_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/client_view_model.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientVM = context.watch<ClientViewModel>();
    final nameController = TextEditingController();
    final contactController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: ListView.builder(
        itemCount: clientVM.clients.length,
        itemBuilder: (context, index) {
          final client = clientVM.clients[index];
          return ListTile(
            title: Text(client.name),
            subtitle: Text(client.contact),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Add Client"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: contactController,
                    decoration: const InputDecoration(labelText: 'Contact')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  clientVM.addClient(
                      nameController.text, contactController.text);
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
