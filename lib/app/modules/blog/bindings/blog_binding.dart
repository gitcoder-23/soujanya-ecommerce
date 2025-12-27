import 'package:get/get.dart';
import 'package:martfury/app/data/providers/blog/blog_service.dart';
import 'package:martfury/app/modules/blog/controllers/blog_controller.dart';

class BlogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogService>(() => BlogService());
    Get.lazyPut<BlogController>(
      () => BlogController(blogService: Get.find()),
    );
  }
}
