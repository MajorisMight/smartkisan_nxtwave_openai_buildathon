import '../services/demo_data_service.dart';

class MarketIntelligenceService {
  static Future<Map<String, dynamic>> buildMarketFactor({
    required String location,
    required String district,
    required String state,
  }) async {
    // Hook point for real marketplace integration once backend is available.
    final listings = DemoDataService.getRelevantProducts();

    final normalizedNeedle = _normalize('$district $state $location');
    final nearby =
        listings.where((product) {
          final hay = _normalize('${product.farmerLocation} ${product.origin}');
          return normalizedNeedle.isNotEmpty &&
              (hay.contains(_normalize(district)) ||
                  hay.contains(_normalize(state)));
        }).toList();

    final selected = nearby.isNotEmpty ? nearby : listings;
    final avgPrice =
        selected.isEmpty
            ? 0.0
            : selected.fold<double>(0.0, (sum, p) => sum + p.price) /
                selected.length;

    return {
      'source': 'marketplace_stub',
      'market_available': nearby.isNotEmpty,
      'regional_average_note':
          'Marketplace currently in fallback mode; use regional averages with available listing signals.',
      'listings_count': selected.length,
      'avg_listing_price': double.parse(avgPrice.toStringAsFixed(1)),
      'sample_listings':
          selected
              .take(6)
              .map(
                (p) => {
                  'name': p.name,
                  'category': p.category,
                  'subCategory': p.subCategory,
                  'price': p.price,
                  'unit': p.unit,
                  'location': p.farmerLocation,
                },
              )
              .toList(),
    };
  }

  static String _normalize(String raw) {
    return raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9 ]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
