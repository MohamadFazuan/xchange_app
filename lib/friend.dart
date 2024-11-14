class Friends {
  final String name;
  final String walletId;

  Friends({
    required this.name,
    required this.walletId,
  });

  factory Friends.fromJson(Map<String, dynamic> json) {
    return Friends(
      name: json['name'] ?? '',
      walletId: json['walletId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'walletId': walletId,
    };
  }
}