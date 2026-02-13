import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan/utils/consistent_data_service.dart';
import '../models/community_post.dart'; 

// Provider 1: Manages the selected category filter
final postCategoryProvider = StateProvider<String>((ref) => 'All');

// 2. Create a Notifier class to manage the list of posts.
class CommunityPostsNotifier extends StateNotifier<List<CommunityPost>> {
  // Initialize the notifier with the list of demo posts.
  CommunityPostsNotifier() : super(ConsistentDataService.getCommunityPosts());

  // This method contains the logic to toggle a like on a post.
  void likePost(String postId) {
    // We create a new list because state in Riverpod should be immutable.
    state = [
      for (final post in state)
        if (post.id == postId)
          // Use a 'copyWith' method on your model to create an updated copy
          post.copyWith(
            isLiked: !post.isLiked,
            likes: post.isLiked ? post.likes - 1 : post.likes + 1,
          )
        else
          post,
    ];
  }
}

// 3. Create a StateNotifierProvider for your new notifier.
final communityPostsProvider = StateNotifierProvider<CommunityPostsNotifier, List<CommunityPost>>((ref) {
  return CommunityPostsNotifier();
});
// 4. Provider for search query state
final searchQueryProvider = StateProvider<String>((ref) => '');
// Provider 5: Provides the final, filtered list to the UI
final filteredCommunityPostsProvider = Provider<List<CommunityPost>>((ref) {
  final category = ref.watch(postCategoryProvider);
  final allPosts = ref.watch(communityPostsProvider);

  if (category == 'All') {
    return allPosts;
  }
  
  return allPosts.where((post) => post.category == category).toList();
});