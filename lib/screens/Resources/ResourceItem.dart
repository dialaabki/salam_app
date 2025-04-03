// Defines the data structure for a resource item.

class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String
  imagePath; // Path for thumbnail/article image (e.g., 'assets/images/videopic.png')
  final String type; // 'Article', 'Video', or 'Quiz'
  final String?
  videoPath; // Path for video file within assets/videos/ (e.g., 'stress_video.mp4') or null

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.type,
    this.videoPath, // Optional: only relevant for 'Video' type
  });
}
