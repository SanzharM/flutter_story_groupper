part of 'story_bloc.dart';

enum StateStatus { initial, loading, error, success }

class StoryState extends Equatable {
  const StoryState({
    this.storyGroups = const [],
    this.currentStoryGroupId = -1,
    this.groupItems = const {},
    this.status = StateStatus.initial,
    this.message = '',
  });

  final List<StoryGroupModel> storyGroups;
  final int currentStoryGroupId;
  final Map<int, List<StoryItemModel>> groupItems;
  final StateStatus status;
  final String message;

  StoryGroupModel? get currentStoryGroup {
    return storyGroups.firstWhereOrNull((e) => currentStoryGroupId == e.id);
  }

  int get currentStoryGroupIndex {
    return storyGroups.indexWhere((e) => e.id == currentStoryGroupId);
  }

  @override
  List<Object> get props {
    return [
      storyGroups,
      currentStoryGroupId,
      groupItems,
      status,
      message,
    ];
  }

  StoryState copyWith({
    List<StoryGroupModel>? storyGroups,
    int? currentStoryGroupId,
    Map<int, List<StoryItemModel>>? groupItems,
    StateStatus? status,
    String? message,
  }) {
    return StoryState(
      storyGroups: storyGroups ?? this.storyGroups,
      currentStoryGroupId: currentStoryGroupId ?? this.currentStoryGroupId,
      groupItems: groupItems ?? this.groupItems,
      status: status ?? this.status,
      message: message ?? '',
    );
  }
}
