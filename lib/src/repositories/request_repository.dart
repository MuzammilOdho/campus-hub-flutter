import 'package:campus_hub/src/api/api_service.dart';
import 'package:campus_hub/src/models/models.dart';

class RequestRepository {
  final ApiService api;
  RequestRepository(this.api);

  Future<List<UserRequestDto>> getReceivedRequests() => api.getReceivedRequests();
  Future<List<UserRequestDto>> getSentRequests() => api.getSentRequests();
  Future<void> createRequest(int resourceId, DateTime returnDate) => api.createUserRequest(resourceId, returnDate);
  Future<void> approveRequest(int requestId, DateTime returnDate) => api.approveRequest(requestId, returnDate);
  Future<void> declineRequest(int requestId) => api.declineRequest(requestId);
}

