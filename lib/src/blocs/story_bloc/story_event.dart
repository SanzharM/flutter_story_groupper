part of 'story_bloc.dart';

sealed class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object> get props => [];
}

final class StoryGetItemsEvent extends StoryEvent {
  final int groupId;

  const StoryGetItemsEvent(this.groupId);

  @override
  List<Object> get props => [groupId];
}

final class StoryUpdateGroupEvent extends StoryEvent {
  final int currentStoryGroupId;

  const StoryUpdateGroupEvent(this.currentStoryGroupId);

  @override
  List<Object> get props => [currentStoryGroupId];
}
