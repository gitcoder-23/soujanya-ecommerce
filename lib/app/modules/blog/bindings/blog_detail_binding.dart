import 'package:get/get.dart';
import 'package:martfury/app/data/providers/blog/blog_service.dart';
import 'package:martfury/app/modules/blog/controllers/blog_detail_controller.dart';

class BlogDetailBinding extends Bindings {
  BlogDetailBinding({required this.slug});

  final String slug;

  @override
  void dependencies() {
    if (!Get.isRegistered<BlogService>()) {
      Get.lazyPut<BlogService>(() => BlogService());
    }
    Get.lazyPut<BlogDetailController>(
      () => BlogDetailController(
        blogService: Get.find(),
        slug: slug,
      ),
    );
  }
}
