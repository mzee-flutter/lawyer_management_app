import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:right_case/repository/client_repository/client_permanent_delete_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

class ClientPermanentDeleteViewModel with ChangeNotifier {
  final ClientPermanentDeleteRepo _permanentDeleteRepo =
      ClientPermanentDeleteRepo();

  Future<void> deleteClientPermanent(context, String id) async {
    try {
      final dbClient = await _permanentDeleteRepo.deleteClient(id);

      Provider.of<ClientListViewModel>(context, listen: false)
          .removeClient(dbClient);
      SnakeBars.flutterToast("Client deleted successfully", context);
    } catch (e) {
      SnakeBars.flutterToast(e.toString(), context);
      debugPrint("Error in ClientPermanentDeleteViewModel: $e");
    }
  }
}
