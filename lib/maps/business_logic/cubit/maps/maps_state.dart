part of 'maps_cubit.dart';

@immutable
abstract class MapsState {}

class MapsInitial extends MapsState {}

// حالة تحميل اقتراحات البحث
class PlacesLoaded extends MapsState {
  final List<PlaceSuggestion> places;

  PlacesLoaded(this.places);
}

// حالة تحميل إحداثيات المكان المختار (الماركر)
class PlaceLocationLoaded extends MapsState {
  final Place place;

  PlaceLocationLoaded(this.place);
}

// حالة تحميل نقاط الطريق (الرسم على الخريطة)
class DirectionsLoaded extends MapsState {
  final List<LatLng> directions; // استقبلنا القائمة الجاهزة للرسم

  DirectionsLoaded(this.directions);
}