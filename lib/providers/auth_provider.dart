// 1. Create a provider to track pending email confirmation
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/providers/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:kisan/providers/profile_provider.dart';
import 'package:kisan/services/session_service.dart';

final pendingEmailConfirmationProvider = StateProvider<String?>((ref) => null);

// 2. Updated AuthNotifier that handles navigation directly
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> signUp(
    String email,
    String password,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
      );

      // If sign up was successful but no session (email confirmation required)
      if (response.user != null && response.session == null) {
        print('Sign up successful - email confirmation required');
        // Set the pending email confirmation
        _ref.read(pendingEmailConfirmationProvider.notifier).state = email;
        // Navigate directly to confirm email screen
        // context.go('/confirm-email');
      } else if (response.user != null && response.session != null) {
        print('Sign up successful - email already confirmed');
        // Clear any pending confirmation
        _ref.read(pendingEmailConfirmationProvider.notifier).state = null;
        // Let the redirect logic handle navigation to home/onboarding
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );
      print('Sign in successful: ${response.user?.email}');
      // Clear any pending confirmation on successful sign in
      _ref.read(pendingEmailConfirmationProvider.notifier).state = null;
    });
  }
}

// Updated provider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, ref);
});

// You'll need a provider to check onboarding status
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase.auth.currentUser == null) return false;

  // Prefer local completion state to avoid redirect loops right after save.
  final localOnboardingComplete = await SessionService.isOnboardingComplete();
  if (localOnboardingComplete) return true;

  try {
    final profile =
        await supabase
            .from('farmers')
            .select('name')
            .eq('id', supabase.auth.currentUser!.id)
            .single();
    return profile['name'] != null;
  } catch (e) {
    // Fallback to local flag to avoid redirect loops when RLS/policy blocks read.
    return SessionService.isOnboardingComplete();
  }
});
