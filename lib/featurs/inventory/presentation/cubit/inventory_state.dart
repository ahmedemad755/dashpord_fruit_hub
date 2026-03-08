import 'package:fruitesdashboard/featurs/inventory/domain/entities/inventory_entity.dart';

abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryEntity> inventoryList;

  InventoryLoaded(this.inventoryList);
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);
}
