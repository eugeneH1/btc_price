class BTCData {
  final double price;
  final double percentChange24h;

  BTCData({required this.price, required this.percentChange24h});

  // Factory constructor to create BTCData from JSON
  factory BTCData.fromJson(Map<String, dynamic> json) {
    return BTCData(
      price: (json['price'] as num).toDouble(),
      percentChange24h: (json['percent_change_24h'] as num).toDouble(),
    );
  }
}
