import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:nextlook/core/network/token_storage.dart';
import 'package:nextlook/core/network/api_exception.dart';
import 'package:nextlook/core/network/dio_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage Tests', () {
    late TokenStorage tokenStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      tokenStorage = TokenStorage(storage: const FlutterSecureStorage());
    });

    test('saveTokens and getAccessToken / getRefreshToken work correctly', () async {
      await tokenStorage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();

      expect(accessToken, equals('access_123'));
      expect(refreshToken, equals('refresh_456'));
    });

    test('saveAccessToken updates only access token', () async {
      await tokenStorage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      await tokenStorage.saveAccessToken('new_access_789');

      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();

      expect(accessToken, equals('new_access_789'));
      expect(refreshToken, equals('refresh_456'));
    });

    test('clearTokens removes stored tokens', () async {
      await tokenStorage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      await tokenStorage.clearTokens();

      final accessToken = await tokenStorage.getAccessToken();
      final refreshToken = await tokenStorage.getRefreshToken();

      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });
  });

  group('ApiException Tests', () {
    test('extracts message from JSON backend response body', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 401,
          data: {'message': 'Invalid email or password'},
        ),
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.statusCode, equals(401));
      expect(exception.message, equals('Invalid email or password'));
    });

    test('falls back to generic error message when response data is empty', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/me'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ApiException.fromDioException(dioError);

      expect(exception.message, contains('Connection timed out'));
    });
  });

  group('DioClient Interceptor Tests', () {
    late TokenStorage tokenStorage;
    late DioClient dioClient;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      tokenStorage = TokenStorage(storage: const FlutterSecureStorage());
      dioClient = DioClient(
        baseUrl: 'http://localhost:3000',
        tokenStorage: tokenStorage,
      );
    });

    test('DioClient initializes with correct options and TokenStorage', () {
      expect(dioClient.dio.options.baseUrl, equals('http://localhost:3000'));
      expect(dioClient.tokenStorage, equals(tokenStorage));
    });
  });
}
