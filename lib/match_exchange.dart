class MatchExchange {
  final int id;
  final String role;
  final String name;
  final String walletId;
  final String fromCurrency;
  final String toCurrency;
  final String fromAmount;
  final String toAmount;
  final String fromDate;
  final String toDate;
  final String location;

  MatchExchange({
    required this.id,
    required this.role,
    required this.name,
    required this.walletId,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.fromDate,
    required this.toDate,
    required this.location
  });

  factory MatchExchange.fromJson(Map<String, dynamic> json) {
    return MatchExchange(
      id: json['id'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      walletId: json['walletId'] ?? '',
      fromCurrency: json['from_currency'] ?? '',
      toCurrency: json['to_currency'] ?? '',
      fromAmount: json['from_amount'] ?? '',
      toAmount: json['to_amount'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      location: json['location'] ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'walletId': walletId,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'fromDate': fromDate,
      'toDate': toDate,
      'location': location,
    };
  }
}