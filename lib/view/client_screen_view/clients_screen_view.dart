import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/client_info_card.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  void initState() {
    final clientListVM =
        Provider.of<ClientListViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clientListVM.fetchClientList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.grey.shade300,
        title: const Text('Clients'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Clients...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            Consumer<ClientListViewModel>(
              builder: (BuildContext context, clientListVM, Widget? child) {
                if (clientListVM.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (clientListVM.clientList.isEmpty) {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 100.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle),
                          child: Icon(
                            Icons.group_off_outlined,
                            size: 40,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Client Not Found',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12.r),
                    child: ListView.builder(
                        itemCount: clientListVM.clientList.length,
                        itemBuilder: (context, index) {
                          final client = clientListVM.clientList[index];
                          return ClientInfoCard(client: client);
                        }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey.shade800,
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.addClientScreen);
        },
        icon: const Icon(
          Icons.person_add,
          color: Colors.white,
        ),
        label: const Text(
          'Add Client',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
