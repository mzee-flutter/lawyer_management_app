import 'package:flutter/foundation.dart';
import 'package:right_case/models/client_models/client_model.dart';
import 'package:right_case/repository/client_repository/client_archived_list_repo.dart';

class ClientArchivedListViewModel with ChangeNotifier {
  final ClientArchivedListRepo _clientArchivedListRepo =
      ClientArchivedListRepo();

  /// Pagination
  int _page = 1;
  final int _size = 10;

  /// Client list
  final List<ClientModel> _archiveClientList = [];
  List<ClientModel> get archiveClientList => _archiveClientList;

  /// Loading flags
  bool isFirstLoading = false; // for initial page
  bool isMoreLoading = false; // for load more
  bool hasMore = true; // if backend still has more data

  Future<void> fetchArchivedClients({bool loadMore = false}) async {
    if (loadMore) {
      if (isMoreLoading || !hasMore) return;
      isMoreLoading = true;
    } else {
      // reset state for first load
      _page = 1;
      hasMore = true;
      _archiveClientList.clear();
      isFirstLoading = true;
    }
    notifyListeners();

    try {
      final clients = await _clientArchivedListRepo.fetchArchivedClients(
        page: _page,
        size: _size,
      );

      if (clients.isEmpty) {
        hasMore = false;
      } else {
        _archiveClientList.addAll(clients);
        _page++;
      }
    } catch (e) {
      debugPrint("Error in ClientArchivedListViewModel: $e");
    } finally {
      if (loadMore) {
        isMoreLoading = false;
      } else {
        isFirstLoading = false;
      }
      notifyListeners();
    }
  }
}
