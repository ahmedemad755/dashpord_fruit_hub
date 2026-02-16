import 'package:fruitesdashboard/featurs/data/entity/BannerEntity.dart';

class BannerModel extends BannerEntity {
  BannerModel({
    required super.id,
    required super.imageUrl,
    super.targetId,
    required super.linkType,
    required super.isActive,
    required super.createdAt,
  });

  // تحويل البيانات من Firestore JSON إلى Model
  factory BannerModel.fromJson(Map<String, dynamic> json, String documentId) {
    return BannerModel(
      id: documentId,
      imageUrl: json['image_url'] ?? '',
      targetId: json['target_id'],
      linkType: json['link_type'] ?? 'none',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? (json['created_at'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  // تحويل الـ Entity إلى JSON لحفظه في Firestore
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'target_id': targetId,
      'link_type': linkType,
      'is_active': isActive,
      'created_at':
          createdAt, // Firestore بيحول الـ DateTime لـ Timestamp تلقائياً
    };
  }

  // دالة لتحويل الـ Entity لـ Model لو احتاجنا نرفعه
  factory BannerModel.fromEntity(BannerEntity entity) {
    return BannerModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      targetId: entity.targetId,
      linkType: entity.linkType,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}
