
Flutter solution for Stories containing multiple sub-stories

## Features

![](example.gif)

## Description

This package simplifies the process of displaying story groups (e.g., thumbnails) and manages the flow for playing stories when a user selects a group. It offers extensive customization options, allowing developers to adjust story duration, use custom widgets, and integrate their own story data. With built-in logic to handle story transitions and essential functionality, developers only need to provide a few required settings to get started.

## Getting Started

```dart
import 'package:story_groupper/story_groupper.dart';
```

1. Start from calling function ```pushDragable```
2. Pass the ```StoryGroupperView``` as a child
3. Provide ```StoryGroupperSettings``` as a parameter
4. Customize your story

## Usage

```dart
 void _onStoryGroupPressed(YourCustomStoryGroupDto group) {
    pushDragable(
      context: context,
      onDragStart: () => _groupperKey.currentState?.pause(),
      onDragEnd: () => _groupperKey.currentState?.resume(),
      child: StoryGroupperView(
        key: _groupperKey,
        storyGroups: _groups
            .map((e) => StoryGroupModel(
                  id: e.id,
                  thumbnail: e.thumbnail,
                ))
            .toList(),
        initialGroupId: group.id,
        onStoryGroupChanged: (group) {
          // Group changed. You may send analytics etc.
          // You may also provide a callback to cache viewed story groups
          final int? groupId = group.id;
          if (groupId != null) {
            setState(() {
              _viewedGroupIds.add(groupId);
              _viewedGroupIds.toSet().toList();
            });
          }
        },
        onStoryGroupFinished: (group) {
          // Group finished. You may send analytics etc.
          // You may also provide a callback to cache viewed story groups
          final int? groupId = group.id;
          if (groupId != null) {
            setState(() {
              _viewedGroupIds.add(groupId);
              _viewedGroupIds.toSet().toList();
            });
          }
        },
        storyItemBuilder: 1 == 2
            ?
            // If you skip this parameter it will take default top layer builder
            null
            :
            // This is custom building story top layer widgets
            (group, item) {
                final customItemDto = _items.firstWhere((e) => e.id == item.id);
                if (customItemDto.buttonUrl?.isEmpty ?? true) {
                  return const SizedBox();
                }
                return SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SomeButton(
                      text: 'More details',
                      onPressed: () {
                        if (_groupperKey.currentState?.isPaused ?? false) {
                          _groupperKey.currentState?.resume();
                        } else {
                          _groupperKey.currentState?.pause();
                        }
                        // launch url or do some action with url
                      },
                    ),
                  ),
                );
              },
        settings: StoryGroupperSettings(
          defaultDuration: const Duration(seconds: 5),
          imageAlignment: Alignment.bottomCenter,
          getStoryItems: (int groupId) async {
            List<YourCustomStoryItemDto> storyItems = await fetchStoryItems();

            return storyItems
                .where((e) => e.groupId == groupId)
                .map((e) => StoryItemModel(
                      id: e.id,
                      imageUrl: e.url,
                    ))
                .toList();
          },
        ),
      ),
    );
  }
```

## Limitations

1. Dependencies: The package relies on external dependencies such as flutter_bloc, equatable, and dart:collection, which may impact flexibility for projects using different state management solutions.
2. Transition Smoothness: There's room for improvement in the smoothness of transitions and animations, which will be addressed in future updates.

## Feedback and Bug Reports
We welcome feedback and encourage users to report any issues they encounter. If you find a bug or have a suggestion for improvement, please open an issue on GitHub. Your contributions help us improve the package and ensure a better experience for all users.