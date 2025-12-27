import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:martfury/app/modules/blog/bindings/blog_detail_binding.dart';
import 'package:martfury/app/modules/blog/controllers/blog_controller.dart';
import 'package:martfury/app/modules/blog/views/blog_post_detail_view.dart';
import 'package:martfury/app/modules/blog/widgets/blog_post_card.dart';
import 'package:martfury/src/theme/app_colors.dart';
import 'package:martfury/src/theme/app_fonts.dart';

class BlogView extends GetView<BlogController> {
  const BlogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile.blog'.tr()),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.posts.isEmpty) {
          return _buildSkeletonLoading(context);
        }

        if (controller.error.value != null && controller.posts.isEmpty) {
          return _buildErrorWidget(context);
        }

        if (controller.posts.isEmpty) {
          return _buildEmptyWidget(context);
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.posts.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.posts.length) {
                if (controller.isLoadingMore.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  );
                } else if (!controller.hasMore.value) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'blog.no_more_posts'.tr(),
                        style: kAppTextStyle(
                          fontSize: 14,
                          color: AppColors.getHintTextColor(context),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final post = controller.posts[index];
              return BlogPostCard(
                post: post,
                onTap: () {
                  Get.to(
                    () => BlogPostDetailView(slug: post.slug),
                    binding: BlogDetailBinding(slug: post.slug),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 80,
              color: AppColors.getHintTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'blog.no_posts'.tr(),
              style: kAppTextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getSecondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'blog.no_posts_description'.tr(),
              style: kAppTextStyle(
                fontSize: 14,
                color: AppColors.getHintTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              onPressed: controller.loadBlogPosts,
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildBlogPostSkeleton(context);
      },
    );
  }

  Widget _buildBlogPostSkeleton(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Container(
              width: double.infinity,
              height: 200,
              color: AppColors.getSkeletonColor(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: width * 0.6,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: width * 0.4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.getSkeletonColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.getSkeletonColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
