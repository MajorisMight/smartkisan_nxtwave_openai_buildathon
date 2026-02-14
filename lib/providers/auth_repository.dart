import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/providers/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  // Expose the raw stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signUp({required String email, required String password}) async {
    final response = await _client.auth.signUp(email: email, password: password);
    
    // Debug print to see what's happening
    print('--- Supabase SignUp Response ---');
    print('User created: ${response.user?.email}');
    print('User ID: ${response.user?.id}');
    print('Email confirmed: ${response.user?.emailConfirmedAt}');
    print('Session exists: ${response.session != null}');
    print('------------------------------');
    
    return response;
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    return response;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});