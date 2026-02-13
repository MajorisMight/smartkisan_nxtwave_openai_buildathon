class CommunityPost {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerImage;
  final String title;
  final String content;
  final String category;
  final List<String> images;
  final List<String> tags;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> commentsList;
  final String location;
  final bool isVerified;

  CommunityPost({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerImage,
    required this.title,
    required this.content,
    required this.category,
    required this.images,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    required this.commentsList,
    required this.location,
    required this.isVerified,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerImage: json['farmerImage'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      commentsList: (json['commentsList'] as List?)
          ?.map((e) => Comment.fromJson(e))
          .toList() ?? [],
      location: json['location'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerImage': farmerImage,
      'title': title,
      'content': content,
      'category': category,
      'images': images,
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'commentsList': commentsList.map((e) => e.toJson()).toList(),
      'location': location,
      'isVerified': isVerified,
    };
  }

  copyWith({required bool isLiked, required int likes}) {
    return CommunityPost(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerImage: farmerImage,
      title: title,
      content: content,
      category: category,
      images: images,
      tags: tags,
      likes: likes,
      comments: comments,
      shares: shares,
      isLiked: isLiked,
      createdAt: createdAt,
      updatedAt: updatedAt,
      commentsList: commentsList,
      location: location,
      isVerified: isVerified,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String farmerId;
  final String farmerName;
  final String farmerImage;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerImage,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.isLiked,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerImage: json['farmerImage'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies: (json['replies'] as List?)
          ?.map((e) => Comment.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerImage': farmerImage,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }
}

class PostCategory {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int postCount;

  PostCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.postCount,
  });

  factory PostCategory.fromJson(Map<String, dynamic> json) {
    return PostCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      postCount: json['postCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'postCount': postCount,
    };
  }
}
