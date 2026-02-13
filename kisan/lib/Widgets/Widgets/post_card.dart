import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan/constants/app_colors.dart';
import 'package:kisan/models/community_post.dart';
import 'package:kisan/providers/community_provider.dart';

class PostCard extends ConsumerWidget {
  final CommunityPost post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
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
          // Post Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: AssetImage('assets/images/farmer.jpg'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.farmerName,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (post.isVerified)
                            Container(
                              margin: EdgeInsets.only(left: 4.w),
                              child: Icon(
                                Icons.verified,
                                color: AppColors.primaryGreen,
                                size: 16.sp,
                              ),
                            ),
                        ],
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
                Text(
                  getTimeAgo(post.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Post Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
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
                    children: post.tags.map<Widget>((tag) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          // Post Images
          if (post.images.isNotEmpty)
            Container(
              height: 200.h,
              margin: EdgeInsets.all(16.w),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        'assets/images/farmer.jpg',
                        fit: BoxFit.cover,
                      ),
                      // The following code is commented out because local assets are used instead of network images:
                      /*
                      child: CachedNetworkImage(
                        imageUrl: post.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.greyLight,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.greyLight,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.grey,
                            size: 40.sp,
                          ),
                        ),
                      ),
                      */
                    ),
                  );
                },
              ),
            ),
          
          // Post Actions
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                buildActionButton(
                  post.isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  '${post.likes}',
                  post.isLiked ? AppColors.error : AppColors.textSecondary,
                  () {
                    // Call the method on the notifier
                    ref.read(communityPostsProvider.notifier).likePost(post.id);
                  },
                ),
                SizedBox(width: 24.w),
                buildActionButton(
                  FontAwesomeIcons.comment,
                  '${post.comments}',
                  AppColors.textSecondary,
                  () => showCommentsDialog(post, context),
                ),
                buildActionButton(
                  FontAwesomeIcons.share,
                  '${post.shares}',
                  AppColors.textSecondary,
                  () {
                    //TODO: Share functionality
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showMoreOptions(post, context);
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

Widget buildActionButton(IconData icon, String count, Color color, VoidCallback onTap) {
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


void showCommentsDialog(post, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Comments'),
      content: Text('Comments feature will be implemented here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}

void showMoreOptions(post, BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.bookmark_outline),
            title: Text('Save Post'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.report_outlined),
            title: Text('Report Post'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.block_outlined),
            title: Text('Block User'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

String getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}

void showCreatePostDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Create New Post'),
      content: Text('This feature will allow you to create new community posts.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}


