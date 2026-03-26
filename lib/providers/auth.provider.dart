import 'package:bag_flow/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Gives you one place to access AuthService 
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Listens to Firebase auth state 
// Later powers AuthGate 
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

final loginUseEmailProvider = StateProvider.autoDispose<bool>((ref) => true);

final loginKeepSignedInProvider = StateProvider.autoDispose<bool>((ref) => true);

final loginLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

final signUpLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

final forgotPasswordLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final phoneVerificationLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final otpVerificationLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final resetPasswordSuccessProvider =
    StateProvider.autoDispose<bool>((ref) => false);
