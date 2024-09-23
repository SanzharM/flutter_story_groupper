import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import 'package:story_groupper/src/models/story_group_model.dart';
import 'package:story_groupper/src/models/story_item_model.dart';

part 'story_event.dart';
part 'story_state.dart';

typedef GetStoryItems = Future<List<StoryItemModel>> Function(int groupId);

class StoryBloc extends Bloc<StoryEvent, StoryState> {
  void getItems(int groupId) => add(StoryGetItemsEvent(groupId));
  void onUpdate(int groupId) => add(StoryUpdateGroupEvent(groupId));

  StoryBloc(
    this._getStoryItems, {
    int groupId = -1,
    required List<StoryGroupModel> storyGroups,
  }) : super(StoryState(
          currentStoryGroupId: groupId,
          storyGroups: storyGroups,
        )) {
    on<StoryUpdateGroupEvent>(_update);
    on<StoryGetItemsEvent>(_getItems);
  }

  final GetStoryItems _getStoryItems;

  void _update(
    StoryUpdateGroupEvent event,
    Emitter<StoryState> emit,
  ) {
    emit(state.copyWith(
      currentStoryGroupId: event.currentStoryGroupId,
    ));
  }

  void _getItems(
    StoryGetItemsEvent event,
    Emitter<StoryState> emit,
  ) async {
    emit(state.copyWith(status: StateStatus.loading));

    try {
      final items = await _getStoryItems.call(event.groupId);
      emit(state.copyWith(
        status: StateStatus.success,
        groupItems: {
          ...state.groupItems,
          ...{event.groupId: items},
        },
        currentStoryGroupId: event.groupId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StateStatus.error,
        message: e.toString(),
      ));
      rethrow;
    }
  }
}
