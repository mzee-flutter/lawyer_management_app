import 'package:flutter/cupertino.dart';

import 'package:right_case/repository/case_repository/hearing_repository/hearing_delete_repo.dart';

class HearingDeleteViewModel with ChangeNotifier {
  final HearingDeleteRepo _hearingDeleteRepo = HearingDeleteRepo();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  Future<void> deleteHearing(context, String hearingId) async {
    toggleLoading(true);
    try {
      await _hearingDeleteRepo.deleteHearing(hearingId);
    } catch (e) {
      debugPrint("Error in HearingDeleteViewModel: $e");
      rethrow;
    } finally {
      toggleLoading(false);
    }
  }
}
