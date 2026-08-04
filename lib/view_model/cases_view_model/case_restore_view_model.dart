import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/repository/case_repository/case_restore_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_archived_list_view_model.dart';

class CaseRestoreViewModel with ChangeNotifier {
  final CaseRestoreRepo _caseRestoreRepo = CaseRestoreRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Future<void> restoreCase(BuildContext context, String caseId) async {
    final restoringSnackBar = SnackBar(
      duration: const Duration(minutes: 1),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 18.h,
            width: 18.w,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text("Restoring case..."),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(restoringSnackBar);

    try {
      _toggleLoading(true);

      await _restoreDbCase(context, caseId);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SnakeBars.flutterToast("✅ Case restored successfully", context);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SnakeBars.flutterToast("❌ Failed to restore case: $e", context);
    } finally {
      _toggleLoading(false);
    }
  }

  Future<void> _restoreDbCase(context, String id) async {
    _toggleLoading(true);
    try {
      final dbCase = await _caseRestoreRepo.restoreCase(id);

      Provider.of<CaseArchivedListViewModel>(context, listen: false)
          .removeFromArchived(dbCase);
    } catch (e) {
      debugPrint("Error in CaseRestoreViewModel: $e");
    } finally {
      _toggleLoading(false);
    }
  }
}
