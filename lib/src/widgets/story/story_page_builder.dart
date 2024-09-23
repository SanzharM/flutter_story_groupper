import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_groupper/src/models/story_group_model.dart';
import 'package:story_groupper/src/models/story_item_model.dart';
import 'package:story_groupper/src/settings/story_groupper_settings.dart';
import 'package:story_groupper/src/blocs/timer_bloc/timer_bloc.dart';
import 'package:story_groupper/src/widgets/story/duration_indicator_widget.dart';
import 'package:story_groupper/src/widgets/story/gesture_wrapper.dart';
import 'package:story_groupper/src/widgets/story/story_image_widget.dart';

class StoryPageBuilder extends StatelessWidget {
  const StoryPageBuilder({
    super.key,
    required this.storyGroup,
    required this.storyItem,
    this.storyItems = const <StoryItemModel>[],
    required this.currentStoryItemIndex,
    required this.onPrevStoryGroup,
    required this.onNextStoryGroup,
    required this.settings,
    required this.timerBloc,
    this.storyItemImageBuilder,
    this.storyItemBuilder,
  });

  final StoryGroupModel storyGroup;
  final StoryItemModel storyItem;
  final List<StoryItemModel> storyItems;
  final int currentStoryItemIndex;
  final VoidCallback onPrevStoryGroup;
  final VoidCallback onNextStoryGroup;
  final TimerBloc timerBloc;
  final StoryGroupperSettings settings;
  final StoryItemBuilder? storyItemBuilder;
  final StoryItemImageBuilder? storyItemImageBuilder;

  String get _heroTag =>
      'story_group_${storyGroup.id ?? DateTime.now().microsecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        if (storyItemImageBuilder != null) ...[
          storyItemImageBuilder!(storyItem),
        ] else ...[
          SafeArea(
            bottom: false,
            child: StoryImageWidget(
              key: ObjectKey(storyItem.imageUrl),
              heroTag: _heroTag,
              url: storyItem.imageUrl ?? '',
              fit: BoxFit.fitWidth,
              onLoaded: () {
                timerBloc.restart();
              },
              onError: (Object? object) {
                log('StoryImageWidget ERROR: $object');
              },
            ),
          ),
        ],
        GestureWrapper(
          onPrevious: onPrevStoryGroup,
          onNext: onNextStoryGroup,
          onLongPressStart: timerBloc.pause,
          onLongPressEnd: timerBloc.resume,
          child: null,
        ),
        if (storyItemBuilder != null) ...[
          storyItemBuilder!(storyGroup, storyItem),
        ],
        Padding(
          padding: MediaQuery.of(context).viewPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (settings.showIndicators) ...[
                Padding(
                  padding: settings.indicatorPadding,
                  child: BlocBuilder<TimerBloc, TimerState>(
                    bloc: timerBloc,
                    builder: (context, timerState) {
                      return DurationIndicatorWidget(
                        itemCount: storyItems.length,
                        activeIndex: currentStoryItemIndex,
                        itemValue: timerState
                            .durationPassed(settings.defaultDuration)
                            .inMilliseconds,
                        itemMaxValue: settings.defaultDuration.inMilliseconds,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12.0),
              ],
              if (settings.showCloseButton) ...[
                settings.closeButton ??
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        onPressed: Navigator.of(context).canPop()
                            ? Navigator.of(context).pop<void>
                            : () {},
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
