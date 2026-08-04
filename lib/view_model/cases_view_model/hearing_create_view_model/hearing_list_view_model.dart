import 'package:all/all.dart';
import 'package:flutter/rendering.dart';
import 'package:right_case/models/case_models/hearing_models.dart';
import 'package:right_case/repository/case_repository/hearing_repository/hearing_list_repo.dart';

class HearingListViewModel with ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final HearingListRepo _hearingListRepo = HearingListRepo();

  bool _isButtonIsVisible = true;
  bool get isButtonIsVisible => _isButtonIsVisible;

  List<HearingPublicModel> _hearingList = [];
  List<HearingPublicModel> get hearingList => _hearingList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool loader) {
    _isLoading = loader;
    notifyListeners();
  }

  void addHearingLocally(HearingPublicModel hearing) {
    _hearingList.add(hearing);
    _hearingList.sort((dateTime1, dateTime2) =>
        dateTime1.hearingDateTime.compareTo(dateTime2.hearingDateTime));
    notifyListeners();
  }

  void deleteHearingFromLocal(String hearingId) {
    _hearingList.removeWhere((h) => h.id == hearingId);
    notifyListeners();
  }

  void updateHearing(HearingPublicModel hearing) {
    final index = _hearingList.indexWhere((h) => h.id == hearing.id);
    if (index != -1) {
      _hearingList[index] = hearing;
      notifyListeners();
    }
  }

  Future<void> fetchHearingList(String caseId) async {
    toggleLoading(true);
    try {
      final hearings = await _hearingListRepo.fetchHearingList(caseId);
      _hearingList = hearings;
    } catch (e) {
      debugPrint("Error in HearingListViewModel: $e");
    } finally {
      toggleLoading(false);
    }
  }

  void addListenerToScroll() {
    scrollController.addListener(handleScroll);
  }

  void handleScroll() {
    final direction = scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.idle) return;

    final shouldBeVisible = direction == ScrollDirection.forward;

    if (_isButtonIsVisible != shouldBeVisible) {
      _isButtonIsVisible = shouldBeVisible;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(handleScroll);
    scrollController.dispose();
    super.dispose();
  }
}
