class Place {
  final double lat;
  final double lng;
  final String? address;

  Place({required this.lat, required this.lng, this.address});

  // الـ Factory ده بيهندل الـ JSON اللي راجع من الـ New Places API
  factory Place.fromJson(Map<String, dynamic> json) {
    // في الـ New API، اللوكيشن بيرجع مباشرة تحت Key اسمه 'location'
    final location = json['location'];
    
    return Place(
      lat: location['latitude']?.toDouble() ?? 0.0,
      lng: location['longitude']?.toDouble() ?? 0.0,
      address: json['formattedAddress'], // حقل اختياري لو محتاجه
    );
  }
}