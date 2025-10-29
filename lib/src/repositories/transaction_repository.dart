import 'package:campus_hub/src/api/api_service.dart';
import 'package:campus_hub/src/models/models.dart';

class TransactionRepository {
  final ApiService api;
  TransactionRepository(this.api);

  Future<List<TransactionRecordDto>> getLentRecords() => api.getLentRecords();
  Future<List<TransactionRecordDto>> getBorrowedRecords() => api.getBorrowedRecords();
  Future<void> markAsReturn(int transactionId) => api.markAsReturn(transactionId);
  Future<void> confirmReturn(int transactionId) => api.confirmReturn(transactionId);
}

