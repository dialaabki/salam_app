// lib/screens/Resources/ResourceItem.dart

class ResourceItem {
  final String id; // From MongoDB _id
  final String title;
  final String description;
  final String? imageUrl; // Mapped from backend 'imageUrl' (was imagePath)
  final String type;     // Mapped from backend 'category' or 'type'
  final String? videoUrl; // Mapped from backend 'videoUrl' (was videoPath)
  final String? articleUrl; // Mapped from backend 'url' for articles

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    this.videoUrl,
    this.articleUrl,
  });

  factory ResourceItem.fromJson(Map<String, dynamic> json) {
    return ResourceItem(
    id: json['_id'] as String, // MongoDB provides _id
    title: json['title'] as String? ?? 'No Title',
    description: json['description'] as String? ?? 'No Description',
    imageUrl: json['imageUrl'] as String?,       // Matches backend
    type: json['category'] as String? ?? 'Unknown', // Map from backend 'category'
    videoUrl: json['videoUrl'] as String?,       // Matches backend
    articleUrl: json['url'] as String?,        // Matches backend 'url' for articles
    );
  }

  Map<String, dynamic> toJsonForCreation() {
    // This is what you send TO the backend when creating a new resource
    return {
      'title': title,
      'description': description,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      'category': type, // Send Flutter 'type' as backend 'category'
      if (videoUrl != null && videoUrl!.isNotEmpty) 'videoUrl': videoUrl,
      if (articleUrl != null && articleUrl!.isNotEmpty) 'url': articleUrl,
    };
  }
}