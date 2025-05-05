import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/view/show_add_client_dialog_view.dart';
import 'package:right_case/view_model/client_view_model.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final clientVM = Provider.of<ClientViewModel>(context);
    final filteredClients = _searchQuery.isEmpty
        ? clientVM.clients
        : clientVM.searchClients(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.grey.shade300,
        title: const Text('Clients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Clients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return Card(
                    color: Colors.grey.shade300,
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Icon(
                          Icons.person,
                          color: Colors.black87,
                        ),
                      ),
                      title: Text(client.name),
                      subtitle: Text('Contact: ${client.contact}'),
                      trailing: Text('${client.cases} case(s)'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showAddClientDialog(context);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Client'),
      ),
    );
  }
}
