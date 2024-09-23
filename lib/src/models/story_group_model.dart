class StoryGroupModel {
  final int? id;
  final String? thumbnail;
  final Duration? duration;

  const StoryGroupModel({
    this.id,
    this.thumbnail,
    this.duration,
  });

  StoryGroupModel copyWith({
    int? id,
    String? thumbnail,
    Duration? duration,
  }) {
    return StoryGroupModel(
      id: id ?? this.id,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StoryGroupModel &&
        other.id == id &&
        other.thumbnail == thumbnail;
  }

  @override
  int get hashCode => id.hashCode ^ thumbnail.hashCode ^ duration.hashCode;

  @override
  String toString() {
    return 'StoryGroupModel(id: $id, duration: $duration, thumbnail: $thumbnail)';
  }
}
