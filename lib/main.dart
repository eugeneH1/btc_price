import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Duration fetchCooldown = Duration(hours: 6);
const String apiKey = '226e4200-9649-477a-a324-20948fe0fd51';

void main() {
  runApp(const BTCApp());
}

class BTCApp extends StatelessWidget {
  const BTCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BTCPriceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BTCPriceScreen extends StatefulWidget {
  const BTCPriceScreen({super.key});

  @override
  State<BTCPriceScreen> createState() => _BTCPriceScreenState();
}

class _BTCPriceScreenState extends State<BTCPriceScreen> {
  double? price;
  double? percentChange24h;
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadBTCData();
  }

  Future<void> _loadBTCData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastFetchMillis = prefs.getInt('last_fetch_timestamp');

    if (lastFetchMillis != null) {
      final lastFetch = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
      if (now.difference(lastFetch) < fetchCooldown) {
        final cachedPrice = prefs.getDouble('btc_price');
        final cachedChange = prefs.getDouble('btc_change');
        if (cachedPrice != null && cachedChange != null) {
          setState(() {
            price = cachedPrice;
            percentChange24h = cachedChange;
            lastUpdated = lastFetch;
          });
          return;
        }
      }
    }

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

      setState(() {
        price = btcPrice;
        percentChange24h = change24h;
        lastUpdated = now;
      });

      await prefs.setInt('last_fetch_timestamp', now.millisecondsSinceEpoch);
      await prefs.setDouble('btc_price', btcPrice);
      await prefs.setDouble('btc_change', change24h);
    } else {
      print('API error: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bitcoin Price Tracker')),
      body: Center(
        child: price == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${price!.toStringAsFixed(2)}',
                    style: style.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '24h change: ${percentChange24h!.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 18,
                      color: percentChange24h! >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (lastUpdated != null)
                    Text(
                      'Last updated: ${lastUpdated!.toLocal().toString().split('.').first}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
      ),
    );
  }
}

