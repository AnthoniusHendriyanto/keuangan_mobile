import '../../domain/entities/transaction.dart';
import '../../domain/entities/credit_card.dart';

class MockDashboardRepository {
  Future<List<CreditCard>> getCreditCards() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      CreditCard(
        id: "e429b9f7-0000-0000-0000-111111111111",
        cardName: "BCA Everyday",
        cutoffDay: 20,
        dueDay: 5,
      ),
      CreditCard(
        id: "f530c0f8-0000-0000-0000-222222222222",
        cardName: "Mandiri Travel",
        cutoffDay: 12,
        dueDay: 28,
      ),
    ];
  }

  Future<List<TransactionEntity>> getRecentTransactions() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      TransactionEntity(
        id: "a1b2c3d4-1111",
        amountIdr: -450000,
        transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
        description: "Grocery Store",
        category: "Groceries",
        type: "MANUAL",
        status: "PENDING",
        paymentMethod: "CREDIT_CARD",
        creditCard: CreditCard(
          id: "e429b9f7-0000-0000-0000-111111111111",
          cardName: "BCA Everyday",
          cutoffDay: 20,
          dueDay: 5,
        ),
      ),
      TransactionEntity(
        id: "b2c3d4e5-2222",
        amountIdr: 8000000,
        transactionDate: DateTime.now().subtract(const Duration(days: 12)),
        description: "Salary Deposit",
        category: "Income",
        type: "MANUAL",
        status: "RECONCILED",
        paymentMethod: "BANK_TRANSFER",
      ),
    ];
  }

  Future<int> getNetBalance() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 15000000;
  }

  Future<int> getCurrentLiabilities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 4500000;
  }

  Future<int> getMonthlyBurn() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 2100000;
  }
}
