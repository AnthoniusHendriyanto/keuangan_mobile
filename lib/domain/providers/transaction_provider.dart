import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/transaction_repository.dart';

// Provider for the API client/repository injection
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// FutureProvider to automatically fetch the transactions on mount
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactions();
});

// Calculate "True Liability" - the sum of all PENDING transactions
final trueLiabilityProvider = Provider<int>((ref) {
  final transactionsState = ref.watch(transactionsProvider);
  
  return transactionsState.maybeWhen(
    data: (transactions) {
      int total = 0;
      for (var t in transactions) {
        if (t.status == 'PENDING') {
          total += t.amountIdr;
        }
      }
      return total;
    },
    orElse: () => 0,
  );
});
