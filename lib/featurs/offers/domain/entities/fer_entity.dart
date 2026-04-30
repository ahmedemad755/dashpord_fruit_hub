import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final int discountPercentage;
  final DateTime expiryDate;
  final String pharmacyId;
  final bool isActive;
  final String? targetCategory;

  const OfferEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.expiryDate,
    required this.pharmacyId,
    this.isActive = true,
    this.targetCategory , 
  });

  @override
  List<Object?> get props => [id, title, description, discountPercentage, expiryDate, pharmacyId, isActive];
}