import 'package:dio/dio.dart';
import 'package:fruitesdashboard/maps/constnats/sitting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacesWebservices {
  late Dio dio;

  PlacesWebservices() {
    BaseOptions options = BaseOptions(
      // الرابط الأساسي للإصدار الجديد
      baseUrl: 'https://places.googleapis.com/v1/',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      receiveDataWhenStatusError: true,
    );
    dio = Dio(options);
  }

  /// 1. جلب مقترحات الأماكن (Autocomplete New - POST)
  Future<List<dynamic>> fetchSuggestions(String place, String sessionToken) async {
    try {
      // إعدادات الـ Header المطلوبة للـ API الجديد
      dio.options.headers = {
        'X-Goog-Api-Key': googleAPIKey,
        'X-Goog-FieldMask': 'suggestions.placePrediction.text.text,suggestions.placePrediction.placeId',
        'Content-Type': 'application/json',
      };

      final response = await dio.post(
        'places:autocomplete',
        data: {
          "input": place,
          "includedRegionCodes": ["eg"], // قصر النتائج على مصر
          "languageCode": "ar",
          "sessionToken": sessionToken,
        },
      );

      print("Suggestions Status: ${response.statusCode}");
      // الـ Key الجديد هو suggestions وليس predictions
      return response.data['suggestions'] ?? [];
    } catch (error) {
      print("Autocomplete Error: $error");
      return [];
    }
  }

  /// 2. جلب إحداثيات مكان محدد (Place Details New - GET)
  Future<dynamic> getPlaceLocation(String placeId, String sessionToken) async {
    try {
      // الـ FieldMask هنا يحدد أننا نريد الـ Location والـ Viewport فقط لتوفير التكلفة
      dio.options.headers = {
        'X-Goog-Api-Key': googleAPIKey,
        'X-Goog-FieldMask': 'id,location,viewport,formattedAddress',
      };

      // ملاحظة: الرابط يختلف في الإصدار الجديد
      Response response = await dio.get('places/$placeId');
      
      return response.data;
    } catch (error) {
      return Future.error("Place location error: $error");
    }
  }

  /// 3. جلب المسارات ورسم الطريق (Directions API - GET)
  /// هذا الـ API لا يزال يعمل بنظام الـ GET التقليدي
  Future<dynamic> getDirections(LatLng origin, LatLng destination) async {
    try {
      // الـ Directions تتبع URL مختلف عن Places v1، لذا نستخدم الرابط الكامل
      Response response = await dio.get(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': googleAPIKey,
        },
      );
      
      print("Directions Status: ${response.statusCode}");
      return response.data;
    } catch (error) {
      return Future.error("Directions error: $error");
    }
  }
}