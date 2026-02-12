// import 'package:flutter/material.dart';
// import '../models/notification.dart';
// import '../services/notification_service.dart';

// class NotificationProvider with ChangeNotifier {
//   List<AppNotification> _notifications = [];
//   List<AppNotification> _unreadNotifications = [];
//   bool _isLoading = false;
//   String? _error;
//   Map<String, dynamic> _settings = {};

//   // Getters
//   List<AppNotification> get notifications => _notifications;
//   List<AppNotification> get unreadNotifications => _unreadNotifications;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Map<String, dynamic> get settings => _settings;
//   int get unreadCount => _unreadNotifications.length;

//   // Initialize notifications
//   Future<void> loadNotifications() async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       _notifications = await NotificationService.getAllNotifications();
//       _unreadNotifications = await NotificationService.getUnreadNotifications();
//       notifyListeners();
//     } catch (e) {
//       _setError('Failed to load notifications: $e');
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Load notification settings
//   Future<void> loadSettings() async {
//     try {
//       _settings = await NotificationService.getNotificationSettings();
//       notifyListeners();
//     } catch (e) {
//       _setError('Failed to load notification settings: $e');
//     }
//   }

//   // Mark notification as read
//   Future<bool> markAsRead(String notificationId) async {
//     try {
//       final success = await NotificationService.markAsRead(notificationId);
//       if (success) {
//         final index = _notifications.indexWhere((n) => n.id == notificationId);
//         if (index != -1) {
//           final notification = _notifications[index];
//           _notifications[index] = AppNotification(
//             id: notification.id,
//             title: notification.title,
//             message: notification.message,
//             type: notification.type,
//             category: notification.category,
//             isRead: true,
//             createdAt: notification.createdAt,
//             data: notification.data,
//             imageUrl: notification.imageUrl,
//             actionUrl: notification.actionUrl,
//             farmerId: notification.farmerId,
//           );
//           _unreadNotifications.removeWhere((n) => n.id == notificationId);
//           notifyListeners();
//         }
//       }
//       return success;
//     } catch (e) {
//       _setError('Failed to mark notification as read: $e');
//       return false;
//     }
//   }

//   // Mark all notifications as read
//   Future<bool> markAllAsRead() async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       final success = await NotificationService.markAllAsRead();
//       if (success) {
//         _notifications = _notifications.map((n) => AppNotification(
//           id: n.id,
//           title: n.title,
//           message: n.message,
//           type: n.type,
//           category: n.category,
//           isRead: true,
//           createdAt: n.createdAt,
//           data: n.data,
//           imageUrl: n.imageUrl,
//           actionUrl: n.actionUrl,
//           farmerId: n.farmerId,
//         )).toList();
//         _unreadNotifications.clear();
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       _setError('Failed to mark all notifications as read: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Delete notification
//   Future<bool> deleteNotification(String notificationId) async {
//     try {
//       final success = await NotificationService.deleteNotification(notificationId);
//       if (success) {
//         _notifications.removeWhere((n) => n.id == notificationId);
//         _unreadNotifications.removeWhere((n) => n.id == notificationId);
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       _setError('Failed to delete notification: $e');
//       return false;
//     }
//   }

//   // Clear all notifications
//   Future<bool> clearAllNotifications() async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       final success = await NotificationService.clearAllNotifications();
//       if (success) {
//         _notifications.clear();
//         _unreadNotifications.clear();
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       _setError('Failed to clear all notifications: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Send local notification
//   Future<void> sendLocalNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     try {
//       await NotificationService.sendLocalNotification(
//         title: title,
//         body: body,
//         payload: payload,
//       );
//     } catch (e) {
//       _setError('Failed to send notification: $e');
//     }
//   }

//   // Schedule notification
//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//     String? payload,
//   }) async {
//     try {
//       await NotificationService.scheduleNotification(
//         id: id,
//         title: title,
//         body: body,
//         scheduledDate: scheduledDate,
//         payload: payload,
//       );
//     } catch (e) {
//       _setError('Failed to schedule notification: $e');
//     }
//   }

//   // Cancel notification
//   Future<void> cancelNotification(int id) async {
//     try {
//       await NotificationService.cancelNotification(id);
//     } catch (e) {
//       _setError('Failed to cancel notification: $e');
//     }
//   }

//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     try {
//       await NotificationService.cancelAllNotifications();
//     } catch (e) {
//       _setError('Failed to cancel all notifications: $e');
//     }
//   }

//   // Update notification settings
//   Future<bool> updateSettings(Map<String, dynamic> newSettings) async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       final success = await NotificationService.updateNotificationSettings(newSettings);
//       if (success) {
//         _settings = newSettings;
//         notifyListeners();
//       }
//       return success;
//     } catch (e) {
//       _setError('Failed to update notification settings: $e');
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Send order update notification
//   Future<void> sendOrderUpdateNotification(String orderId, String status) async {
//     try {
//       await NotificationService.sendOrderUpdateNotification(orderId, status);
//     } catch (e) {
//       _setError('Failed to send order update notification: $e');
//     }
//   }

//   // Send weather alert notification
//   Future<void> sendWeatherAlertNotification(String alert) async {
//     try {
//       await NotificationService.sendWeatherAlertNotification(alert);
//     } catch (e) {
//       _setError('Failed to send weather alert notification: $e');
//     }
//   }

//   // Send community update notification
//   Future<void> sendCommunityUpdateNotification(String postTitle) async {
//     try {
//       await NotificationService.sendCommunityUpdateNotification(postTitle);
//     } catch (e) {
//       _setError('Failed to send community update notification: $e');
//     }
//   }

//   // Refresh notifications
//   Future<void> refresh() async {
//     await loadNotifications();
//   }

//   // Helper methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setError(String error) {
//     _error = error;
//     notifyListeners();
//   }

//   void _clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   void clearError() {
//     _clearError();
//   }
// }
