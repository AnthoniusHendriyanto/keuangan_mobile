import 'dart:convert';
import '../../core/network/api_client.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final ApiClient _apiClient;

  TransactionRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Transaction>> getTransactions() async {
    final response = await _apiClient.get('/transactions/');
    
    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);
      final List<dynamic> data = (body is Map && body.containsKey('data')) 
          ? body['data'] as List<dynamic> 
          : body as List<dynamic>;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode} - ${response.body}');
    }
  }
}
