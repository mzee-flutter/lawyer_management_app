import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/repository/client_repository/client_restore_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';

class ClientRestoreViewModel with ChangeNotifier {
  final ClientRestoreRepo _clientRestoreRepo = ClientRestoreRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Future<void> handleRestore(BuildContext context, String clientId) async {
    // Show snackbar with spinner
    final restoringSnackBar = SnackBar(
      duration: const Duration(minutes: 1),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 18.w,
            width: 18.w,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Text("Restoring client..."),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(restoringSnackBar);

    try {
      _toggleLoading(true);

      // 👉 call your repository/service here
      await restoreClient(context, clientId);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SnakeBars.flutterToast("Client restored successfully", context);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SnakeBars.flutterToast("Failed to restore client: $e", context);
    } finally {
      _toggleLoading(false);
    }
  }

  Future<void> restoreClient(context, String id) async {
    _toggleLoading(true);
    try {
      final dbClient = await _clientRestoreRepo.restoreClient(id);

      Provider.of<ClientArchivedListViewModel>(context, listen: false)
          .removeFromArchived(dbClient);
    } catch (e) {
      debugPrint("Error in ClientRestoreViewModel: $e");
    } finally {
      _toggleLoading(false);
    }
  }
}
