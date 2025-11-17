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

  factory ReviewModel.fromentity(ReviewEntite entity) {
    return ReviewModel(
      name: entity.name,
      comment: entity.comment,
      rating: entity.rating,
      date: entity.date,
      image: entity.image,
    );
  }

  ///parser json to data
  ///يعني تحويل (json) ل (data)
  ///parsing = تحويل من JSON/String → Object (Model في الكود)
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['name'],
      comment: json['comment'],
      rating: json['rating'],
      date: json['date'],
      image: json['image'],
    );
  }

  ///serilization data to json
  ///يعني تحويل (data) ل (json)
  ///serilization = تحويل من Object (Model في الكود) → JSON/String
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'comment': comment,
      'rating': rating,
      'date': date,
      'image': image,
    };
  }
}
