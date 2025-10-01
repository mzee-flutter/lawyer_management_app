import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/repository/client_repository/client_archive_repo.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

class ClientArchiveViewModel with ChangeNotifier {
  final ClientArchiveRepo _clientArchiveRepo = ClientArchiveRepo();

  Future<void> archiveClient(context, String id) async {
    try {
      final dbClient = await _clientArchiveRepo.archiveClient(id);

      Provider.of<ClientListViewModel>(context, listen: false)
          .archiveClient(dbClient);
    } catch (e) {
      debugPrint("Error in ClientArchiveViewModel: $e");
    }
  }
}
