// lib/repositories/court_portal_repository.dart
//
// Follows the exact pattern of AgendaRepository and CalendarRepository.
// Pure HTTP — zero business logic.

import 'package:all/all.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/resources/URLs/case_urls.dart';

import '../../../models/case_models/court_portal_model.dart';

class CourtPortalRepository {
  final BaseApiServices _services = NetworkApiServices();

  // ── Bench Roster ─────────────────────────────────────────────

  Future<BenchRosterModel> getBenchRoster() async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getBenchRoster,
        CaseUrls.headers,
      );
      return BenchRosterModel.fromJson(response);
    } catch (e) {
      debugPrint("ERROR in CourtPortalRepository: ${e.toString()}");
      rethrow;
    }
  }

  // ── Certified Copies ─────────────────────────────────────────

  Future<List<CertifiedCopyModel>> getAllCopies({String? statusFilter}) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getCertifiedCopies(statusFilter: statusFilter),
        CaseUrls.headers,
      );
      final List<dynamic> data = response;

      return data.map((item) => CertifiedCopyModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("ERROR in CourtPortalRepository: ${e.toString()}");
      rethrow;
    }
  }

  Future<List<CertifiedCopyModel>> getCopiesByCase(String caseId) async {
    try {
      final response = await _services.getGetApiRequest(
        CaseUrls.getCopiesByCaseId(caseId),
        CaseUrls.headers,
      );
      final List<dynamic> data = response;

      return data.map((item) => CertifiedCopyModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("ERROR in CourtPortalRepository: ${e.toString()}");
      rethrow;
    }
  }

  Future<CertifiedCopyModel> createCopy({
    required String caseId,
    required String referenceNumber,
    String? description,
  }) async {
    final requestBody = {
      "case_id": caseId,
      "reference_number": referenceNumber,
      if (description != null) "description": description,
    };

    try {
      final response = await _services.getPostApiRequest(
        CaseUrls.createCertifiedCopy,
        CaseUrls.headers,
        requestBody,
      );
      return CertifiedCopyModel.fromJson(response);
    } catch (e) {
      debugPrint("ERROR in CourtPortalRepository: ${e.toString()}");
      rethrow;
    }
  }

  Future<CertifiedCopyModel> advanceStatus({
    required String copyId,
    required String newStatus,
  }) async {
    try {
      final response = await _services.getPatchApiRequest(
        CaseUrls.updateCertifiedCopy(copyId),
        CaseUrls.headers,
        {"status": newStatus},
      );
      return CertifiedCopyModel.fromJson(response);
    } catch (e) {
      debugPrint("ERROR in CourtPortalRepository: ${e.toString()}");
      rethrow;
    }
  }

  Future<CertifiedCopyModel> deleteCopy(String copyId) async {
    try {
      final response = await _services.getDeleteApiRequest(
        CaseUrls.deleteCertifiedCopy(copyId),
        CaseUrls.headers,
      );
      return CertifiedCopyModel.fromJson(response);
    } catch (e) {
      debugPrint("ERROR in CourtPortalRepository: ${e.toString()}");
      rethrow;
    }
  }

  // ── Error handling ──────────────────────────────────────────
}
