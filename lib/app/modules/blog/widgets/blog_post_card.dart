import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:martfury/app/data/models/blog_post.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';

class BlogPostCard extends StatelessWidget {
  const BlogPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  final BlogPost post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: post.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.getSurfaceColor(context),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.getSurfaceColor(context),
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.getHintTextColor(context),
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.categories.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: post.categories
                          .take(2)
                          .map(
                            (category) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category.name,
                                style: kAppTextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (post.categories.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    post.name,
                    style: kAppTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getPrimaryTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (post.description.isNotEmpty)
                    Text(
                      post.description,
                      style: kAppTextStyle(
                        fontSize: 14,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.getHintTextColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(post.createdAt),
                        style: kAppTextStyle(
                          fontSize: 12,
                          color: AppColors.getHintTextColor(context),
                        ),
                      ),
                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.label_outline,
                          size: 14,
                          color: AppColors.getHintTextColor(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.tags.map((tag) => tag.name).join(', '),
                            style: kAppTextStyle(
                              fontSize: 12,
                              color: AppColors.getHintTextColor(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
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
}
