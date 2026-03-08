import 'package:fruitesdashboard/featurs/add_product/domain/entities/review_entite.dart';

class ReviewModel {
  final String name;
  final String comment;
  final num rating;
  final String image;
  final String date;

  ReviewModel({
    required this.name,
    required this.comment,
    required this.rating,
    required this.date,
    required this.image,
  });

  // 1️⃣ تحويل من Entity (الواجهة) إلى Model (البيانات)
  factory ReviewModel.fromentity(ReviewEntite entity) {
    return ReviewModel(
      name: entity.name,
      comment: entity.comment,
      rating: entity.rating,
      date: entity.date,
      image: entity.image,
    );
  }

  // 2️⃣ تحويل من JSON (Firestore) إلى Model
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['name'] ?? '',
      comment: json['comment'] ?? '',
      rating: json['rating'] ?? 0,
      date: json['date'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // 3️⃣ تحويل من Model إلى JSON (للحفظ في Firestore)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'comment': comment,
      'rating': rating,
      'date': date,
      'image': image,
    };
  }

  // 🔥 4️⃣ الدالة المفقودة: تحويل من Model إلى Entity (لعرض المراجعات في الـ UI)
  ReviewEntite toEntity() {
    return ReviewEntite(
      name: name,
      comment: comment,
      rating: rating,
      date: date,
      image: image,
    );
  }
}