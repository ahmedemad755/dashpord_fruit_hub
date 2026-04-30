import 'package:bloc/bloc.dart';
import 'package:fruitesdashboard/maps/data/models/placesugestion.dart';
import 'package:fruitesdashboard/maps/data/repo/place_repo.dart';
import 'package:fruitesdashboard/maps/presentation/widgets/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'maps_state.dart';

class MapsCubit extends Cubit<MapsState> {
  final MapsRepository mapsRepository;

  MapsCubit(this.mapsRepository) : super(MapsInitial());

  void emitPlaceSuggestions(String place, String sessionToken) {
    mapsRepository.fetchSuggestions(place, sessionToken).then((suggestions) {
      emit(PlacesLoaded(suggestions));
    });
  }

 // داخل كلاس MapsCubit
void emitPlaceLocation(String placeId, String sessionToken) {
  // دلوقتي mapsRepository.getPlaceLocation بترجع Place
  mapsRepository.getPlaceLocation(placeId, sessionToken).then((place) {
    // الـ place هنا نوعه Place، والـ State مستني Place
    // كدة مفيش تعارض والـ Error هيختفي
    emit(PlaceLocationLoaded(place));
  });
}

void emitPlaceDirections(LatLng origin, LatLng destination) {
  mapsRepository.getDirections(origin, destination).then((directions) {
    emit(DirectionsLoaded(directions)); // directions هنا أصبحت List<LatLng>
  });
}
}