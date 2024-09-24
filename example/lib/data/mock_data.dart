import 'package:example/models/models.dart';

Future<List<YourCustomStoryGroupDto>> fetchStoryGroups() async {
  await Future.delayed(const Duration(milliseconds: 250));
  return _groups.map((e) => YourCustomStoryGroupDto.fromMap(e)).toList();
}

Future<List<YourCustomStoryItemDto>> fetchStoryItems() async {
  await Future.delayed(const Duration(milliseconds: 250));
  return _items.map((e) => YourCustomStoryItemDto.fromMap(e)).toList();
}

// id: 1 - https://www.pexels.com/ru-ru/photo/13159659/
// id: 2 - https://www.pexels.com/ru-ru/photo/19553534/

const _groups = <Map<String, dynamic>>[
  {
    'id': 1,
    'title': 'Lorem',
    'thumbnail':
        'https://images.pexels.com/photos/13159659/pexels-photo-13159659.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
  {
    'id': 2,
    'title': 'Hello World!!!',
    'thumbnail':
        'https://images.pexels.com/photos/19553534/pexels-photo-19553534.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
  },
];

// id: 1 - https://www.pexels.com/ru-ru/photo/28121941/
// id: 2 - https://www.pexels.com/ru-ru/photo/12670543/
// https://images.pexels.com/photos/12670543/pexels-photo-12670543.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2
const _items = [
  {
    'id': 1,
    'group_id': 1,
    'title': 'Some title...',
    'text': null,
    'url':
        'https://images.pexels.com/photos/28121941/pexels-photo-28121941.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'button_url': null,
    'data': '',
  },
  {
    'id': 2,
    'group_id': 2,
    'title': null,
    'text': null,
    'url':
        'https://images.pexels.com/photos/12670543/pexels-photo-12670543.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'button_url': 'https://www.pexels.com/ru-ru/photo/12670543/',
    'data': null,
  },
  {
    'id': 3,
    'group_id': 2,
    'title': 'Awesome places to visit',
    'text':
        'Some list of places I\'d advise u to hike and so on etc ... ... ...',
    'url':
        'https://images.pexels.com/photos/18486379/pexels-photo-18486379.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    'button_url': 'https://www.pexels.com/ru-ru/photo/',
    'data': {'photo': '18486379'},
  },
];
