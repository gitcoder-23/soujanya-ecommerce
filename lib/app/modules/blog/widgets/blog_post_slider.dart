import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:martfury/app/data/models/blog_post.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';

class BlogPostSlider extends StatelessWidget {
  const BlogPostSlider({
    super.key,
    required this.posts,
    this.onPostTap,
  });

  final List<BlogPost> posts;
  final Function(BlogPost)? onPostTap;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes < 5) {
          return 'notifications.just_now'.tr();
        }
        return 'notifications.minutes_ago'
            .tr(namedArgs: {'minutes': '${difference.inMinutes}'});
      }
      return 'notifications.hours_ago'
          .tr(namedArgs: {'hours': '${difference.inHours}'});
    } else if (difference.inDays < 7) {
      return 'notifications.days_ago'
          .tr(namedArgs: {'days': '${difference.inDays}'});
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return GestureDetector(
            onTap: () => onPostTap?.call(post),
            child: Container(
              width: 280,
              margin: EdgeInsets.only(
                right: index < posts.length - 1 ? 16 : 0,
              ),
              decoration: BoxDecoration(
                color: AppColors.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.getBorderColor(context),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.image.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: post.image,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 140,
                          color: AppColors.getSkeletonColor(context),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 140,
                          color: AppColors.getSurfaceColor(context),
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.getHintTextColor(context),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.categories.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                post.categories.first.name,
                                style: kAppTextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (post.categories.isNotEmpty)
                            const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              post.name,
                              style: kAppTextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getPrimaryTextColor(context),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: AppColors.getHintTextColor(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(post.createdAt),
                                style: kAppTextStyle(
                                  fontSize: 11,
                                  color: AppColors.getHintTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
