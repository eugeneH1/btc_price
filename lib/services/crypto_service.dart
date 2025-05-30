import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Duration fetchCooldown = Duration(hours: 6);

Future<Map<String, dynamic>?> fetchBitcoinPriceIfAllowed() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final lastFetchMillis = prefs.getInt('last_fetch_timestamp');

  if (lastFetchMillis != null) {
    final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    final difference = now.difference(lastFetchTime);

    if (difference < fetchCooldown) {
      // Return cached data if available
      final cachedPrice = prefs.getDouble('btc_price');
      final cachedChange = prefs.getDouble('btc_change');

      if (cachedPrice != null && cachedChange != null) {
        return {
          'price': cachedPrice,
          'percent_change_24h': cachedChange,
          'last_updated': lastFetchTime,
        };
      }
      return null; // No cached data
    }
  }

  final apiKey = dotenv.env['CMP_API_KEY'] ?? '';

  final response = await http.get(
    Uri.parse(
      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?symbol=BTC',
    ),
    headers: {'X-CMC_PRO_API_KEY': apiKey},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final quote = data['data']['BTC']['quote']['USD'];
    final btcPrice = quote['price'];
    final change24h = quote['percent_change_24h'];

    await prefs.setInt('last_fetch_timestamp', now.millisecondsSinceEpoch);
    await prefs.setDouble('btc_price', btcPrice);
    await prefs.setDouble('btc_change', change24h);

    return {
      'price': btcPrice,
      'percent_change_24h': change24h,
      'last_updated': now,
    };
  } else {
    return null;
  }
}

