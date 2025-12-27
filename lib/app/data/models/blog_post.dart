class BlogCategory {
  final int id;
  final String name;
  final String slug;
  final String url;
  final String? description;

  BlogCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.url,
    this.description,
  });

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      url: json['url'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'url': url,
      'description': description,
    };
  }
}

class BlogTag {
  final int id;
  final String name;
  final String slug;

  BlogTag({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory BlogTag.fromJson(Map<String, dynamic> json) {
    return BlogTag(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class BlogPost {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? content;
  final String image;
  final List<BlogCategory> categories;
  final List<BlogTag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlogPost({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.content,
    required this.image,
    required this.categories,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      content: json['content'] as String?,
      image: json['image'] as String? ?? '',
      categories: (json['categories'] as List<dynamic>?)
              ?.map((cat) => BlogCategory.fromJson(cat as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => BlogTag.fromJson(tag as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'content': content,
      'image': image,
      'categories': categories.map((cat) => cat.toJson()).toList(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
