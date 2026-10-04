class GoogleMapsService {
  static const String googleMapsApiKey = '';

  static bool get hasApiKey => googleMapsApiKey.trim().isNotEmpty;

  static String buildLocationUrl({required double latitude, required double longitude}) {
    if (hasApiKey) {
      return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=15&size=600x300&markers=color:red%7C$latitude,$longitude&key=$googleMapsApiKey';
    }
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }
}
