import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:martfury/app/data/models/blog_post.dart';
import 'package:martfury/app/data/providers/blog/blog_service.dart';
import 'package:martfury/src/service/base_service.dart';

class BlogController extends GetxController {
  BlogController({required BlogService blogService})
      : _blogService = blogService;

  final BlogService _blogService;
  final ScrollController scrollController = ScrollController();

  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final error = RxnString();
  final posts = <BlogPost>[].obs;

  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    loadBlogPosts();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMore.value &&
        !isLoading.value) {
      loadMorePosts();
    }
  }

  Future<void> loadBlogPosts({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      posts.clear();
    }

    isLoading.value = true;
    error.value = null;

    try {
      final response = await _blogService.getBlogPosts(
        page: currentPage.value,
        perPage: 10,
      );

      final List<BlogPost> fetchedPosts =
          response['data'] as List<BlogPost>;

      if (refresh) {
        posts.assignAll(fetchedPosts);
      } else {
        posts.addAll(fetchedPosts);
      }

      currentPage.value = response['current_page'] as int;
      lastPage.value = response['last_page'] as int;
      total.value = response['total'] as int;
      hasMore.value = response['has_more'] as bool;
    } catch (e) {
      if (e is! MaintenanceException &&
          e is! NoInternetException &&
          e is! ServerErrorException) {
        error.value = e.toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMorePosts() async {
    if (!hasMore.value || isLoadingMore.value) return;

    isLoadingMore.value = true;

    try {
      final nextPage = currentPage.value + 1;
      final response = await _blogService.getBlogPosts(
        page: nextPage,
        perPage: 10,
      );

      final List<BlogPost> fetchedPosts =
          response['data'] as List<BlogPost>;

      posts.addAll(fetchedPosts);

      currentPage.value = response['current_page'] as int;
      lastPage.value = response['last_page'] as int;
      total.value = response['total'] as int;
      hasMore.value = response['has_more'] as bool;
    } catch (e) {
      debugPrint('Error loading more posts: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadBlogPosts(refresh: true);
  }
}
