class Crypto {
  String id;
  String name;
  String symbol;
  double changePercent24Hr;
  double priceUsd;
  double marketCapUsd;
  int rank;

  Crypto(
    this.changePercent24Hr,
    this.id,
    this.marketCapUsd,
    this.name,
    this.priceUsd,
    this.rank,
    this.symbol,
  );

  factory Crypto.fromMapJson(Map<String, dynamic> jsonMapObject) {
    return Crypto(
      double.parse(jsonMapObject['changePercent24Hr']),
      jsonMapObject['id'],
      double.parse(jsonMapObject['marketCapUsd']),
      jsonMapObject['name'],
      double.parse(jsonMapObject['priceUsd']),
      int.parse(jsonMapObject['rank']),
      jsonMapObject['symbol'],
    );
  }
}
