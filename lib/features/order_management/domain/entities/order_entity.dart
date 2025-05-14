import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {

  const OrderEntity({
    required this.id,
    required this.customerName,
    required this.date,
    required this.items,
  });
  final String id;
  final String customerName;
  final DateTime date;
  final List<dynamic> items;

  @override
  List<Object?> get props => [id, customerName, date, items];
}
