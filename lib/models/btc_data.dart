class BTCData {
  final double price;
  final double percentChange24h;
  final DateTime lastUpdated;

  BTCData({
    required this.price,
    required this.percentChange24h,
    required this.lastUpdated,
  });

  // Factory constructor to create BTCData from JSON
  factory BTCData.fromJson(Map<String, dynamic> json) {
    return BTCData(
      price: (json['price'] as num).toDouble(),
      percentChange24h: (json['percent_change_24h'] as num).toDouble(),
      lastUpdated: json['lastUpdated'] is DateTime
          ? json['last_updated'] as DateTime
          : DateTime.parse(json['last_updated']),
    );
  }
}
