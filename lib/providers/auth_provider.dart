import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  Farmer? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  // Getters
  Farmer? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _isLoggedIn = await AuthService.isLoggedIn();
      if (_isLoggedIn) {
        _currentUser = await AuthService.getCurrentUser();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String phoneNumber, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await AuthService.login(phoneNumber, password);
      if (success) {
        _isLoggedIn = true;
        _currentUser = await AuthService.getCurrentUser();
        notifyListeners();
        return true;
      } else {
        _setError('Invalid phone number or password');
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(Farmer farmer, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await AuthService.register(farmer, password);
      if (success) {
        _isLoggedIn = true;
        _currentUser = farmer;
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await AuthService.logout();
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<bool> updateProfile(Farmer farmer) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await AuthService.updateProfile(farmer);
      if (success) {
        _currentUser = farmer;
        notifyListeners();
        return true;
      } else {
        _setError('Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await AuthService.changePassword(oldPassword, newPassword);
      if (!success) {
        _setError('Password change failed');
      }
      return success;
    } catch (e) {
      _setError('Password change failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String phoneNumber) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await AuthService.forgotPassword(phoneNumber);
      if (!success) {
        _setError('Password reset failed');
      }
      return success;
    } catch (e) {
      _setError('Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
