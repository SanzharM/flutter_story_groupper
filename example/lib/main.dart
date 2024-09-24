import 'dart:developer';

import 'package:example/data/mock_data.dart';
import 'package:example/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:story_groupper/story_groupper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StoryGroupperExampleApp());
}

class StoryGroupperExampleApp extends StatelessWidget {
  const StoryGroupperExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<StoryGroupperViewState> _groupperKey =
      GlobalKey<StoryGroupperViewState>();

  bool isLoading = false;
  void _toggleLoading({bool? value}) =>
      setState(() => isLoading = value ?? !isLoading);

  List<YourCustomStoryGroupDto> _groups = [];
  List<YourCustomStoryItemDto> _items = [];

  final List<int> _viewedGroupIds = [];

  bool _isGroupViewed(int? id) => _viewedGroupIds.contains(id);
  List<YourCustomStoryGroupDto> get _sortedGroups {
    return [
      ..._groups.where((e) => !_isGroupViewed(e.id)),
      ..._groups.where((e) => _isGroupViewed(e.id)),
    ];
  }

  void requestData() async {
    if (isLoading) return;
    _toggleLoading();

    try {
      _groups = await fetchStoryGroups();
      _items = await fetchStoryItems();
    } catch (e) {
      //
    }

    _toggleLoading();
  }

  @override
  void initState() {
    requestData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'StoryGroupper Example',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (isLoading) ...[
            const Center(child: CircularProgressIndicator.adaptive()),
          ] else ...[
            _GroupsSlider(
              groups: _sortedGroups,
              onGroupPressed: _onStoryGroupPressed,
              isViewed: _isGroupViewed,
            ),
          ]
        ],
      ),
    );
  }

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
          log('Group ${group.id} changed. You may send analytics etc.');
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
          log('Group ${group.id} finished. You may send analytics etc.');
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

            // Also you can use here package default widgets
            (group, item) {
                // print('asdasd');
                final customItemDto = _items.firstWhere((e) => e.id == item.id);
                if (customItemDto.buttonUrl?.isEmpty ?? true) {
                  return const SizedBox();
                }
                return SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.maxFinite,
                      child: CupertinoButton(
                        pressedOpacity: 0.75,
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        color: Theme.of(context).primaryColor,
                        child: SizedBox(
                          child: Text(
                            'More details',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.titleMedium?.apply(
                                      color: Colors.white,
                                    ),
                          ),
                        ),
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
}

class _GroupsSlider extends StatelessWidget {
  const _GroupsSlider({
    required this.groups,
    required this.onGroupPressed,
    required this.isViewed,
  });

  final List<YourCustomStoryGroupDto> groups;
  final bool Function(int? id) isViewed;
  final void Function(YourCustomStoryGroupDto group) onGroupPressed;

  static const double _size = 98.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      height: _size + 24.0,
      width: double.maxFinite,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        scrollDirection: Axis.horizontal,
        itemCount: groups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12.0),
        itemBuilder: (_, i) {
          final String heroTag = 'story_group_'
              '${groups[i].id ?? DateTime.now().microsecondsSinceEpoch}';
          final Color borderColor = isViewed(groups[i].id)
              ? const Color(0xFFD2C5C5)
              : theme.primaryColor;
          return GestureDetector(
            onTap: () => onGroupPressed(groups[i]),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RepaintBoundary(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: double.maxFinite,
                      width: _size,
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16.0)),
                        border: Border.all(width: 2.0, color: borderColor),
                      ),
                      child: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0)),
                        child: Hero(
                          tag: heroTag,
                          child: Image.network(
                            groups[i].thumbnail ?? '',
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_not_supported_rounded,
                                size: 24.0,
                                color: theme.hintColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  groups[i].title ?? '',
                  textAlign: TextAlign.left,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
