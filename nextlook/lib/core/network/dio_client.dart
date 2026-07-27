import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'api_exception.dart';

/// Configured Dio HTTP client with automatic token attachment, refresh interceptor,
/// and typed error handling via [ApiException].
class DioClient {
  /// Public backend URL hosted on Render.
  static const String defaultBaseUrl = 'https://nextlook-shopping-app-flutter.onrender.com';

  final Dio _dio;
  final TokenStorage _tokenStorage;

  DioClient({
    String baseUrl = defaultBaseUrl,
    TokenStorage? tokenStorage,
    Dio? dio,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 60),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    _setupInterceptors();
  }

  /// Expose underlying Dio instance if needed.
  Dio get dio => _dio;

  /// Expose TokenStorage instance.
  TokenStorage get tokenStorage => _tokenStorage;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final path = options.path;
          final isAuthEndpoint = path.contains('/auth/register') ||
              path.contains('/auth/login') ||
              path.contains('/auth/refresh');

          if (!isAuthEndpoint) {
            final accessToken = await _tokenStorage.getAccessToken();
            if (accessToken != null && accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          return handler.next(options);
        },
        onError: (DioException err, handler) async {
          final isAuthEndpoint = err.requestOptions.path.contains('/auth/register') ||
              err.requestOptions.path.contains('/auth/login') ||
              err.requestOptions.path.contains('/auth/refresh');
          final isRetry = err.requestOptions.extra['isRetry'] == true;

          if (err.response?.statusCode == 401 && !isAuthEndpoint && !isRetry) {
            final refreshed = await _attemptTokenRefresh(err.requestOptions);
            if (refreshed != null) {
              return handler.resolve(refreshed);
            }
          }
          return handler.next(err);
        },
      ),
    );
  }

  /// Attempts to refresh the access token and retries the failed request once.
  Future<Response?> _attemptTokenRefresh(RequestOptions requestOptions) async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _tokenStorage.clearTokens();
        return null;
      }

      // Standalone Dio instance to prevent interceptor loops
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['accessToken'] as String?;
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _tokenStorage.saveAccessToken(newAccessToken);

          // Mark request as retried and set new Authorization header
          requestOptions.extra['isRetry'] = true;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          return await _dio.fetch(requestOptions);
        }
      }
    } catch (e) {
      // Refresh failed (invalid/expired refresh token)
      await _tokenStorage.clearTokens();
    }
    return null;
  }

  /// Wrapper for GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Wrapper for POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Wrapper for PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Wrapper for DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
