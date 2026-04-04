class Transaction {
  final String id;
  final String userId;
  final int amountIdr;
  final DateTime transactionDate;
  final String description;
  final String category;
  final String type;
  final String status;
  final String paymentMethod;
  final String? creditCardId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amountIdr,
    required this.transactionDate,
    required this.description,
    required this.category,
    required this.type,
    required this.status,
    required this.paymentMethod,
    this.creditCardId,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amountIdr: json['amount_idr'] as int,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      description: json['description'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      creditCardId: json['credit_card_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
