import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart' hide Trans;
import 'package:martfury/app/modules/blog/controllers/blog_detail_controller.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';
import 'package:share_plus/share_plus.dart';

class BlogPostDetailView extends GetView<BlogDetailController> {
  const BlogPostDetailView({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.post.value?.name ?? 'common.loading'.tr(),
          ),
        ),
        actions: [
          Obx(() {
            final post = controller.post.value;
            if (post == null) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'common.share'.tr(),
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: '${post.name}\n\n${post.description}',
                    subject: post.name,
                  ),
                );
              },
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildSkeletonLoading(context);
        }

        if (controller.error.value != null) {
          return _buildErrorWidget(context);
        }

        final post = controller.post.value;
        if (post == null) {
          return _buildErrorWidget(context);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.image.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: post.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
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
                    height: 250,
                    color: AppColors.getSurfaceColor(context),
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.getHintTextColor(context),
                      size: 48,
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
                            .map(
                              (category) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  category.name,
                                  style: kAppTextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    if (post.categories.isNotEmpty) const SizedBox(height: 16),
                    Text(
                      post.name,
                      style: kAppTextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.getHintTextColor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(post.createdAt),
                          style: kAppTextStyle(
                            fontSize: 14,
                            color: AppColors.getHintTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (post.description.isNotEmpty) ...[
                      Text(
                        post.description,
                        style: kAppTextStyle(
                          fontSize: 16,
                          color: AppColors.getSecondaryTextColor(context),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: AppColors.getBorderColor(context),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (post.content != null && post.content!.isNotEmpty)
                      HtmlWidget(
                        post.content!,
                        textStyle: kAppTextStyle(
                          fontSize: 15,
                          color: AppColors.getPrimaryTextColor(context),
                          height: 1.6,
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (post.tags.isNotEmpty) ...[
                      Text(
                        'blog.tags'.tr(),
                        style: kAppTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.getSurfaceColor(context),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.getBorderColor(context),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.label,
                                      size: 14,
                                      color: AppColors.getSecondaryTextColor(context),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      tag.name,
                                      style: kAppTextStyle(
                                        fontSize: 13,
                                        color: AppColors.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.getHintTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'common.error_occurred'.tr(),
              style: kAppTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.error.value ?? 'common.unknown_error'.tr(),
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getHintTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadPost,
              icon: const Icon(Icons.refresh),
              label: Text('common.try_again'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: AppColors.getSkeletonColor(context),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 90,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 80,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width * 0.8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width * 0.6,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  color: AppColors.getSkeletonColor(context),
                ),
                const SizedBox(height: 20),
                ...List.generate(6, (index) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 15,
                        decoration: BoxDecoration(
                          color: AppColors.getSkeletonColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 15,
                        decoration: BoxDecoration(
                          color: AppColors.getSkeletonColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: width * 0.7,
                        height: 15,
                        decoration: BoxDecoration(
                          color: AppColors.getSkeletonColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 80 + (index * 10),
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
