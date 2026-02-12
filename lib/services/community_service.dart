import '../models/community_post.dart';
import '../utils/dummy_data.dart';

class CommunityService {
  // Get all community posts
  static Future<List<CommunityPost>> getAllPosts() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyCommunityPosts();
  }

  // Get posts by category/topic
  static Future<List<CommunityPost>> getPostsByTopic(String topic) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyCommunityPosts()
        .where((post) => 
            post.title.toLowerCase().contains(topic.toLowerCase()) ||
            post.content.toLowerCase().contains(topic.toLowerCase()))
        .toList();
  }

  // Get post by ID
  static Future<CommunityPost?> getPostById(String id) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));
    try {
      return DummyData.getDummyCommunityPosts()
          .firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create new post
  static Future<bool> createPost(CommunityPost post) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // For demo purposes, always succeed
    return true;
  }

  // Update post
  static Future<bool> updatePost(CommunityPost post) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Delete post
  static Future<bool> deletePost(String postId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Like/unlike post
  static Future<bool> toggleLike(String postId, String userId) async {
    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // For demo purposes, always succeed
    return true;
  }

  // Add comment to post
  static Future<bool> addComment(String postId, String userId, String comment) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Get comments for post
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // Return dummy comments
    return [
      {
        'id': 'C001',
        'authorId': 'F002',
        'authorName': 'Priya Sharma',
        'authorImageUrl': 'assets/images/farmer.jpg',
        'content': 'Great tips! I\'ve been using similar techniques on my farm.',
        'timestamp': DateTime.now().subtract(Duration(hours: 1)),
      },
      {
        'id': 'C002',
        'authorId': 'F003',
        'authorName': 'Amit Singh',
        'authorImageUrl': 'assets/images/farmer.jpg',
        'content': 'Thanks for sharing this valuable information.',
        'timestamp': DateTime.now().subtract(Duration(hours: 2)),
      },
    ];
  }

  // Get trending posts
  static Future<List<CommunityPost>> getTrendingPosts() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    return DummyData.getDummyCommunityPosts()
        .where((post) => post.likes >= 50)
        .toList();
  }

  // Get recent posts
  static Future<List<CommunityPost>> getRecentPosts() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyCommunityPosts()
    .where((post) => post.createdAt.isAfter(DateTime.now().subtract(Duration(days: 7))))
    .toList();
  }

  // Search posts
  static Future<List<CommunityPost>> searchPosts(String query) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyCommunityPosts()
    .where((post) => 
      post.title.toLowerCase().contains(query.toLowerCase()) ||
      post.content.toLowerCase().contains(query.toLowerCase()) ||
      post.farmerName.toLowerCase().contains(query.toLowerCase()))
    .toList();
  }

  // Report post
  static Future<bool> reportPost(String postId, String reason) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
    
    // For demo purposes, always succeed
    return true;
  }

  // Get user's posts
  static Future<List<CommunityPost>> getUserPosts(String userId) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 1));
  return DummyData.getDummyCommunityPosts()
    .where((post) => post.farmerId == userId)
    .toList();
  }
}
