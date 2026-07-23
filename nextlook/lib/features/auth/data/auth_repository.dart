import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';
import 'user_model.dart';

/// Repository wrapping DioClient and TokenStorage to handle authentication tasks.
class AuthRepository {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  AuthRepository({
    DioClient? dioClient,
    TokenStorage? tokenStorage,
  })  : _dioClient = dioClient ?? DioClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  DioClient get dioClient => _dioClient;
  TokenStorage get tokenStorage => _tokenStorage;

  /// Registers a new user with name, email, and password.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      '/api/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Logs in an existing user with email and password.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Fetches current authenticated user data.
  Future<User> getCurrentUser() async {
    final response = await _dioClient.get('/api/auth/me');
    final data = response.data as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Logs out user by clearing stored tokens.
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  /// Checks if an access token exists in local secure storage.
  Future<bool> hasValidSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
