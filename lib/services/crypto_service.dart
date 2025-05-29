import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/btc_data.dart';

class CryptoService {
  static const _baseUrl =
      'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest';
  final String apiKey;

  CryptoService({required this.apiKey});

  Future<BTCData?> fetchBTCData() async {
    final url = Uri.parse('$_baseUrl?id=1'); // 1 is BTC's CoinMarketCap id

    final response = await http.get(
      url,
      headers: {'X-CMC_PRO_API_KEY': apiKey, 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final btcJson = jsonData['data']['1']['quote']['USD'];
      return BTCData.fromJson(btcJson);
    } else {
      print('Failed to load BTC data: ${response.statusCode}');
      return null;
    }
  }
}
