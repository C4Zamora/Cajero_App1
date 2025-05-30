class Account {
  final double balance;

  Account({required this.balance});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      balance: (json['balance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
    };
  }
}