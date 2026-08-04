import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/add_related_client_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/repository/case_repository/remove_related_client_repo.dart';

class RelatedClientViewModel with ChangeNotifier {
  final String caseId;

  RelatedClientViewModel({required this.caseId});

  final RemoveRelatedClientRepo _removeRelatedClientRepo =
      RemoveRelatedClientRepo();

  List<RelatedClientModel> _relatedClients = [];
  List<RelatedClientModel> get relatedClients =>
      List.unmodifiable(_relatedClients);

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  String? _lastError;
  String? get lastError => _lastError;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  final Set<String> _selectedClientsIds = {};
  Set<String> get selectedClientsIds => _selectedClientsIds;

  bool isClientBoxIsChecked(String clientId) {
    return _selectedClientsIds.contains(clientId);
  }

  void onCheckBoxChange(bool? isChecked, String clientId) {
    isChecked == true
        ? _selectedClientsIds.add(clientId)
        : _selectedClientsIds.remove(clientId);
    notifyListeners();
  }

  bool isClientAlreadyAdded(String clientId) {
    return _relatedClients.any(
      (rc) => rc.client.id == clientId,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────

  void loadRelatedClientsFromCase(BuildContext context) {
    if (_isInitialized) return;

    final caseData = context.read<CaseListViewModel>().getCaseById(caseId);

    _relatedClients = List.from(caseData?.relatedClients ?? []);
    _isInitialized = true;

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // ADD (OPTIMISTIC)
  // ─────────────────────────────────────────────────────────────

  void addRelatedClientsLocally(
    BuildContext context,
    List<RelatedClientModel> clients,
  ) {
    for (final client in clients) {
      final exists = _relatedClients.any(
        (c) => c.client.id == client.client.id,
      );

      if (!exists) {
        _relatedClients.add(
          client.copyWith(isSynced: false),
        );
      }
    }

    _syncUpward(context);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // REMOVE (SAFE)
  // ─────────────────────────────────────────────────────────────

  Future<bool> removeRelatedClient(
    BuildContext context,
    RelatedClientModel client,
  ) async {
    if (!client.isSynced) return false;

    try {
      await _removeRelatedClientRepo.removeRelatedClient(client.id);

      _relatedClients.removeWhere(
        (c) => c.client.id == client.client.id,
      );

      _syncUpward(context);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Failed to delete related client: $e");
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────
  // SYNC UNSYNCED → SERVER
  // ─────────────────────────────────────────────────────────────

  Future<bool> syncUnSyncedClients(BuildContext context) async {
    if (_isSyncing) return false;

    final unSynced = _relatedClients.where((c) => !c.isSynced).toList();
    if (unSynced.isEmpty) return true;

    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      final requests = unSynced
          .map(
            (c) => RelatedClientRequestModel(
              clientId: c.client.id,
              role: c.role,
            ),
          )
          .toList();

      final serverClients =
          await context.read<AddRelatedClientViewModel>().addRelatedClients(
                caseId: caseId,
                relatedClients: requests,
              );

      _replaceWithServerClients(serverClients);
      _syncUpward(context);
      return true;
    } catch (e) {
      _lastError = "Failed to sync. Check internet connection.";
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _replaceWithServerClients(List<RelatedClientModel> serverClients) {
    for (final serverClient in serverClients) {
      final index = _relatedClients.indexWhere(
        (c) => c.client.id == serverClient.client.id,
      );

      if (index != -1) {
        _relatedClients[index] = serverClient.copyWith(isSynced: true);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPWARD SYNC (SOURCE OF TRUTH)
  // ─────────────────────────────────────────────────────────────

  void _syncUpward(BuildContext context) {
    context.read<CaseListViewModel>().updateRelatedClients(
          caseId: caseId,
          relatedClients: List.unmodifiable(_relatedClients),
        );
  }

  // ─────────────────────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────────────────────

  void reset() {
    _relatedClients.clear();
    _isInitialized = false;
    notifyListeners();
  }

  void resetSelectedClients() {
    _selectedClientsIds.clear();
    notifyListeners();
  }
}
