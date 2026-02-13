import 'package:flutter/material.dart';
import '../models/community_post.dart';
import '../services/community_service.dart';

class CommunityProvider with ChangeNotifier {
  List<CommunityPost> _posts = [];
  List<CommunityPost> _filteredPosts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedTopic = '';

  // Getters
  List<CommunityPost> get posts => _filteredPosts;
  List<CommunityPost> get allPosts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedTopic => _selectedTopic;

  // Initialize posts
  Future<void> loadPosts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _posts = await CommunityService.getAllPosts();
      _filteredPosts = _posts;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search posts
  Future<void> searchPosts(String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();
    
    try {
      if (query.isEmpty) {
        _filteredPosts = _posts;
      } else {
        _filteredPosts = await CommunityService.searchPosts(query);
      }
      notifyListeners();
    } catch (e) {
      _setError('Search failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter by topic
  Future<void> filterByTopic(String topic) async {
    _selectedTopic = topic;
    _setLoading(true);
    _clearError();
    
    try {
      if (topic.isEmpty) {
        _filteredPosts = _posts;
      } else {
        _filteredPosts = await CommunityService.getPostsByTopic(topic);
      }
      notifyListeners();
    } catch (e) {
      _setError('Filter failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get post by ID
  Future<CommunityPost?> getPostById(String id) async {
    try {
      return await CommunityService.getPostById(id);
    } catch (e) {
      _setError('Failed to get post: $e');
      return null;
    }
  }

  // Create post
  Future<bool> createPost(CommunityPost post) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await CommunityService.createPost(post);
      if (success) {
        _posts.insert(0, post);
        _filteredPosts = _posts;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to create post: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update post
  Future<bool> updatePost(CommunityPost post) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await CommunityService.updatePost(post);
      if (success) {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post;
          _filteredPosts = _posts;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to update post: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete post
  Future<bool> deletePost(String postId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await CommunityService.deletePost(postId);
      if (success) {
        _posts.removeWhere((p) => p.id == postId);
        _filteredPosts = _posts;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Failed to delete post: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle like
  Future<bool> toggleLike(String postId, String userId) async {
    try {
      final success = await CommunityService.toggleLike(postId, userId);
      if (success) {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = CommunityPost(
            id: post.id,
            farmerId: post.farmerId,
            farmerName: post.farmerName,
            farmerImage: post.farmerImage,
            title: post.title,
            content: post.content,
            category: post.category,
            images: post.images,
            tags: post.tags,
            likes: post.likes + 1,
            comments: post.comments,
            shares: post.shares,
            isLiked: true,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            commentsList: post.commentsList,
            location: post.location,
            isVerified: post.isVerified,
          );
          _filteredPosts = _posts;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to toggle like: $e');
      return false;
    }
  }

  // Add comment
  Future<bool> addComment(String postId, String userId, String comment) async {
    try {
      final success = await CommunityService.addComment(postId, userId, comment);
      if (success) {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = CommunityPost(
            id: post.id,
            farmerId: post.farmerId,
            farmerName: post.farmerName,
            farmerImage: post.farmerImage,
            title: post.title,
            content: post.content,
            category: post.category,
            images: post.images,
            tags: post.tags,
            likes: post.likes,
            comments: post.comments + 1,
            shares: post.shares,
            isLiked: post.isLiked,
            createdAt: post.createdAt,
            updatedAt: post.updatedAt,
            commentsList: post.commentsList,
            location: post.location,
            isVerified: post.isVerified,
          );
          _filteredPosts = _posts;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to add comment: $e');
      return false;
    }
  }

  // Get comments
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      return await CommunityService.getComments(postId);
    } catch (e) {
      _setError('Failed to get comments: $e');
      return [];
    }
  }

  // Get trending posts
  Future<List<CommunityPost>> getTrendingPosts() async {
    try {
      return await CommunityService.getTrendingPosts();
    } catch (e) {
      _setError('Failed to get trending posts: $e');
      return [];
    }
  }

  // Get recent posts
  Future<List<CommunityPost>> getRecentPosts() async {
    try {
      return await CommunityService.getRecentPosts();
    } catch (e) {
      _setError('Failed to get recent posts: $e');
      return [];
    }
  }

  // Get user posts
  Future<List<CommunityPost>> getUserPosts(String userId) async {
    try {
      return await CommunityService.getUserPosts(userId);
    } catch (e) {
      _setError('Failed to get user posts: $e');
      return [];
    }
  }

  // Report post
  Future<bool> reportPost(String postId, String reason) async {
    try {
      return await CommunityService.reportPost(postId, reason);
    } catch (e) {
      _setError('Failed to report post: $e');
      return false;
    }
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedTopic = '';
    _filteredPosts = _posts;
    notifyListeners();
  }

  // Refresh posts
  Future<void> refresh() async {
    await loadPosts();
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
