import 'package:flutter/material.dart';

import '../../models/rule_content.dart';

abstract final class Batch18Rules {
  static const Color _teal = Color(0xFF0E9F6E);

  static final List<RuleContent> rules = <RuleContent>[
    _whoWhose,
    _where,
    _whenWhatTime,
  ];

  static RuleExample _example(
      String bangla,
      String english,
      String visualKey, {
        RuleExampleType type = RuleExampleType.question,
      }) {
    return RuleExample(
      bengali: bangla,
      english: english,
      type: type,
      visualKey: visualKey,
    );
  }

  static RuleTest _test(
      String id,
      String question,
      List<String> options,
      String answer,
      String explanation,
      ) {
    return RuleTest(
      id: id,
      type: RuleTestType.multipleChoice,
      question: question,
      options: options,
      correctAnswer: answer,
      explanation: explanation,
    );
  }

  static SpeakingTest _speaking(
      String id,
      String instruction,
      String answer,
      IconData icon,
      Color color,
      ) {
    return SpeakingTest(
      id: id,
      instruction: instruction,
      expectedAnswer: answer,
      acceptedAnswers: <String>[
        answer,
        answer.replaceAll('.', ''),
      ],
      visualIcon: icon,
      visualColor: color,
    );
  }

  static final RuleContent _whoWhose = RuleContent(
    id: 'who_whose',
    order: 52,
    title: 'Who & Whose',
    shortMeaning: 'কে এবং কার জানতে',
    usage:
    'কোনো ব্যক্তি কে জানতে Who এবং কোনো জিনিস কার জানতে Whose ব্যবহার হয়।',
    formula: 'Who + Verb...? | Whose + Noun + Verb...?',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.person_search_rounded,
    color: _teal,
    keywords: <String>[
      'Who',
      'Whose',
      'Person',
      'Owner',
    ],
    examples: <RuleExample>[
      _example('তুমি কে?', 'Who are you?', 'person'),
      _example('সে কে?', 'Who is he?', 'man'),
      _example('তোমার শিক্ষক কে?', 'Who is your teacher?', 'teacher'),
      _example('তোমাকে কে ফোন করেছিল?', 'Who called you?', 'call'),
      _example('এখানে কে থাকে?', 'Who lives here?', 'live'),
      _example('কে আসছে?', 'Who is coming?', 'coming'),
      _example('তুমি কাকে ভালোবাসো?', 'Who do you love?', 'love'),
      _example('তুমি কার সঙ্গে দেখা করেছিলে?', 'Who did you meet?', 'meet'),
      _example('কে আমাকে সাহায্য করতে পারে?', 'Who can help me?', 'help'),
      _example('এটি কার বই?', 'Whose book is this?', 'book'),
      _example('কার ফোন বাজছে?', 'Whose phone is ringing?', 'phone'),
      _example('টেবিলের উপর কার ব্যাগ আছে?', 'Whose bag is on the table?', 'bag'),
      _example('এটি কার কলম?', 'Whose pen is this?', 'pen'),
      _example('এগুলো কার জুতা?', 'Whose shoes are these?', 'shoes'),
      _example('এটি কার ধারণা ছিল?', 'Whose idea was it?', 'idea'),
    ],
    tests: <RuleTest>[
      _test(
        'who_whose_test_01',
        '___ are you?',
        <String>['Who', 'Whose', 'Where'],
        'Who',
        'কোনো ব্যক্তি কে জানতে Who ব্যবহার হয়।',
      ),
      _test(
        'who_whose_test_02',
        '___ is he?',
        <String>['Who', 'Whose', 'When'],
        'Who',
        'ব্যক্তি সম্পর্কে জানতে Who is ব্যবহার হয়।',
      ),
      _test(
        'who_whose_test_03',
        '___ called you?',
        <String>['Who', 'Whose', 'What'],
        'Who',
        'কে ফোন করেছে জানতে Who called বলা হয়।',
      ),
      _test(
        'who_whose_test_04',
        '___ lives here?',
        <String>['Who', 'Whose', 'Where'],
        'Who',
        'কে এখানে থাকে জানতে Who ব্যবহার হয়।',
      ),
      _test(
        'who_whose_test_05',
        'এটি কার বই?',
        <String>[
          'Whose book is this?',
          'Who book is this?',
          'Whose books are this?',
        ],
        'Whose book is this?',
        'কোনো জিনিস কার জানতে Whose ব্যবহার হয়।',
      ),
      _test(
        'who_whose_test_06',
        'এটি কার কলম?',
        <String>[
          'Whose pen is this?',
          'Who pen is this?',
          'Whose pens are this?',
        ],
        'Whose pen is this?',
        'Whose-এর পরে noun বসে।',
      ),
      _test(
        'who_whose_test_07',
        'তুমি কাকে ভালোবাসো?',
        <String>[
          'Who do you love?',
          'Whose do you love?',
          'Who does you love?',
        ],
        'Who do you love?',
        'You-এর সঙ্গে do ব্যবহার হয়।',
      ),
      _test(
        'who_whose_test_08',
        'তুমি কার সঙ্গে দেখা করেছিলে?',
        <String>[
          'Who did you meet?',
          'Who did you met?',
          'Whose did you meet?',
        ],
        'Who did you meet?',
        'Did-এর পরে meet-এর base form হয়।',
      ),
      _test(
        'who_whose_test_09',
        'এগুলো কার জুতা?',
        <String>[
          'Whose shoes are these?',
          'Who shoes are these?',
          'Whose shoe is these?',
        ],
        'Whose shoes are these?',
        'Shoes plural, তাই are these হবে।',
      ),
      _test(
        'who_whose_test_10',
        'কে আমাকে সাহায্য করতে পারে?',
        <String>[
          'Who can help me?',
          'Who can helps me?',
          'Whose can help me?',
        ],
        'Who can help me?',
        'Can-এর পরে help-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'who_whose_speaking_01',
        'প্রশ্ন করুন: তুমি কে?',
        'Who are you?',
        Icons.person_rounded,
        _teal,
      ),
      _speaking(
        'who_whose_speaking_02',
        'প্রশ্ন করুন: তোমার শিক্ষক কে?',
        'Who is your teacher?',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'who_whose_speaking_03',
        'প্রশ্ন করুন: এটি কার বই?',
        'Whose book is this?',
        Icons.menu_book_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'who_whose_speaking_04',
        'প্রশ্ন করুন: কে আমাকে সাহায্য করতে পারে?',
        'Who can help me?',
        Icons.help_rounded,
        Colors.orange,
      ),
      _speaking(
        'who_whose_speaking_05',
        'প্রশ্ন করুন: এগুলো কার জুতা?',
        'Whose shoes are these?',
        Icons.shopping_bag_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _where = RuleContent(
    id: 'where',
    order: 53,
    title: 'Where',
    shortMeaning: 'কোথায় বা কোথা থেকে জানতে',
    usage: 'কোনো ব্যক্তি বা জিনিসের স্থান জানতে Where ব্যবহার হয়।',
    formula: 'Where + Helping Verb + Subject + Verb?',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.place_rounded,
    color: Colors.blue,
    keywords: <String>[
      'Where',
      'Place',
      'Location',
      'Position',
    ],
    examples: <RuleExample>[
      _example('তুমি কোথায় থাকো?', 'Where do you live?', 'home'),
      _example('সে কোথায় আছে?', 'Where is he?', 'person_place'),
      _example('তুমি কোথায় যাচ্ছো?', 'Where are you going?', 'going'),
      _example('তোমার বাড়ি কোথায়?', 'Where is your home?', 'house'),
      _example('তুমি কোথা থেকে এসেছো?', 'Where are you from?', 'country'),
      _example('সে কোথায় কাজ করে?', 'Where does he work?', 'work'),
      _example('তুমি বইটি কোথায় রেখেছো?', 'Where did you put the book?', 'book'),
      _example('আমরা কোথায় দেখা করব?', 'Where will we meet?', 'meet'),
      _example('বাসস্টপ কোথায়?', 'Where is the bus stop?', 'bus'),
      _example('তুমি কোথায় English শিখো?', 'Where do you learn English?', 'learn'),
      _example('আমার ফোন কোথায়?', 'Where is my phone?', 'phone'),
      _example('তারা কোথায় খেলছে?', 'Where are they playing?', 'playing'),
      _example('তুমি কোথায় যেতে চাও?', 'Where do you want to go?', 'travel'),
      _example('এই দোকানটি কোথায়?', 'Where is this shop?', 'shop'),
      _example('সে কোথায় জন্মগ্রহণ করেছে?', 'Where was she born?', 'birth'),
    ],
    tests: <RuleTest>[
      _test(
        'where_test_01',
        '___ do you live?',
        <String>['Where', 'When', 'Who'],
        'Where',
        'কোনো জায়গা জানতে Where ব্যবহার হয়।',
      ),
      _test(
        'where_test_02',
        '___ is he?',
        <String>['Where', 'What', 'Why'],
        'Where',
        'কেউ কোথায় আছে জানতে Where is বলা হয়।',
      ),
      _test(
        'where_test_03',
        'তুমি কোথায় যাচ্ছো?',
        <String>[
          'Where are you going?',
          'Where is you going?',
          'What are you going?',
        ],
        'Where are you going?',
        'You-এর সঙ্গে are ব্যবহার হয়।',
      ),
      _test(
        'where_test_04',
        'তোমার বাড়ি কোথায়?',
        <String>[
          'Where is your home?',
          'Where are your home?',
          'What is your home?',
        ],
        'Where is your home?',
        'Home singular, তাই is হবে।',
      ),
      _test(
        'where_test_05',
        'তুমি কোথা থেকে এসেছো?',
        <String>[
          'Where are you from?',
          'Where is you from?',
          'What are you from?',
        ],
        'Where are you from?',
        'পরিচয় বা উৎস জানতে Where are you from? হয়।',
      ),
      _test(
        'where_test_06',
        'সে কোথায় কাজ করে?',
        <String>[
          'Where does he work?',
          'Where do he work?',
          'Where does he works?',
        ],
        'Where does he work?',
        'He-এর সঙ্গে does এবং base verb work হয়।',
      ),
      _test(
        'where_test_07',
        'তুমি বইটি কোথায় রেখেছো?',
        <String>[
          'Where did you put the book?',
          'Where did you putted the book?',
          'Where do you put the book yesterday?',
        ],
        'Where did you put the book?',
        'Did-এর পরে put-এর base form হয়।',
      ),
      _test(
        'where_test_08',
        'আমরা কোথায় দেখা করব?',
        <String>[
          'Where will we meet?',
          'Where will we meets?',
          'Where do we will meet?',
        ],
        'Where will we meet?',
        'Will-এর পরে meet-এর base form হয়।',
      ),
      _test(
        'where_test_09',
        'তারা কোথায় খেলছে?',
        <String>[
          'Where are they playing?',
          'Where is they playing?',
          'Where do they playing?',
        ],
        'Where are they playing?',
        'They-এর সঙ্গে are ব্যবহার হয়।',
      ),
      _test(
        'where_test_10',
        'সে কোথায় জন্মগ্রহণ করেছে?',
        <String>[
          'Where was she born?',
          'Where were she born?',
          'Where did she born?',
        ],
        'Where was she born?',
        'She-এর সঙ্গে was ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'where_speaking_01',
        'প্রশ্ন করুন: তুমি কোথায় থাকো?',
        'Where do you live?',
        Icons.home_rounded,
        _teal,
      ),
      _speaking(
        'where_speaking_02',
        'প্রশ্ন করুন: তুমি কোথায় যাচ্ছো?',
        'Where are you going?',
        Icons.directions_walk_rounded,
        Colors.blue,
      ),
      _speaking(
        'where_speaking_03',
        'প্রশ্ন করুন: তুমি কোথা থেকে এসেছো?',
        'Where are you from?',
        Icons.public_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'where_speaking_04',
        'প্রশ্ন করুন: বাসস্টপ কোথায়?',
        'Where is the bus stop?',
        Icons.directions_bus_rounded,
        Colors.orange,
      ),
      _speaking(
        'where_speaking_05',
        'প্রশ্ন করুন: আমরা কোথায় দেখা করব?',
        'Where will we meet?',
        Icons.meeting_room_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _whenWhatTime = RuleContent(
    id: 'when_what_time',
    order: 54,
    title: 'When & What time',
    shortMeaning: 'কখন এবং কয়টা বাজে জানতে',
    usage:
    'কোনো ঘটনা কখন ঘটে জানতে When এবং নির্দিষ্ট সময় জানতে What time ব্যবহার হয়।',
    formula: 'When + Question? | What time + Be/Auxiliary + Subject?',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.access_time_rounded,
    color: Colors.deepPurple,
    keywords: <String>[
      'When',
      'What time',
      'Time',
      'Date',
    ],
    examples: <RuleExample>[
      _example('তুমি কখন আসবে?', 'When will you come?', 'come'),
      _example('ক্লাস কখন শুরু হবে?', 'When will the class start?', 'class'),
      _example('তুমি কখন ঘুম থেকে ওঠো?', 'When do you wake up?', 'wake'),
      _example('সে কখন চলে গেছে?', 'When did he leave?', 'leave'),
      _example('তোমার জন্মদিন কবে?', 'When is your birthday?', 'birthday'),
      _example('তুমি কখন English শিখবে?', 'When will you learn English?', 'learn'),
      _example('তুমি কখন কাজ শেষ করবে?', 'When will you finish the work?', 'finish'),
      _example('তারা কখন পৌঁছাবে?', 'When will they arrive?', 'arrive'),
      _example('এখন কয়টা বাজে?', 'What time is it now?', 'clock'),
      _example('তুমি কয়টায় ঘুম থেকে ওঠো?', 'What time do you wake up?', 'morning'),
      _example('ট্রেন কয়টায় ছাড়বে?', 'What time will the train leave?', 'train'),
      _example('দোকান কয়টায় খোলে?', 'What time does the shop open?', 'shop'),
      _example('মিটিং কখন?', 'When is the meeting?', 'meeting'),
      _example('তুমি কখন দুপুরের খাবার খাও?', 'When do you eat lunch?', 'lunch'),
      _example('পরীক্ষা কখন শুরু হবে?', 'When will the exam start?', 'exam'),
    ],
    tests: <RuleTest>[
      _test(
        'when_what_time_test_01',
        '___ will you come?',
        <String>['When', 'Where', 'Who'],
        'When',
        'কখন জানতে When ব্যবহার হয়।',
      ),
      _test(
        'when_what_time_test_02',
        '___ will the class start?',
        <String>['When', 'What', 'Why'],
        'When',
        'কোনো ঘটনা কখন হবে জানতে When ব্যবহার হয়।',
      ),
      _test(
        'when_what_time_test_03',
        'তুমি কখন ঘুম থেকে ওঠো?',
        <String>[
          'When do you wake up?',
          'When does you wake up?',
          'What do you wake up?',
        ],
        'When do you wake up?',
        'You-এর সঙ্গে do ব্যবহার হয়।',
      ),
      _test(
        'when_what_time_test_04',
        'সে কখন চলে গেছে?',
        <String>[
          'When did he leave?',
          'When did he left?',
          'When does he leave yesterday?',
        ],
        'When did he leave?',
        'Did-এর পরে leave-এর base form হয়।',
      ),
      _test(
        'when_what_time_test_05',
        'তোমার জন্মদিন কবে?',
        <String>[
          'When is your birthday?',
          'When are your birthday?',
          'What is your birthday?',
        ],
        'When is your birthday?',
        'Birthday singular, তাই is হবে।',
      ),
      _test(
        'when_what_time_test_06',
        'এখন কয়টা বাজে?',
        <String>[
          'What time is it now?',
          'When time is it now?',
          'What time are it now?',
        ],
        'What time is it now?',
        'নির্দিষ্ট সময় জানতে What time ব্যবহার হয়।',
      ),
      _test(
        'when_what_time_test_07',
        'তুমি কয়টায় ঘুম থেকে ওঠো?',
        <String>[
          'What time do you wake up?',
          'What time does you wake up?',
          'When time do you wake up?',
        ],
        'What time do you wake up?',
        'You-এর সঙ্গে do ব্যবহার হয়।',
      ),
      _test(
        'when_what_time_test_08',
        'ট্রেন কয়টায় ছাড়বে?',
        <String>[
          'What time will the train leave?',
          'What time will the train leaves?',
          'When time will the train leave?',
        ],
        'What time will the train leave?',
        'Will-এর পরে leave-এর base form হয়।',
      ),
      _test(
        'when_what_time_test_09',
        'দোকান কয়টায় খোলে?',
        <String>[
          'What time does the shop open?',
          'What time do the shop open?',
          'What time does the shop opens?',
        ],
        'What time does the shop open?',
        'Shop singular, তাই does হবে।',
      ),
      _test(
        'when_what_time_test_10',
        'পরীক্ষা কখন শুরু হবে?',
        <String>[
          'When will the exam start?',
          'When will the exam starts?',
          'What will the exam start?',
        ],
        'When will the exam start?',
        'Will-এর পরে start-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'when_what_time_speaking_01',
        'প্রশ্ন করুন: তুমি কখন আসবে?',
        'When will you come?',
        Icons.event_rounded,
        _teal,
      ),
      _speaking(
        'when_what_time_speaking_02',
        'প্রশ্ন করুন: তোমার জন্মদিন কবে?',
        'When is your birthday?',
        Icons.cake_rounded,
        Colors.blue,
      ),
      _speaking(
        'when_what_time_speaking_03',
        'প্রশ্ন করুন: এখন কয়টা বাজে?',
        'What time is it now?',
        Icons.access_time_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'when_what_time_speaking_04',
        'প্রশ্ন করুন: ট্রেন কয়টায় ছাড়বে?',
        'What time will the train leave?',
        Icons.train_rounded,
        Colors.orange,
      ),
      _speaking(
        'when_what_time_speaking_05',
        'প্রশ্ন করুন: পরীক্ষা কখন শুরু হবে?',
        'When will the exam start?',
        Icons.assignment_rounded,
        Colors.green,
      ),
    ],
  );
}