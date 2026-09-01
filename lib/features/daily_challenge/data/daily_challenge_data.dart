import 'dart:math';

import '../models/daily_challenge_item.dart';

abstract final class DailyChallengeData {
  static const List<DailyChallengeItem> all = <DailyChallengeItem>[
    // Rules — 6
    DailyChallengeItem(
      id: 'daily_rule_01',
      type: DailyChallengeItemType.rule,
      bengali: 'I ___ ready.',
      english: 'I am ready.',
      options: <String>['am', 'is', 'are'],
      correctAnswer: 'am',
      explanation: 'I-এর পরে am বসে।',
    ),
    DailyChallengeItem(
      id: 'daily_rule_02',
      type: DailyChallengeItemType.rule,
      bengali: 'He ___ my brother.',
      english: 'He is my brother.',
      options: <String>['am', 'is', 'are'],
      correctAnswer: 'is',
      explanation: 'He-এর পরে is বসে।',
    ),
    DailyChallengeItem(
      id: 'daily_rule_03',
      type: DailyChallengeItemType.rule,
      bengali: 'They ___ at home.',
      english: 'They are at home.',
      options: <String>['am', 'is', 'are'],
      correctAnswer: 'are',
      explanation: 'They-এর পরে are বসে।',
    ),
    DailyChallengeItem(
      id: 'daily_rule_04',
      type: DailyChallengeItemType.rule,
      bengali: 'She ___ English.',
      english: 'She studies English.',
      options: <String>['study', 'studies', 'studying'],
      correctAnswer: 'studies',
      explanation: 'She-এর সঙ্গে verb-এর শেষে s বা es হয়।',
    ),
    DailyChallengeItem(
      id: 'daily_rule_05',
      type: DailyChallengeItemType.rule,
      bengali: 'We ___ football.',
      english: 'We play football.',
      options: <String>['play', 'plays', 'playing'],
      correctAnswer: 'play',
      explanation: 'We-এর সঙ্গে verb-এর base form হয়।',
    ),
    DailyChallengeItem(
      id: 'daily_rule_06',
      type: DailyChallengeItemType.rule,
      bengali: 'Did you ___ the door?',
      english: 'Did you open the door?',
      options: <String>['open', 'opened', 'opening'],
      correctAnswer: 'open',
      explanation: 'Did-এর পরে verb-এর base form হয়।',
    ),

    // Basic Sentences — 9
    DailyChallengeItem(
      id: 'daily_basic_01',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'আমি ভোরে উঠি।',
      english: 'I wake up early.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_02',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'আমি পানি পান করি।',
      english: 'I drink water.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_03',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'সে রান্না করছে।',
      english: 'She is cooking.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_04',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'আমরা স্কুলে যাচ্ছি।',
      english: 'We are going to school.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_05',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'সে এখানে কাজ করে।',
      english: 'He works here.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_06',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'আমি ইংরেজি বলি।',
      english: 'I speak English.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_07',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'তারা ফুটবল খেলেছিল।',
      english: 'They played football.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_08',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'আমি তোমাকে ফোন করব।',
      english: 'I will call you.',
    ),
    DailyChallengeItem(
      id: 'daily_basic_09',
      type: DailyChallengeItemType.basicSentence,
      bengali: 'দরজাটি খোলো।',
      english: 'Open the door.',
    ),

    // Question Making — 9
    DailyChallengeItem(
      id: 'daily_question_01',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কোথায় থাকো?',
      english: 'Where do you live?',
    ),
    DailyChallengeItem(
      id: 'daily_question_02',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কী চাও?',
      english: 'What do you want?',
    ),
    DailyChallengeItem(
      id: 'daily_question_03',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কখন আসবে?',
      english: 'When will you come?',
    ),
    DailyChallengeItem(
      id: 'daily_question_04',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কেন দেরি করেছো?',
      english: 'Why are you late?',
    ),
    DailyChallengeItem(
      id: 'daily_question_05',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তোমার শিক্ষক কে?',
      english: 'Who is your teacher?',
    ),
    DailyChallengeItem(
      id: 'daily_question_06',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কীভাবে যাও?',
      english: 'How do you go?',
    ),
    DailyChallengeItem(
      id: 'daily_question_07',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কি আমাকে সাহায্য করতে পারো?',
      english: 'Can you help me?',
    ),
    DailyChallengeItem(
      id: 'daily_question_08',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কি শেষ করেছো?',
      english: 'Did you finish?',
    ),
    DailyChallengeItem(
      id: 'daily_question_09',
      type: DailyChallengeItemType.questionMaking,
      bengali: 'তুমি কি চা খাবে?',
      english: 'Would you like tea?',
    ),

    // Speaking — 6
    DailyChallengeItem(
      id: 'daily_speaking_01',
      type: DailyChallengeItemType.speaking,
      bengali: 'আমার নাম রাজ।',
      english: 'My name is Raj.',
    ),
    DailyChallengeItem(
      id: 'daily_speaking_02',
      type: DailyChallengeItemType.speaking,
      bengali: 'আমি ইংরেজি শিখছি।',
      english: 'I am learning English.',
    ),
    DailyChallengeItem(
      id: 'daily_speaking_03',
      type: DailyChallengeItemType.speaking,
      bengali: 'আমি বাংলাদেশে থাকি।',
      english: 'I live in Bangladesh.',
    ),
    DailyChallengeItem(
      id: 'daily_speaking_04',
      type: DailyChallengeItemType.speaking,
      bengali: 'আমি একজন ডেভেলপার।',
      english: 'I am a developer.',
    ),
    DailyChallengeItem(
      id: 'daily_speaking_05',
      type: DailyChallengeItemType.speaking,
      bengali: 'আমি ইংরেজি অনুশীলন করি।',
      english: 'I practice English.',
    ),
    DailyChallengeItem(
      id: 'daily_speaking_06',
      type: DailyChallengeItemType.speaking,
      bengali: 'আমি আত্মবিশ্বাসের সাথে কথা বলি।',
      english: 'I speak confidently.',
    ),
  ];

  static List<DailyChallengeItem> today() {
    final String date = _dateKey(DateTime.now());
    final Random random = Random(_seed(date));

    final List<DailyChallengeItem> todayItems = <DailyChallengeItem>[
      ..._takeType(DailyChallengeItemType.rule, 2, random),
      ..._takeType(DailyChallengeItemType.basicSentence, 3, random),
      ..._takeType(DailyChallengeItemType.questionMaking, 3, random),
      ..._takeType(DailyChallengeItemType.speaking, 2, random),
    ];

    todayItems.shuffle(random);
    return todayItems;
  }

  static List<DailyChallengeItem> _takeType(
      DailyChallengeItemType type,
      int count,
      Random random,
      ) {
    final List<DailyChallengeItem> items =
    all.where((DailyChallengeItem item) => item.type == type).toList();
    items.shuffle(random);
    return items.take(count).toList(growable: false);
  }

  static String _dateKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static int _seed(String value) {
    int result = 0;
    for (final int codeUnit in value.codeUnits) {
      result = (result * 31 + codeUnit) & 0x7fffffff;
    }
    return result;
  }
}