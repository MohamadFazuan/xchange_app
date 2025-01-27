class Transaction {
  final String from;
  final String to;
  final String fromCurrency;
  final String toCurrency;
  final String fromAmount;
  final String toAmount;
  final String timestamp;

  Transaction({
    required this.from,
    required this.to,
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmount,
    required this.toAmount,
    required this.timestamp
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      fromCurrency: json['from_currency'] ?? '',
      toCurrency: json['to_currency'] ?? '',
      fromAmount: json['from_amount'] ?? '',
      toAmount: json['to_amount'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'timestamp': timestamp
    };
  }
}