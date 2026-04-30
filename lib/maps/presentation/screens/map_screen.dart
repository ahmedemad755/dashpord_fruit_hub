import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fruitesdashboard/maps/business_logic/cubit/maps/maps_cubit.dart';
import 'package:fruitesdashboard/maps/data/models/placesugestion.dart';
import 'package:fruitesdashboard/maps/helpers/location_helper.dart';
import 'package:fruitesdashboard/maps/presentation/widgets/place.dart';
import 'package:fruitesdashboard/maps/presentation/widgets/place_item.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? position;
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  FloatingSearchBarController controller = FloatingSearchBarController();
  
  List<PlaceSuggestion> places = [];
  Set<Marker> markers = {};
  
  // إحداثيات النقطة اللي في نص الشاشة حالياً
  late LatLng _currentMapCenter;

  @override
  void initState() {
    super.initState();
    _getMyCurrentLocation();
  }

  Future<void> _getMyCurrentLocation() async {
    try {
      Position p = await LocationHelper.getCurrentLocation();
      setState(() {
        position = p;
        _currentMapCenter = LatLng(p.latitude, p.longitude);
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }
// في ملف map_screen.dart ضيف الميثود دي
Future<String> _getAddressFromLatLng(LatLng position) async {
  final String googleApiKey = "AIzaSyBqylu7OAYPkQC8HfSBTjrg8vDWeHkApvQ";
  final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey&language=ar';

  try {
    final response = await Dio().get(url); // محتاج تعمل import لـ dio
    if (response.statusCode == 200 && response.data['results'].isNotEmpty) {
      return response.data['results'][0]['formatted_address'];
    }
  } catch (e) {
    debugPrint("Geocoding Error: $e");
  }
  return "موقع مجهول";
}


  // تحريك الكاميرا لمكان البحث
  Future<void> _goToMySelectedPlace(Place place) async {
    final LatLng selectedLatLng = LatLng(place.lat, place.lng);
    final GoogleMapController controller = await _mapControllerCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: selectedLatLng, zoom: 17),
    ));
  }

  Widget buildMap() {
    if (position == null) {
    return const Center(child: CircularProgressIndicator());
  }
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      zoomControlsEnabled: false, // قفلناها عشان الزرار ميزحمش الشاشة
      myLocationButtonEnabled: false,
initialCameraPosition: CameraPosition(
      target: LatLng(position!.latitude, position!.longitude),
      zoom: 17,
    ),
      onMapCreated: (controller) {
        if (!_mapControllerCompleter.isCompleted) {
          _mapControllerCompleter.complete(controller);
        }
      },
      // تحديث الإحداثيات كل ما المستخدم يحرك الخريطة
      onCameraMove: (CameraPosition cameraPosition) {
        _currentMapCenter = cameraPosition.target;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // تم إلغاء الـ AppBar التقليدي لتوسيع مساحة الرؤية
      body: Stack(
        fit: StackFit.expand,
        children: [
          position != null
              ? buildMap()
              : const Center(child: CircularProgressIndicator(color: Colors.blue)),
          
          // 1. شريط البحث
          buildFloatingSearchBar(),

          // 2. أيقونة الماركر الثابتة في منتصف الشاشة
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 35), // لضبط سن الماركر على النقطة
              child: Icon(Icons.location_on, color: Colors.red.shade700, size: 50),
            ),
          ),

          // 3. زرار التأكيد في الأسفل
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // زرار "مكاني الحالي" فوق زرار التأكيد
                Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await _getMyCurrentLocation();
                      final GoogleMapController controller = await _mapControllerCompleter.future;
                      controller.animateCamera(CameraUpdate.newLatLng(LatLng(position!.latitude, position!.longitude)));
                    },
                    backgroundColor: Colors.white,
                    mini: true,
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
  // وتعديل زرار التأكيد يكون كدا:
onPressed: () async {
  // نجيب العنوان الفعلي من الإحداثيات قبل ما نقفل
  String fullAddress = await _getAddressFromLatLng(_currentMapCenter);

  Navigator.pop(context, {
    'lat': _currentMapCenter.latitude,
    'lng': _currentMapCenter.longitude,
    'address': fullAddress, // العنوان الحقيقي هيتبعت هنا
  });
},
                    child: const Text(
                      'تأكيد موقع الصيدلية',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Listener للبحث
          BlocListener<MapsCubit, MapsState>(
            listener: (context, state) {
              if (state is PlaceLocationLoaded) {
                _goToMySelectedPlace(state.place);
              }
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // --- دوال الـ Search Bar كما هي في كودك مع تعديل بسيط ---
  Widget buildFloatingSearchBar() {
    return FloatingSearchBar(
      controller: controller,
      elevation: 6,
      hint: 'ابحث عن منطقة أو شارع..',
      margins: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      onQueryChanged: (query) {
        final sessionToken = const Uuid().v4();
        BlocProvider.of<MapsCubit>(context).emitPlaceSuggestions(query, sessionToken);
      },
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            elevation: 4,
            child: buildSuggestionsBloc(),
          ),
        );
      },
    );
  }

  Widget buildSuggestionsBloc() {
    return BlocBuilder<MapsCubit, MapsState>(
      builder: (context, state) {
        if (state is PlacesLoaded) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: state.places.length,
            itemBuilder: (ctx, index) {
              return InkWell(
                onTap: () {
                  controller.close();
                  final sessionToken = const Uuid().v4();
                  BlocProvider.of<MapsCubit>(context).emitPlaceLocation(state.places[index].placeId, sessionToken);
                },
                child: PlaceItem(suggestion: state.places[index]),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}


