import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../app_extensions.dart';
import '../constants/app_colors.dart';
import '../models/community_post.dart';
import '../providers/community_provider.dart';
import '../services/storage_service.dart';
import 'add_community_post_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StorageService _storageService = StorageService();
  final List<String> _categories = const <String>[
    'All',
    'Farming Tips',
    'Market Updates',
    'Weather Alerts',
    'Success Stories',
    'Questions & Answers',
  ];

  // Helper to convert internal keys (database) to display text (UI)
  String _getLocalizedCategory(String key) {
    switch (key) {
      case 'All':
        return context.l10n.catAll;
      case 'Farming Tips':
        return context.l10n.catFarmingTips;
      case 'Market Updates':
        return context.l10n.catMarketUpdates;
      case 'Weather Alerts':
        return context.l10n.catWeatherAlerts;
      case 'Success Stories':
        return context.l10n.catSuccessStories;
      case 'Questions & Answers':
        return context.l10n.catQA;
      default:
        return key;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(communityRealtimeProvider);
    final postsAsync = ref.watch(communityPostsProvider);
    final filteredPosts = ref.watch(filteredCommunityPostsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildCategories(),
              Expanded(
                child: postsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _errorState('${context.l10n.commErrorLoad}\n$e'),
                  data: (_) {
                    if (filteredPosts.isEmpty) {
                      return _emptyState();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: filteredPosts.length,
                      itemBuilder:
                          (context, index) =>
                              _buildPostCard(filteredPosts[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePostPage,
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.navCommunity,
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                context.l10n.commSubtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              color: AppColors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final query = ref.watch(searchQueryProvider);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: context.l10n.commSearchHint,
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon:
                query.trim().isEmpty
                    ? null
                    : IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
      ),
    ));
  }

  Widget _buildCategories() {
    final selected = ref.watch(postCategoryProvider);
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = selected == category;
          return GestureDetector(
            onTap:
                () => ref.read(postCategoryProvider.notifier).state = category,
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getLocalizedCategory(category),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final avatar = post.farmerImageUrl;
    final hasAvatar = avatar != null && avatar.trim().isNotEmpty;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
                  child: hasAvatar ? null : const Icon(Icons.person_outline),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.farmerName,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        post.location,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (currentUserId != null &&
                        currentUserId == post.farmerId)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18.sp,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Delete post',
                        onPressed: () => _deletePost(post),
                      ),
                    Text(
                      _getTimeAgo(post.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    post.category,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  post.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  post.content,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (post.tags.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    children:
                        post.tags
                            .map(
                              (tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.greyLight,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
                if (post.images.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      post.images.first,
                      height: 180.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          height: 180.h,
                          color: AppColors.greyLight,
                          alignment: Alignment.center,
                          child: const Text('Image unavailable'),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                _actionButton(
                  post.isLiked
                      ? FontAwesomeIcons.solidHeart
                      : FontAwesomeIcons.heart,
                  '${post.likesCount}',
                  post.isLiked ? AppColors.error : AppColors.textSecondary,
                  () => ref
                      .read(communityActionsProvider.notifier)
                      .toggleLike(post),
                ),
                SizedBox(width: 24.w),
                _actionButton(
                  FontAwesomeIcons.comment,
                  '${post.commentsCount}',
                  AppColors.textSecondary,
                  () => _showCommentsDialog(post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(CommunityPost post) async {
    try {
      await ref.read(communityActionsProvider.notifier).deletePost(
            postId: post.id,
          );
      ref.invalidate(communityPostsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete post. $e')),
      );
    }
  }

  Widget _actionButton(
    IconData icon,
    String count,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 4.w),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreatePostDialog() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    String selectedCategory = _categories[1];
    bool isSubmitting = false;
    File? selectedImageFile;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title:  Text(context.l10n.commBtnCreate),
              content: SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      items: _categories
                          .where((e) => e != 'All')
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(_getLocalizedCategory(c)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedCategory = value);
                      },
                      decoration:  InputDecoration(labelText: context.l10n.addProductLabelCategory),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration:  InputDecoration(labelText: context.l10n.commLabelTitle),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration:  InputDecoration(labelText: context.l10n.commLabelContent),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tagsController,
                      decoration:  InputDecoration(labelText: context.l10n.commLabelTags),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final file =
                                  await _storageService.pickAndCompressImage();
                              if (file == null) return;
                              setDialogState(() => selectedImageFile = file);
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        selectedImageFile == null
                            ? context.l10n.commBtnAddPhoto
                            : context.l10n.commBtnChangePhoto,
                      ),
                    ),
                    if (selectedImageFile != null) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            selectedImageFile!,
                            fit: BoxFit.cover,
                            cacheWidth: 720,
                            filterQuality: FilterQuality.low,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                height: 120,
                                color: AppColors.greyLight,
                                alignment: Alignment.center,
                                child: const Text('Preview unavailable'),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child:  Text(context.l10n.btnCancel),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();
                    if (title.isEmpty || content.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.commMsgRequired),
                        ),
                      );
                      return;
                    }
                    final tags = tagsController.text
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .toList();

                    setDialogState(() => isSubmitting = true);
                    try {
                      await ref
                          .read(communityActionsProvider.notifier)
                          .createPost(
                            category: selectedCategory,
                            title: title,
                            content: content,
                            tags: tags,
                            imageFile: selectedImageFile,
                          );
                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text(context.l10n.commMsgSuccess)),
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(context.l10n.commPostError(e.toString()))),
                      );
                    } finally {
                      if (dialogContext.mounted) {
                        setDialogState(() => isSubmitting = false);
                      }
                    }
                  },
                  child: Text(isSubmitting ? context.l10n.btnPosting : context.l10n.btnPost),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openCreatePostPage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (_) => AddCommunityPostScreen(
              categories: _categories.where((e) => e != 'All').toList(),
            ),
      ),
    );
    if (created == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully.')),
      );
    }
  }

  Future<void> _showCommentsDialog(CommunityPost post) async {
    final inputController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    context.l10n.commCommentsTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final commentsAsync = ref.watch(
                        commentsByPostProvider(post.id),
                      );
                      return commentsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => _errorState(context.l10n.commCommentsError),
                        data: (comments) {
                          if (comments.isEmpty) {
                            return _emptyState(label: context.l10n.commCommentsEmpty);
                          }
                          return ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final c = comments[index];
                              final hasAvatar =
                                  c.farmerImageUrl != null &&
                                  c.farmerImageUrl!.trim().isNotEmpty;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      hasAvatar
                                          ? NetworkImage(c.farmerImageUrl!)
                                          : null,
                                  child:
                                      hasAvatar
                                          ? null
                                          : const Icon(Icons.person_outline),
                                ),
                                title: Text(c.farmerName),
                                subtitle: Text(c.content),
                                trailing: Text(
                                  _getTimeAgo(c.createdAt),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          decoration: InputDecoration(
                            hintText: context.l10n.commCommentsHint,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = inputController.text.trim();
                          if (text.isEmpty) return;
                          await ref
                              .read(communityActionsProvider.notifier)
                              .addComment(postId: post.id, content: text);
                          inputController.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState({String label = ''}) {
    if (label.isEmpty) label = context.l10n.commEmptyState;
    return Center(
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
