import 'package:flutter/material.dart';
import 'package:story_groupper/src/blocs/story_bloc/story_bloc.dart';
import 'package:story_groupper/src/models/story_group_model.dart';
import 'package:story_groupper/src/models/story_item_model.dart';

typedef CustomStoryPageBuilder = Widget Function(
  StoryGroupModel group,
  StoryItemModel item,
);

typedef StoryItemImageBuilder = Widget Function(StoryItemModel storyItem);

typedef StoryItemBuilder = Widget Function(
  StoryGroupModel group,
  StoryItemModel item,
);

class StoryGroupperSettings {
  /// Function that returns list of Story Items from [groupId]
  final GetStoryItems getStoryItems;

  /// Rethrows any exception if occured while proceeding [getStoryItems]
  final bool rethrowAtGettingItems;

  final CustomStoryPageBuilder? storyPageBuilder;

  /// Decides either show indicators widget or no
  final bool showIndicators;

  /// Padding values for top indicator widget
  final EdgeInsets indicatorPadding;

  /// Space between Indicators widget and [closeButton]
  final double spaceBetweenIndicatorAndCloseButton;

  /// Decides either show close button widget or no
  final bool showCloseButton;

  /// Customization of close button aligned at the top right
  final Widget? closeButton;

  /// If StoryItem duration is null or not defined
  /// [defaultDuration] value will be used
  final Duration defaultDuration;

  /// [Duration] that is used for animations
  final Duration animationDuration;

  /// [PageController] controls list of [StoryGroupModel]
  final PageController? pageController;

  final Color scaffoldBackgroundColor;

  const StoryGroupperSettings({
    required this.getStoryItems,
    this.rethrowAtGettingItems = true,
    this.indicatorPadding = defaultIndicatorPadding,
    this.closeButton,
    this.spaceBetweenIndicatorAndCloseButton = 12.0,
    this.defaultDuration = const Duration(seconds: 10),
    this.animationDuration = const Duration(milliseconds: 450),
    this.storyPageBuilder,
    this.showCloseButton = true,
    this.showIndicators = true,
    this.pageController,
    this.scaffoldBackgroundColor = Colors.black,
  });

  static const EdgeInsets defaultIndicatorPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );
}
