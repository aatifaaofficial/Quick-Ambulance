class GoogleMapsService {
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
  );

  static bool get hasApiKey => googleMapsApiKey.trim().isNotEmpty;

  static String? buildStaticMapUrl({
    required double latitude,
    required double longitude,
  }) {
    if (!hasApiKey) {
      return null;
    }
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$latitude,$longitude&zoom=15&size=700x360'
        '&markers=color:red%7C$latitude,$longitude&key=$googleMapsApiKey';
  }

  static String buildLocationUrl({required double latitude, required double longitude}) {
    return Uri.https(
      'www.google.com',
      '/maps/search/',
      {
        'api': '1',
        'query': '$latitude,$longitude',
      },
    ).toString();
  }
}
