import 'package:bag_flow/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bag_flow/services/user_service.dart';
import 'package:bag_flow/services/preferences_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Gives real-time authentication state updates 
// Listen to logins and log outs and update immediately when changed 
final authStateProvider = StreamProvider<User?>((ref) {
  // Gets AuthService from other provider 
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges();
});

// Using email to login is set as default 
final loginUseEmailProvider = StateProvider.autoDispose<bool>((ref) => true);
// login
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

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final userService = ref.watch(userServiceProvider);

  final user = authService.currentUser;
  if (user == null) return null;

  final doc = await userService.getUserProfile(user.uid);
  return doc.data() as Map<String, dynamic>?;
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final hasSeenWelcomeProvider = FutureProvider<bool>((ref) async {
  final prefsService = ref.watch(preferencesServiceProvider);
  return prefsService.getHasSeenWelcome();
});

final sessionBootstrapProvider = FutureProvider<void>((ref) async {
  final prefsService = ref.watch(preferencesServiceProvider);
  final authService = ref.watch(authServiceProvider);

  final keepSignedIn = await prefsService.getKeepSignedIn();

  if (!keepSignedIn && authService.currentUser != null) {
    await authService.signOut();
  }
});