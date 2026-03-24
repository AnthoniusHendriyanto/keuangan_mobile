import 'credit_card.dart';

class TransactionEntity {
  final String id;
  final int amountIdr; // Strict int for IDR
  final DateTime transactionDate;
  final String description;
  final String category;
  final String type; // MANUAL, PDF_PARSED
  final String status; // PENDING, RECONCILED
  final String paymentMethod; // CREDIT_CARD, CASH, QR_BANK
  final CreditCard? creditCard;

  TransactionEntity({
    required this.id,
    required this.amountIdr,
    required this.transactionDate,
    required this.description,
    required this.category,
    required this.type,
    required this.status,
    required this.paymentMethod,
    this.creditCard,
  });
}
