class StoryItemModel {
  final int? id;
  final String? imageUrl;
  final Duration? duration;

  const StoryItemModel({
    this.id,
    this.imageUrl,
    this.duration,
  });

  StoryItemModel copyWith({
    int? id,
    String? imageUrl,
    Duration? duration,
  }) {
    return StoryItemModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StoryItemModel &&
        other.id == id &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ imageUrl.hashCode ^ duration.hashCode;

  @override
  String toString() {
    return 'StoryItemModel(id: $id, duration: $duration, imageUrl: $imageUrl)';
  }
}
