class NewsModel {
  final DateTime date;
  final String title;
  final String message;
  final String image;

  NewsModel({
    required this.date,
    required this.title,
    required this.message,
    required this.image,
  });

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    // Helper function to fix asset paths
    String fixAssetPath(String path) {
      if (path.startsWith('http')) return path; // Network URLs are fine
      if (path.startsWith('images/')) return 'assets/$path'; // Fix asset paths
      return path;
    }

    return NewsModel(
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      message: map['message'] as String,
      image: fixAssetPath(map['image'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'message': message,
      'image': image,
    };
  }
} 