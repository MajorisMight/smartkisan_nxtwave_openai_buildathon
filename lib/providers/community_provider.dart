import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

import '../models/community_post.dart';
import 'profile_provider.dart';

final postCategoryProvider = StateProvider<String>((ref) => 'All');
final searchQueryProvider = StateProvider<String>((ref) => '');

class CommunityFarmerIdentity {
  final String name;
  final String? photoUrl;

  const CommunityFarmerIdentity({
    required this.name,
    required this.photoUrl,
  });
}

final farmerIdentityProvider =
    FutureProvider.family<CommunityFarmerIdentity, String>((ref, farmerId) async {
  final supabase = ref.watch(supabaseClientProvider);
  final id = farmerId.trim();
  if (id.isEmpty) {
    return const CommunityFarmerIdentity(name: 'Farmer', photoUrl: null);
  }

  try {
    final row = await supabase
        .from('farmers')
        .select('name, photo_url')
        .eq('id', id)
        .maybeSingle();

    if (row == null) {
      return const CommunityFarmerIdentity(name: 'Farmer', photoUrl: null);
    }

    final map = Map<String, dynamic>.from(row);
    final name = (map['name']?.toString() ?? '').trim();
    final photo = (map['photo_url']?.toString() ?? '').trim();
    return CommunityFarmerIdentity(
      name: name.isEmpty ? 'Farmer' : name,
      photoUrl: photo.isEmpty ? null : photo,
    );
  } catch (_) {
    return const CommunityFarmerIdentity(name: 'Farmer', photoUrl: null);
  }
});

final communityPostsProvider = FutureProvider<List<CommunityPost>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return const <CommunityPost>[];

  // ignore: avoid_print
  print('[CommunityProvider] Fetching posts for user=$userId');
  final rawPosts = await supabase
      .from('posts')
      .select(
        'id, farmer_id, category, title, content, image_urls, tags, likes_count, comments_count, created_at',
      )
      .order('created_at', ascending: false);

  final rawLikes = await supabase
      .from('post_likes')
      .select('post_id')
      .eq('farmer_id', userId);

  final likedPostIds = List<Map<String, dynamic>>.from(rawLikes as List)
      .map((e) => e['post_id'].toString())
      .toSet();

  final postRows = List<Map<String, dynamic>>.from(rawPosts as List);
  // ignore: avoid_print
  print('[CommunityProvider] Posts fetched=${postRows.length}');
  final farmerIds = postRows.map((row) => row['farmer_id'].toString());
  final farmersById = await _loadFarmersByIds(
    supabase,
    farmerIds,
    columns: 'id, name, photo_url, village, district, state',
  );
  // ignore: avoid_print
  print('[CommunityProvider] Farmers fetched=${farmersById.length}');

  return postRows
      .map(
        (row) => CommunityPost.fromRow(
          row,
          likedPostIds: likedPostIds,
          farmersById: farmersById,
        ),
      )
      .toList();
});

final filteredCommunityPostsProvider = Provider<List<CommunityPost>>((ref) {
  final category = ref.watch(postCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final posts = ref.watch(communityPostsProvider).valueOrNull ?? const [];

  return posts.where((post) {
    final categoryMatch = category == 'All' || post.category == category;
    if (!categoryMatch) return false;
    if (query.isEmpty) return true;

    final searchableText = <String>[
      post.title,
      post.content,
      post.category,
      post.farmerName,
      post.location,
      ...post.tags,
    ].join(' ').toLowerCase();

    return searchableText.contains(query);
  }).toList();
});

final commentsByPostProvider =
    FutureProvider.family<List<CommunityComment>, String>((ref, postId) async {
  final supabase = ref.watch(supabaseClientProvider);
  // ignore: avoid_print
  print('[CommunityProvider] Fetching comments for post=$postId');
  final rows = await supabase
      .from('comments')
      .select(
        'id, post_id, farmer_id, content, created_at',
      )
      .eq('post_id', postId)
      .order('created_at', ascending: false);

  final commentRows = List<Map<String, dynamic>>.from(rows as List);
  // ignore: avoid_print
  print('[CommunityProvider] Comments fetched=${commentRows.length} for post=$postId');
  final farmerIds = commentRows.map((row) => row['farmer_id'].toString());
  final farmersById = await _loadFarmersByIds(
    supabase,
    farmerIds,
    columns: 'id, name, photo_url',
  );

  return commentRows
      .map(
        (row) => CommunityComment.fromRowWithFarmers(
          row,
          farmersById: farmersById,
        ),
      )
      .toList();
});

// Keeps community feed and comment counts in sync with DB changes.
final communityRealtimeProvider = Provider<void>((ref) {
  final supabase = ref.watch(supabaseClientProvider);

  final channel = supabase
      .channel('community-realtime')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'posts',
        callback: (_) {
          ref.invalidate(communityPostsProvider);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'post_likes',
        callback: (_) {
          ref.invalidate(communityPostsProvider);
        },
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'comments',
        callback: (payload) {
          ref.invalidate(communityPostsProvider);
          final postId = _extractPostIdFromPayload(payload);
          if (postId != null && postId.isNotEmpty) {
            ref.invalidate(commentsByPostProvider(postId));
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    supabase.removeChannel(channel);
  });
});

class CommunityActionsNotifier extends StateNotifier<AsyncValue<void>> {
  CommunityActionsNotifier(this.ref) : super(const AsyncValue.data(null));

  final Ref ref;

  // Creates a post and refreshes post list so UI shows latest data.
  Future<void> createPost({
    required String category,
    required String title,
    required String content,
    List<String> tags = const [],
    List<String> imageUrls = const [],
    File? imageFile,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncValue.loading();
    try {
      final urls = <String>[...imageUrls];
      if (imageFile != null) {
        final uploadedUrl = await _uploadPostImage(
          supabase: supabase,
          userId: user.id,
          imageFile: imageFile,
        );
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw Exception('Image upload failed');
        }
        urls.add(uploadedUrl);
      }
      final position = await _tryGetCurrentPosition();
      final locationPoint = position == null
          ? null
          : _toPostgisPoint(position.latitude, position.longitude);
      final isPest = tags.any((tag) => tag.trim().toLowerCase() == 'pest');

      await supabase.from('posts').insert({
        'farmer_id': user.id,
        'category': category,
        'title': title,
        'content': content,
        'tags': tags,
        'image_urls': urls,
        if (locationPoint != null) 'location': locationPoint,
        if (isPest && position != null) 'latitude': position.latitude,
        if (isPest && position != null) 'longitude': position.longitude,
      });
      ref.invalidate(communityPostsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Toggles like in pivot table and mirrors count in posts table.
  Future<void> toggleLike(CommunityPost post) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (post.isLiked) {
        await supabase
            .from('post_likes')
            .delete()
            .eq('post_id', post.id)
            .eq('farmer_id', user.id);
      } else {
        await supabase.from('post_likes').insert({
          'post_id': post.id,
          'farmer_id': user.id,
        });
      }

      final newCount = post.isLiked
          ? (post.likesCount > 0 ? post.likesCount - 1 : 0)
          : post.likesCount + 1;

      await supabase
          .from('posts')
          .update({'likes_count': newCount})
          .eq('id', post.id);

      ref.invalidate(communityPostsProvider);
    });
  }

  // Adds a comment and updates denormalized comments_count for quick list UI.
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase.from('comments').insert({
        'post_id': postId,
        'farmer_id': user.id,
        'content': content,
      });

      final rows = await supabase
          .from('comments')
          .select('id')
          .eq('post_id', postId);

      await supabase
          .from('posts')
          .update({'comments_count': (rows as List).length})
          .eq('id', postId);

      ref.invalidate(communityPostsProvider);
      ref.invalidate(commentsByPostProvider(postId));
    });
  }

  Future<void> deletePost({
    required String postId,
  }) async {
    final supabase = ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('farmer_id', user.id);

      ref.invalidate(communityPostsProvider);
    });
  }

  Future<String?> _uploadPostImage({
    required SupabaseClient supabase,
    required String userId,
    required File imageFile,
  }) async {
    final fileToUpload = await _compressForUpload(imageFile);
    final ext = p.extension(fileToUpload.path).toLowerCase();
    final fileExt = ext.isEmpty ? '.jpg' : ext;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
    final filePath = '$userId/$fileName';

    await supabase.storage.from('community').upload(
          filePath,
          fileToUpload,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return supabase.storage.from('community').getPublicUrl(filePath);
  }

  Future<File> _compressForUpload(File source) async {
    try {
      final sourceSize = source.lengthSync();
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          p.join(tempDir.path, 'community_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final compressed = await FlutterImageCompress.compressAndGetFile(
        source.path,
        targetPath,
        quality: 70,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        return source;
      }

      final compressedFile = File(compressed.path);
      final compressedSize = compressedFile.lengthSync();
      final ratio =
          sourceSize == 0 ? 0 : ((sourceSize - compressedSize) / sourceSize) * 100;
      // ignore: avoid_print
      print(
        'Community image compressed: original=$sourceSize bytes, compressed=$compressedSize bytes, saved=${ratio.toStringAsFixed(1)}%',
      );
      return compressedFile;
    } on MissingPluginException {
      return source;
    } on PlatformException {
      return source;
    } catch (_) {
      return source;
    }
  }

  Future<Position?> _tryGetCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return position;
    } catch (_) {
      return null;
    }
  }

  String _toPostgisPoint(double latitude, double longitude) {
    return 'SRID=4326;POINT($longitude $latitude)';
  }
}

final communityActionsProvider =
    StateNotifierProvider<CommunityActionsNotifier, AsyncValue<void>>((ref) {
  return CommunityActionsNotifier(ref);
});

String? _extractPostIdFromPayload(PostgresChangePayload payload) {
  final newRecord = payload.newRecord;
  final oldRecord = payload.oldRecord;

  final fromNew = newRecord['post_id']?.toString();
  if (fromNew != null && fromNew.isNotEmpty) return fromNew;

  final fromOld = oldRecord['post_id']?.toString();
  if (fromOld != null && fromOld.isNotEmpty) return fromOld;

  return null;
}

Future<Map<String, Map<String, dynamic>>> _loadFarmersByIds(
  SupabaseClient supabase,
  Iterable<String> farmerIds, {
  required String columns,
}) async {
  final ids = farmerIds
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();

  if (ids.isEmpty) return const <String, Map<String, dynamic>>{};

  try {
    final rows = await supabase
        .from('farmers')
        .select(columns)
        .inFilter('id', ids);

    final out = <String, Map<String, dynamic>>{};
    for (final row in List<Map<String, dynamic>>.from(rows as List)) {
      final id = row['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        out[id] = row;
      }
    }
    // ignore: avoid_print
    print('[CommunityProvider] Farmers lookup success ids=${ids.length} found=${out.length}');
    return out;
  } catch (_) {
    // Keep feed usable even if profile read is blocked by policy.
    // ignore: avoid_print
    print('[CommunityProvider] Farmers lookup failed (likely RLS/policy)');
    return const <String, Map<String, dynamic>>{};
  }
}
