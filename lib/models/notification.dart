class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String category;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String? actionUrl;
  final String? farmerId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.isRead,
    required this.createdAt,
    required this.data,
    this.imageUrl,
    this.actionUrl,
    this.farmerId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      farmerId: json['farmerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'farmerId': farmerId,
    };
  }
}

enum NotificationType {
  order,
  weather,
  community,
  marketplace,
  system,
  promotion,
}

enum NotificationCategory {
  newOrder,
  orderUpdate,
  weatherAlert,
  newPost,
  newComment,
  priceUpdate,
  stockLow,
  systemMaintenance,
  promotion,
  reminder,
}
