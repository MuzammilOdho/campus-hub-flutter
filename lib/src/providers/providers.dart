import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';
import '../repositories/resource_repository.dart';
import '../repositories/request_repository.dart';
import '../repositories/transaction_repository.dart';


/// Resolves the API base URL in this order:
/// 1. flutter_dotenv's env["API_BASE_URL"] (if dotenv loaded)
/// 2. Dart-define `API_BASE_URL` via String.fromEnvironment
/// 3. Fallback to the previous hardcoded default (10.0.2.2 for emulator).
final baseUrlProvider = Provider<String>((ref) {
  final fromDotenv = dotenv.env['API_BASE_URL'];
  if (fromDotenv != null && fromDotenv.isNotEmpty) return fromDotenv;
  const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  if (fromDefine.isNotEmpty) return fromDefine;
  return 'http://10.0.2.2:8080';
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final base = ref.watch(baseUrlProvider);
  return ApiService(baseUrl: base, storage: const FlutterSecureStorage());
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthRepository(api);
});

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return ResourceRepository(api);
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RequestRepository(api);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  return TransactionRepository(api);
});

// Simple polling stream to trigger periodic refreshes (used by requests/transactions UI).
final requestsPollProvider = StreamProvider.autoDispose<int>((ref) async* {
  // emit a tick immediately, then every 20 seconds
  yield 0;
  await for (final _ in Stream.periodic(const Duration(seconds: 20), (i) => i)) {
    yield 1;
  }
});

class AuthNotifier extends StateNotifier<UserDto?> {
  AuthNotifier(this._ref) : super(null);
  final Ref _ref;

  Future<void> loadProfile() async {
    final api = _ref.read(apiServiceProvider);
    try {
      final user = await api.getProfile();
      state = user;
    } catch (_) {
      state = null;
    }
  }

  Future<void> logout() async {
    final api = _ref.read(apiServiceProvider);
    await api.clearToken();
    state = null;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, UserDto?>((ref) => AuthNotifier(ref));

final resourcesProvider = FutureProvider.autoDispose<List<ResourceDto>>((ref) async {
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getResources();
});

final myResourcesProvider = FutureProvider.autoDispose<List<ResourceDto>>((ref) async {
  final repo = ref.watch(resourceRepositoryProvider);
  return repo.getMyResources();
});

final receivedRequestsProvider = FutureProvider.autoDispose((ref) async {
  // Depend on poll provider so we refetch periodically when UI is active
  ref.watch(requestsPollProvider);
  final repo = ref.watch(requestRepositoryProvider);
  return repo.getReceivedRequests();
});

/// Number of received requests (for notification badge)
final receivedRequestsCountProvider = Provider<int>((ref) {
  final async = ref.watch(receivedRequestsProvider);
  return async.maybeWhen(data: (list) => list.length, orElse: () => 0);
});

final sentRequestsProvider = FutureProvider.autoDispose((ref) async {
  ref.watch(requestsPollProvider);
  final repo = ref.watch(requestRepositoryProvider);
  return repo.getSentRequests();
});

final lentRecordsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getLentRecords();
});

final borrowedRecordsProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getBorrowedRecords();
});
