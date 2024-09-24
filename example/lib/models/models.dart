class YourCustomStoryGroupDto {
  final int? id;
  final String? title;
  final String? thumbnail;

  const YourCustomStoryGroupDto({
    this.id,
    this.title,
    this.thumbnail,
  });

  factory YourCustomStoryGroupDto.fromMap(Map<String, dynamic> map) {
    return YourCustomStoryGroupDto(
      id: int.tryParse('${map['id']}'),
      title: map['title']?.toString(),
      thumbnail: map['thumbnail']?.toString(),
    );
  }
}

class YourCustomStoryItemDto {
  final int? id;
  final int? groupId;
  final String? title;
  final String? text;
  final String? url;
  final String? buttonUrl;
  final dynamic data;

  const YourCustomStoryItemDto({
    this.id,
    this.groupId,
    this.title,
    this.text,
    this.url,
    this.buttonUrl,
    this.data,
  });

  factory YourCustomStoryItemDto.fromMap(Map<String, dynamic> map) {
    return YourCustomStoryItemDto(
      id: int.tryParse('${map['id']}'),
      groupId: int.tryParse('${map['group_id']}'),
      title: map['title']?.toString(),
      text: map['text']?.toString(),
      url: map['url']?.toString(),
      buttonUrl: map['button_url']?.toString(),
      data: map['data'] as dynamic,
    );
  }
}
