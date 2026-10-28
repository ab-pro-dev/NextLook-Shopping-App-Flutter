import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/token_storage.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

/// Sealed class representing all possible authentication states.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  String toString() => 'AuthInitial()';
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  String toString() => 'AuthLoading()';
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated && runtimeType == other.runtimeType && user == other.user;

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'AuthAuthenticated(user: ${user.name}, email: ${user.email})';
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  String toString() => 'AuthUnauthenticated()';
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthError && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'AuthError(message: "$message")';
}

/// StateNotifier controlling Google authentication flows.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthInitial());

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signInWithGoogle();
      if (mounted) {
        state = AuthAuthenticated(user);
      }
    } on ApiException catch (e) {
      if (mounted) {
        state = AuthError(e.message);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        state = AuthError(msg);
      }
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _authRepository.logout();
      if (mounted) {
        state = const AuthUnauthenticated();
      }
    } catch (e) {
      if (mounted) {
        state = AuthError(e.toString());
      }
    }
  }

  Future<User> updateProfile({required String name, String? avatarUrl}) async {
    final updatedUser = await _authRepository.updateProfile(name: name, avatarUrl: avatarUrl);
    if (mounted) {
      state = AuthAuthenticated(updatedUser);
    }
    return updatedUser;
  }

  Future<User> uploadAvatar({required List<int> imageBytes, required String fileName}) async {
    final updatedUser = await _authRepository.uploadAvatar(imageBytes: imageBytes, fileName: fileName);
    if (mounted) {
      state = AuthAuthenticated(updatedUser);
    }
    return updatedUser;
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final hasSession = await _authRepository.hasValidSession();
      if (!hasSession) {
        if (mounted) {
          state = const AuthUnauthenticated();
        }
        return;
      }
      final user = await _authRepository.getCurrentUser();
      if (mounted) {
        state = AuthAuthenticated(user);
      }
    } catch (e) {
      await _authRepository.logout();
      if (mounted) {
        state = const AuthUnauthenticated();
      }
    }
  }
}

/// Riverpod Providers
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioClientProvider = Provider<DioClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioClient(tokenStorage: tokenStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(dioClient: dioClient, tokenStorage: tokenStorage);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});
