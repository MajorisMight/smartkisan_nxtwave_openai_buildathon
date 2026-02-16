class CommunityPost {
  final String id;
  final String farmerId;
  final String farmerName;
  final String? farmerImageUrl;
  final String title;
  final String content;
  final String category;
  final List<String> images;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final String location;

  const CommunityPost({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerImageUrl,
    required this.title,
    required this.content,
    required this.category,
    required this.images,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.location,
  });

  factory CommunityPost.fromRow(
    Map<String, dynamic> row, {
    required Set<String> likedPostIds,
    Map<String, Map<String, dynamic>> farmersById = const {},
  }) {
    final farmerId = row['farmer_id']?.toString() ?? '';
    final farmer =
        farmersById[farmerId] ?? _asMap(row['farmers']);
    final village = farmer['village']?.toString().trim() ?? '';
    final district = farmer['district']?.toString().trim() ?? '';
    final state = farmer['state']?.toString().trim() ?? '';
    final location = [village, district, state]
        .where((v) => v.isNotEmpty)
        .join(', ');

    return CommunityPost(
      id: row['id'].toString(),
      farmerId: farmerId,
      farmerName: farmer['name']?.toString() ?? 'Farmer',
      farmerImageUrl:
          farmer['profile_photo']?.toString() ?? farmer['photo_url']?.toString(),
      title: row['title']?.toString() ?? '',
      content: row['content']?.toString() ?? '',
      category: row['category']?.toString() ?? 'General',
      images: _asStringList(row['image_urls']),
      tags: _asStringList(row['tags']),
      likesCount: _asInt(row['likes_count']),
      commentsCount: _asInt(row['comments_count']),
      isLiked: likedPostIds.contains(row['id'].toString()),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
      location: location.isEmpty ? 'Unknown location' : location,
    );
  }

  CommunityPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return CommunityPost(
      id: id,
      farmerId: farmerId,
      farmerName: farmerName,
      farmerImageUrl: farmerImageUrl,
      title: title,
      content: content,
      category: category,
      images: images,
      tags: tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt,
      location: location,
    );
  }
}

class CommunityComment {
  final String id;
  final String postId;
  final String farmerId;
  final String farmerName;
  final String? farmerImageUrl;
  final String content;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerImageUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromRow(Map<String, dynamic> row) {
    return CommunityComment.fromRowWithFarmers(
      row,
      farmersById: const {},
    );
  }

  factory CommunityComment.fromRowWithFarmers(
    Map<String, dynamic> row, {
    required Map<String, Map<String, dynamic>> farmersById,
  }) {
    final farmerId = row['farmer_id']?.toString() ?? '';
    final farmer =
        farmersById[farmerId] ?? _asMap(row['farmers']);
    return CommunityComment(
      id: row['id'].toString(),
      postId: row['post_id'].toString(),
      farmerId: farmerId,
      farmerName: farmer['name']?.toString() ?? 'Farmer',
      farmerImageUrl:
          farmer['profile_photo']?.toString() ?? farmer['photo_url']?.toString(),
      content: row['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  return const <String>[];
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
