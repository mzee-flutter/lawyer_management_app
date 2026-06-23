import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/repository/case_repository/case_permanent_delete_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';

class CasePermanentDeleteViewModel with ChangeNotifier {
  final CasePermanentDeleteRepo _casePermanentDeleteRepo =
      CasePermanentDeleteRepo();

  Future<void> deleteCasePermanent(context, String id) async {
    try {
      final dbCase = await _casePermanentDeleteRepo.deleteCase(id);

      Provider.of<CaseListViewModel>(context, listen: false).removeCase(dbCase);
      SnakeBars.flutterToast("Case deleted successfully", context);
    } catch (e) {
      SnakeBars.flutterToast(e.toString(), context);
      debugPrint("Error in CasePermanentDeleteViewModel: $e");
    }
  }
}
