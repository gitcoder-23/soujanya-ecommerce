class HelpItem {
  final String question;
  final String answer;

  HelpItem({
    required this.question,
    required this.answer,
  });

  factory HelpItem.fromJson(Map<String, dynamic> json) {
    return HelpItem(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
    };
  }
}

class HelpCategory {
  final String id;
  final String title;
  final String icon;
  final List<HelpItem> items;

  HelpCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.items,
  });

  factory HelpCategory.fromJson(Map<String, dynamic> json) {
    return HelpCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => HelpItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
