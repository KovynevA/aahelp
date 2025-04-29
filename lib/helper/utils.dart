import 'dart:convert';
import 'package:aahelp/diary/diaryhtml.dart';
import 'package:aahelp/findgroup/findgroup.dart';
import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/mysobriety/mysobriety.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TabBarPage extends StatelessWidget {
  final Widget tabWidget;

  const TabBarPage({
    super.key,
    required this.tabWidget,
  });

  @override
  Widget build(BuildContext context) {
    String title = '';
    if (tabWidget is FindGroup) {
      title = (tabWidget as FindGroup)
          .title; // Получаем параметр title из виджета FindGroup
    }
    if (tabWidget is Diary) {
      title = (tabWidget as Diary)
          .title; // Получаем параметр title из виджета FindGroup
    }
    if (tabWidget is MySobriety) {
      title = (tabWidget as MySobriety)
          .title; // Получаем параметр title из виджета FindGroup
    }

    return Card(
      color: AppColor.backgroundColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Center(
          child: Text(
            title,
            style: AppTextStyle.valuesstyle,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => tabWidget,
            ),
          );
        },
      ),
    );
  }
}

// Сравнение дат без времени
bool compareDate(DateTime date1, DateTime date2) {
  if (date1.day == date2.day &&
      date1.month == date2.month &&
      date1.year == date2.year) {
    return true;
  } else {
    return false;
  }
}

List<String> daysOfWeek = [
  'Пн',
  'Вт',
  'Ср',
  'Чт',
  'Пт',
  'Сб',
  'Вс',
];

// SnackBar внизу экрана
void infoSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

///////******* Класс поиска и фильтрации по группам ********/////////////

enum TimePeriod { morning, afternoon, evening, none }

enum DayOfWeek { today, notToday }

class GroupSearchService {
// Вычленить время в мапе найденной группы
  String formatTiming(List<Map<String, String>>? timing) {
    if (timing != null && timing.isNotEmpty) {
      String result = '';
      for (var item in timing) {
        result += '${item.keys.first}: ${item[item.keys.first] ?? ''}\n';
      }
      return result;
    }
    return 'Не указано';
  }

  // Вычленить Телефоны в мапе найденной группы
  String formatPhone(List<Phone>? phonelist) {
    if (phonelist != null && phonelist != []) {
      String result = '';
      for (var phone in phonelist) {
        String info = phone.info == null ? '' : ' ${phone.info}';
        result += ' ${phone.number} $info \n';
      }
      return result;
    }
    return 'Не указаны';
  }

  /////////////////////////// ВРЕМЯ////////////////////////////////////////////

  Future<List<GroupsAA>> filterGroupsByTime(
      TimePeriod timePeriod, List<GroupsAA> groups, bool isToday) async {
    Set<GroupsAA> filteredGroups = {};

    for (var group in groups) {
      try {
        if (group.workingTime != null) {
          for (var timegroup in group.workingTime!) {
            // Предполагаем, что timegroup - это Map<String, String>
            String day = timegroup.keys.first; // Получаем день
            String time = timegroup[day]!; // Получаем время

            // Если стоит галка фильтровать "На сегодня"
            if (isToday) {
              if (isDayToday(day)) {
                // Фильтруем по утру/дню/вечеру
                if (timePeriod == TimePeriod.morning && isTimeInMorning(time)) {
                  filteredGroups.add(group);
                } else if (timePeriod == TimePeriod.afternoon &&
                    isTimeInDay(time)) {
                  filteredGroups.add(group);
                } else if (timePeriod == TimePeriod.evening &&
                    isTimeInEvening(time)) {
                  filteredGroups.add(group);
                } else if (timePeriod == TimePeriod.none) {
                  filteredGroups.add(group);
                }
              }
            } else {
              // Если галка фильтровать "На сегодня" не стоит
              if (timePeriod == TimePeriod.morning && isTimeInMorning(time)) {
                filteredGroups.add(group);
              } else if (timePeriod == TimePeriod.afternoon &&
                  isTimeInDay(time)) {
                filteredGroups.add(group);
              } else if (timePeriod == TimePeriod.evening &&
                  isTimeInEvening(time)) {
                filteredGroups.add(group);
              } else if (timePeriod == TimePeriod.none) {
                filteredGroups.add(group);
              }
            }
          }
        }
      } catch (e) {
        print('Ошибка $e в группе ${group.name}');
      }
    }
    return filteredGroups.toList();
  }

// Вспомогательная функция сравнения текущего дня с заданным днем из daysOfweek
  bool isDayToday(String day) {
    int todayindex = DateTime.now().weekday - 1;

    return daysOfWeek[todayindex] == day;
  }

// Вспомогательная функция для проверки времени на принадлежность к утру (06:00 - 12:00)
  bool isTimeInMorning(String time) {
    // Преобразуем строку времени в часы и минуты
    int hours = int.parse(time.split(':')[0]);

    return hours >= 6 && hours < 12;
  }

// Вспомогательная функция для проверки времени на принадлежность к дню (12:00 - 17:00)
  bool isTimeInDay(String time) {
    // Преобразуем строку времени в часы и минуты
    int hours = int.parse(time.split(':')[0]);

    return hours >= 12 && hours < 17;
  }

// Вспомогательная функция для проверки времени на принадлежность к вечеру (17:00 - 24:00)
  bool isTimeInEvening(String time) {
    // Преобразуем строку времени в часы и минуты
    int hours = int.parse(time.split(':')[0]);
    return hours >= 17 ||
        hours <
            6; // Вечернее время начинается после 17:00 и до 24:00, а также с полуночи до 6:00
  }
}

// Функция транслитерации русских букв в латинские
// String transliterate(String input) {
//   Map<String, String> translitMap = {
//     'а': 'a',
//     'б': 'b',
//     'в': 'v',
//     'г': 'g',
//     'д': 'd',
//     'е': 'e',
//     'ё': 'yo',
//     'ж': 'zh',
//     'з': 'z',
//     'и': 'i',
//     'й': 'y',
//     'к': 'k',
//     'л': 'l',
//     'м': 'm',
//     'н': 'n',
//     'о': 'o',
//     'п': 'p',
//     'р': 'r',
//     'с': 's',
//     'т': 't',
//     'у': 'u',
//     'ф': 'f',
//     'х': 'kh',
//     'ц': 'ts',
//     'ч': 'ch',
//     'ш': 'sh',
//     'щ': 'shch',
//     'ъ': '',
//     'ы': 'y',
//     'ь': '',
//     'э': 'e',
//     'ю': 'yu',
//     'я': 'ya'
//   };

//   String result = '';

//   for (int i = 0; i < input.length; i++) {
//     String char = input[i].toLowerCase();
//     if (translitMap.containsKey(char)) {
//       result += translitMap[char]!;
//     } else {
//       result += char;
//     }
//   }

//   return result;
// }

/////////Тест группы с json с сайта!//////////////////////

class GroupsAA {
  String companyId;
  String? name;
  String? shortname;
  String nameOther;
  String? address;
  String? country;
  String? rubricId;
  String? url;
  int? actualizationDate;
  Coordinates? coordinates;
  List<Map<String, String>>? workingTime;
  String? email;
  String? infoPage;
  List<Phone>? phone;
  String? city;
  String? region;
  String? district;
  List<String>? metro;

  GroupsAA({
    required this.companyId,
    this.name,
    this.shortname,
    required this.nameOther,
    this.address,
    this.country,
    this.rubricId,
    this.url,
    this.actualizationDate,
    this.coordinates,
    this.workingTime,
    this.email,
    this.infoPage,
    this.phone,
    this.city,
    this.region,
    this.district,
    this.metro,
  });

  factory GroupsAA.fromJson(Map<String, dynamic> json) {
    // Проверяем наличие обязательных полей
    if (json['company-id'] == null || json['name-other'] == null) {
      throw Exception('Invalid JSON structure: missing required fields');
    }

    List<Phone>? phoneList;
    if (json['phone'] != null) {
      if (json['phone'] is List) {
        phoneList = (json['phone'] as List)
            .map((i) => Phone.fromJson(i as Map<String, dynamic>))
            .toList();
      } else if (json['phone'] is Map) {
        phoneList = [Phone.fromJson(json['phone'] as Map<String, dynamic>)];
      }
    }

    List<Map<String, String>>? timingList;
    if (json['working-time'] != null) {
      if (json['working-time'] is String) {
        timingList = (json['working-time'] as String)
            .split(',')
            .map((entry) {
              final parts = entry.trim().split(' '); // Убираем лишние пробелы
              if (parts.length >= 2) {
                final day = parts[0]; // Берем день
                final timeParts = parts[1].split('-'); // Разбиваем по тире
                final startTime =
                    timeParts[0].trim(); // Оставляем только время начала
                return {
                  day: startTime
                }; // Возвращаем карту с днем и временем начала
              }
              return <String,
                  String>{}; // Возвращаем пустую карту, если формат неправильный
            })
            .where((map) => map.isNotEmpty) // Убираем пустые карты
            .cast<Map<String, String>>() // Приведение типа
            .toList();
      }
    }

    List<String>? metroList;
    if (json['metro'] != null) {
      metroList =
          (json['metro'] as String).split(',').map((s) => s.trim()).toList();
    }

    return GroupsAA(
      companyId: json['company-id'],
      nameOther: json['name-other'],
      name: json['name'],
      shortname: json['shortname'],
      address: json['address'],
      country: json['country'],
      rubricId: json['rubric-id'],
      url: json['url'],
      actualizationDate: json['actualization-date'] != null
          ? int.tryParse(json['actualization-date'].toString())
          : null,
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : null,
      workingTime: timingList,
      email: json['email'],
      infoPage: json['info-page'],
      phone: phoneList,
      city: json['city'],
      region: json['region'],
      district: json['district'],
      metro: metroList,
    );
  }
  // Map<String, dynamic> toJson() {
  //   return {
  //     'company-id': companyId,
  //     'name': name,
  //     'shortname': shortname,
  //     'name-other': nameOther,
  //     'address': address,
  //     'country': country,
  //     'rubric-id': rubricId,
  //     'url': url,
  //     'actualization-date': actualizationDate.toString(),
  //     'coordinates': coordinates?.toJson(),
  //     'working-time': workingTime,
  //     'email': email,
  //     'info-page': infoPage,
  //     'phone': phone?.map((e) => e.toJson()).toList(),
  //     'city': city,
  //     'region': region,
  //     'district': district,
  //     'metro': metroList,
  //   };
  // }

  // Метод для поиска групп по станции метро
  static Future<List<GroupsAA>> findGroupsByMetro(String station) async {
    try {
      List<GroupsAA> groups = await fetchGroupAAList();
      return groups
          .where((group) => group.metro?.contains(station) ?? false)
          .toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<GroupsAA>> fetchGroupAAList() async {
    var client = http.Client();
    final uri = Uri.https('aamos.ru', '/mobile.json');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body)['company'];
      List<GroupsAA> groupAAList = [];

      for (var json in jsonList) {
        try {
          var group = GroupsAA.fromJson(json as Map<String, dynamic>);
          if (group.coordinates != null) {
            // Проверяем, что координаты не null
            groupAAList.add(group);
          }
        } catch (e) {
          print('Error parsing group: $e'); // Логируем ошибку
        }
      }

      return groupAAList;
    } else {
      throw Exception('Failed to load groupAAList');
    }
  }

  static Future<GroupsAA?> findGroupByIndex(int index) async {
    try {
      List<GroupsAA> groupAAList = await fetchGroupAAList();
      if (index >= 0 && index < groupAAList.length) {
        return groupAAList[index];
      } else {
        return null; // Индекс вне диапазона
      }
    } catch (e) {
      print('Error: $e');
      return null; // Ошибка при загрузке списка групп
    }
  }
}

class Coordinates {
  final String lon;
  final String lat;

  Coordinates({required this.lon, required this.lat});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lon: json['lon'],
      lat: json['lat'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lon'] = lon;
    data['lat'] = lat;
    return data;
  }
}

class Phone {
  final String number;
  final String type;
  final String? info;

  Phone({required this.number, required this.type, this.info});

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      number: json['number'],
      type: json['type'],
      info: json['info'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['type'] = type;
    data['info'] = info;
    return data;
  }
}

class SobrietyDuration {
  final int years;
  final int months;
  final int days;
  final int totalDays;
  
  SobrietyDuration({
    this.years = 0,
    this.months = 0,
    this.days = 0,
    this.totalDays = 0,
  });
 
}