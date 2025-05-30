import 'package:hive/hive.dart';

part 'client_model.g.dart';

@HiveType(typeId: 0)
class ClientModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? mobileNumber;

  @HiveField(3)
  final String? emailAddress;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final DateTime? createdAt;

  ClientModel({
    required this.id,
    required this.name,
    this.mobileNumber,
    this.emailAddress,
    this.address,
    this.createdAt,
  });
}
