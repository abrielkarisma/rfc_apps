class Artikel {
  final String createdAt;
  final String title;
  final String images;
  final String description;
  final String id;

  Artikel({
    required this.createdAt,
    required this.title,
    required this.images,
    required this.description,
    required this.id,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      createdAt: json['createdAt'],
      title: json['title'],
      images: json['images'],
      description: json['description'],
      id: json['id'],
    );
  }
}
