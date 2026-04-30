import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  final LatLng? location; // خليناه Nullable لأن الاقتراحات أحياناً بتيجي من غير إحداثيات في الأول

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.location,
  });

  // 1. Factory لعمل Map من الـ JSON اللي راجع من الـ Autocomplete (النتائج المتعددة)
  factory PlaceSuggestion.fromAutocompleteJson(Map<String, dynamic> json) {
    // نركز في المسار اللي شفناه في بوستمان: suggestions -> placePrediction
    return PlaceSuggestion(
      placeId: json['placeId'] ?? '',
      description: json['text']['text'] ?? '',
      // الـ Autocomplete New مبيبعتش لوكيشن في العادي، بيبعت مكان بس
      location: null, 
    );
  }

  // 2. Factory لعمل Map من الـ JSON اللي راجع من الـ Place Details (لما تختار مكان معين)
  factory PlaceSuggestion.fromPlaceDetailsJson(Map<String, dynamic> json) {
    final locationData = json['location'];
    return PlaceSuggestion(
      placeId: json['id'] ?? '',
      description: json['formattedAddress'] ?? '', // أو أي حقل عنوان راجع
      location: locationData != null 
          ? LatLng(locationData['latitude'], locationData['longitude'])
          : null,
    );
  }
}