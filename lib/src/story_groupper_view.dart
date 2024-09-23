import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:story_groupper/src/blocs/story_bloc/story_bloc.dart';
import 'package:story_groupper/src/blocs/timer_bloc/timer_bloc.dart';
import 'package:story_groupper/src/models/story_group_model.dart';
import 'package:story_groupper/src/models/story_item_model.dart';
import 'package:story_groupper/src/settings/story_groupper_settings.dart';
import 'package:story_groupper/src/ticker/ticker.dart';
import 'package:story_groupper/src/widgets/story_groupper_widgets.dart';

class StoryGroupperView extends StatefulWidget {
  const StoryGroupperView({
    super.key,
    this.initialGroupId,
    this.initialItemId,
    required this.storyGroups,
    required this.settings,
    this.storyItemImageBuilder,
    this.storyItemBuilder,
    this.onStoryGroupChanged,
    this.onStoryGroupFinished,
  });

  /// Story Group [id] that will be used to fetch first
  final int? initialGroupId;

  /// Story Item [id] that will be first
  final int? initialItemId;

  /// Predefined list of story groups
  final List<StoryGroupModel> storyGroups;

  /// [StoryGroupperSettings] setting values for package
  final StoryGroupperSettings settings;

  /// [StoryItemModel]'s image builder
  final StoryItemImageBuilder? storyItemImageBuilder;

  /// Top layer widgets above [StoryItemImageBuilder]
  final StoryItemBuilder? storyItemBuilder;

  /// [VoidCallback] will be triggered when [StoryGroupModel] was changed due to [PageController] swipe or indicator timer finishing
  /// Returns currently active [StoryGroupModel]
  final void Function(StoryGroupModel group)? onStoryGroupChanged;

  /// [VoidCallback] will be triggered when [StoryGroupModel] was finished due to [PageController] swipe or indicator timer finishing
  /// Returns [StoryGroupModel] that was finished
  final void Function(StoryGroupModel group)? onStoryGroupFinished;

  @override
  State<StoryGroupperView> createState() => StoryGroupperViewState();
}

class StoryGroupperViewState extends State<StoryGroupperView> {
  StoryGroupperSettings get _settings => widget.settings;
  late final PageController _pageController;
  late final TimerBloc _timerBloc;
  late final StoryBloc _storyBloc;

  int _itemIndex = 0;

  void pause() => _timerBloc.pause();
  void resume() => _timerBloc.resume();

  void _initialRequest() {
    final int? groupId =
        widget.initialGroupId ?? widget.storyGroups.firstOrNull?.id;
    if (groupId == null) {
      Navigator.of(context).maybePop<void>();
      return;
    }
    return _storyBloc.getItems(groupId);
  }

  @override
  void initState() {
    _timerBloc = TimerBloc(
      Ticker(tickDuration: const Duration(milliseconds: 100)),
      duration: _settings.defaultDuration,
    );
    _storyBloc = StoryBloc(
      _settings.getStoryItems,
      groupId: widget.initialGroupId ?? -1,
      storyGroups: widget.storyGroups,
    );
    _pageController = _settings.pageController ?? PageController();
    _initialRequest();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int currentStoryGroupIndex = widget.storyGroups.indexWhere(
        (storyGroup) => storyGroup.id == widget.initialGroupId,
      );
      if (currentStoryGroupIndex.isNegative) return;
      _pageController.jumpToPage(currentStoryGroupIndex);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimerBloc, TimerState>(
      bloc: _timerBloc,
      listener: (context, state) {
        if (state.isFinished()) {
          _onNextStoryGroup();
        }
      },
      builder: (context, timerState) {
        return BlocBuilder<StoryBloc, StoryState>(
          bloc: _storyBloc,
          builder: (context, state) {
            return Scaffold(
              backgroundColor: _settings.scaffoldBackgroundColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              body: CubePageView.builder(
                controller: _pageController,
                physics: const CubeScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                itemCount: widget.storyGroups.length,
                onPageChanged: (value) {
                  int groupId = widget.storyGroups[value].id!;
                  _storyBloc.getItems(groupId);
                  setState(() => _itemIndex = 0);
                  _timerBloc.pause();
                },
                itemBuilder: (context, index) {
                  return _buildPage(
                    context: context,
                    timerState: timerState,
                    state: state,
                    groupIndex: index,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required TimerState timerState,
    required StoryState state,
    required int groupIndex,
  }) {
    final StoryGroupModel storyGroup = state.storyGroups[groupIndex];

    final List<StoryItemModel> storyItems =
        state.groupItems[storyGroup.id] ?? [];

    final StoryItemModel? item =
        _itemIndex + 1 > storyItems.length ? null : storyItems[_itemIndex];
    if (item == null) {
      return SizedBox.expand(
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    if (_settings.storyPageBuilder != null) {
      return _settings.storyPageBuilder!(storyGroup, item);
    }

    return StoryPageBuilder(
      storyGroup: storyGroup,
      storyItem: item,
      storyItems: storyItems,
      currentStoryItemIndex: _itemIndex,
      onPrevStoryGroup: _onPrevStoryGroup,
      onNextStoryGroup: _onNextStoryGroup,
      timerBloc: _timerBloc,
      settings: _settings,
      storyItemBuilder: widget.storyItemBuilder,
      storyItemImageBuilder: widget.storyItemImageBuilder,
    );
  }

  void _onPrevStoryGroup() {
    final TimerState timerState = _timerBloc.state;
    final StoryState state = _storyBloc.state;

    final bool isFirstStoryItem = _itemIndex == 0;
    if (isFirstStoryItem) {
      final int groupIndex = state.currentStoryGroupIndex;
      final bool isFirstStoryGroup = groupIndex <= 0;

      final bool isInstantAction =
          timerState.durationPassed(_settings.defaultDuration).inMilliseconds <=
              500;

      if (!isInstantAction) {
        return _timerBloc.restart();
      }

      if (isFirstStoryGroup) {
        if (state.currentStoryGroup != null) {
          widget.onStoryGroupFinished?.call(
            state.currentStoryGroup!,
          );
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop<void>();
          return;
        }
        log('UNABLE TO CLOSE FIRST STORY GROUP', level: 1000);
        return;
      }

      final StoryGroupModel prevStoryGroup = state.storyGroups[groupIndex - 1];
      final int? prevStoryGroupId = prevStoryGroup.id;
      if (prevStoryGroupId == null) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop<void>();
          return;
        }
        log('PREV STORY GROUP ID NOT FOUND', level: 1000);
        return;
      }

      _pageController.previousPage(
        duration: _settings.animationDuration,
        curve: Curves.easeInOut,
      );
      setState(() => _itemIndex = 0);
      _storyBloc.onUpdate(prevStoryGroupId);
      _timerBloc.restart();
      widget.onStoryGroupChanged?.call(prevStoryGroup);
      return;
    }

    setState(() => _itemIndex -= 1);
    _timerBloc.restart();
  }

  void _onNextStoryGroup() {
    final StoryState state = _storyBloc.state;
    final List<StoryItemModel> groupItems =
        state.groupItems[state.currentStoryGroupId] ?? [];

    bool isLastStoryItem = _itemIndex + 1 >= groupItems.length;
    if (isLastStoryItem) {
      final int groupIndex = state.currentStoryGroupIndex;
      final bool isLastStoryGroup = groupIndex + 1 >= state.storyGroups.length;

      if (state.currentStoryGroup != null) {
        widget.onStoryGroupFinished?.call(
          state.currentStoryGroup!,
        );
      }
      if (isLastStoryGroup) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop<void>();
          return;
        }
        log('UNABLE TO CLOSE', level: 1000);
        return;
      }
      final StoryGroupModel nextStoryGroup = state.storyGroups[groupIndex + 1];
      final int? nextStoryGroupId = nextStoryGroup.id;
      if (nextStoryGroupId == null) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop<void>();
          return;
        }
        return;
      }

      _storyBloc.onUpdate(nextStoryGroupId);
      _pageController.nextPage(
        duration: _settings.animationDuration,
        curve: Curves.easeInOut,
      );
      setState(() => _itemIndex = 0);
      _timerBloc.restart();
      widget.onStoryGroupChanged?.call(nextStoryGroup);
      return;
    }

    setState(() => _itemIndex += 1);
    _timerBloc.restart();
  }
}
