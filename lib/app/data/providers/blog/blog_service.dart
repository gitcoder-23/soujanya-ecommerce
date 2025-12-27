import 'package:martfury/app/data/models/blog_post.dart';
import 'package:martfury/src/service/base_service.dart';

class BlogService extends BaseService {
  Future<Map<String, dynamic>> getBlogPosts({
    int page = 1,
    int perPage = 10,
  }) async {
    final data = await get('/api/v1/posts?page=$page&per_page=$perPage');

    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load blog posts');
    }

    final List<BlogPost> posts = (data['data'] as List<dynamic>)
        .map((post) => BlogPost.fromJson(post as Map<String, dynamic>))
        .toList();

    final meta = data['meta'] as Map<String, dynamic>;

    return {
      'data': posts,
      'current_page': meta['current_page'] as int,
      'last_page': meta['last_page'] as int,
      'per_page': meta['per_page'] as int,
      'total': meta['total'] as int,
      'has_more': (meta['current_page'] as int) < (meta['last_page'] as int),
    };
  }

  Future<BlogPost> getBlogPostBySlug(String slug) async {
    final data = await get('/api/v1/posts/$slug');

    if (data['error'] == true) {
      throw Exception(data['message'] ?? 'Failed to load blog post');
    }

    final postData = data['data'];

    if (postData is Map<String, dynamic>) {
      return BlogPost.fromJson(postData);
    } else if (postData is List && postData.isNotEmpty) {
      return BlogPost.fromJson(postData[0] as Map<String, dynamic>);
    } else {
      throw Exception('Invalid blog post data format');
    }
  }
}
