import 'package:get/get.dart';
import 'package:martfury/app/data/models/blog_post.dart';
import 'package:martfury/app/data/providers/blog/blog_service.dart';
import 'package:martfury/src/service/base_service.dart';

class BlogDetailController extends GetxController {
  BlogDetailController({
    required BlogService blogService,
    required this.slug,
  }) : _blogService = blogService;

  final BlogService _blogService;
  final String slug;

  final isLoading = true.obs;
  final error = RxnString();
  final post = Rxn<BlogPost>();

  @override
  void onInit() {
    super.onInit();
    loadPost();
  }

  Future<void> loadPost() async {
    isLoading.value = true;
    error.value = null;

    try {
      final fetchedPost = await _blogService.getBlogPostBySlug(slug);
      post.value = fetchedPost;
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
}
