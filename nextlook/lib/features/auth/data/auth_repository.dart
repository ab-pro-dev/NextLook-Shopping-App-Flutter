import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';
import 'user_model.dart';

/// Repository wrapping DioClient, TokenStorage, and GoogleSignIn to handle authentication tasks.
class AuthRepository {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    DioClient? dioClient,
    TokenStorage? tokenStorage,
    GoogleSignIn? googleSignIn,
  })  : _dioClient = dioClient ?? DioClient(),
        _tokenStorage = tokenStorage ?? TokenStorage(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  '448048429868-qml55dpkn0a3da0tatat14rcb79g5043.apps.googleusercontent.com',
              scopes: ['email', 'profile'],
            );

  DioClient get dioClient => _dioClient;
  TokenStorage get tokenStorage => _tokenStorage;

  /// Performs Google Sign-In flow, retrieves Google ID token, and authenticates with POST /api/auth/google
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) {
      throw Exception('Sign in cancelled');
    }

    final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to retrieve Google ID Token');
    }

    final response = await _dioClient.post(
      '/api/auth/google',
      data: {'idToken': idToken},
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

  /// Fetches current authenticated user data via GET /api/auth/me
  Future<User> getCurrentUser() async {
    final response = await _dioClient.get('/api/auth/me');
    final data = response.data as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Updates user profile (name) via PUT /api/auth/me
  Future<User> updateProfile({required String name}) async {
    final response = await _dioClient.put(
      '/api/auth/me',
      data: {'name': name},
    );
    final data = response.data as Map<String, dynamic>;
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Logs out user by clearing stored tokens and Google Sign-In session.
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _tokenStorage.clearTokens();
  }

  /// Checks if an access token exists in local secure storage.
  Future<bool> hasValidSession() async {
    final accessToken = await _tokenStorage.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
