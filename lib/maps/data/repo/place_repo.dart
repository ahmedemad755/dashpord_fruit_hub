
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fruitesdashboard/maps/data/models/placesugestion.dart';
import 'package:fruitesdashboard/maps/data/web/place_web_servises.dart';
import 'package:fruitesdashboard/maps/presentation/widgets/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapsRepository {
  final PlacesWebservices placesWebservices;

  MapsRepository(this.placesWebservices);

  /// جلب الاقتراحات وتحويلها لموديلات
  Future<List<PlaceSuggestion>> fetchSuggestions(
      String place, String sessionToken) async {
    final suggestions =
        await placesWebservices.fetchSuggestions(place, sessionToken);

    // التعديل هنا: بندخل جوه كل عنصر ونبعت 'placePrediction' للموديل
    return suggestions
        .map((suggestion) => PlaceSuggestion.fromAutocompleteJson(suggestion['placePrediction']))
        .toList();
  }

  /// جلب تفاصيل المكان (اللوكيشن) بناءً على الـ ID
 Future<Place> getPlaceLocation(String placeId, String sessionToken) async {
  final placeData = await placesWebservices.getPlaceLocation(placeId, sessionToken);
  
  // 2. استخدم Place.fromJson (الموديل اللي هندلناه سوا)
  return Place.fromJson(placeData);
}

Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final directions = await placesWebservices.getDirections(origin, destination);
    
    // التعديل هنا: بننادي الكلاس مباشرة بدون إنشاء متغير (Instance)
    List<PointLatLng> result = PolylinePoints.decodePolyline(
      directions['routes'][0]['overview_polyline']['points'],
    );

    return result.map((point) => LatLng(point.latitude, point.longitude)).toList();
  }

//   // داخل MapsRepository
// Future<Map<String, dynamic>> getDirections(LatLng origin, LatLng destination) async {
//   final directions = await placesWebservices.getDirections(origin, destination);
  
//   // فك التشفير للنقاط (كما فعلنا سابقاً)
//   List<PointLatLng> result = PolylinePoints.decodePolyline(
//     directions['routes'][0]['overview_polyline']['points'],
//   );

//   // جلب النص المقروء للمسافة (مثلاً: "5.2 km")
//   String distanceText = directions['routes'][0]['legs'][0]['distance']['text'];
//   // جلب الوقت المتوقع (مثلاً: "12 mins")
//   String durationText = directions['routes'][0]['legs'][0]['duration']['text'];

//   return {
//     'points': result.map((point) => LatLng(point.latitude, point.longitude)).toList(),
//     'distance': distanceText,
//     'duration': durationText,
//   };
// }


}