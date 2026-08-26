import 'package:flutter/material.dart';

import '../../models/rule_content.dart';

abstract final class Batch19Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _whyBecause,
    _how,
    _howManyMuch,
  ];

  static const Color _teal = Color(0xFF0E9F6E);

  static RuleExample _example(
      String bangla,
      String english,
      String visualKey,
      ) {
    return RuleExample(
      bengali: bangla,
      english: english,
      type: RuleExampleType.simple,
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

  static final RuleContent _whyBecause = RuleContent(
    id: 'why_because',
    order: 55,
    title: 'Why & Because',
    shortMeaning: 'কারণ জানতে ও কারণ বলতে',
    usage: 'কারণ জানতে Why এবং কারণ জানাতে Because ব্যবহার হয়।',
    formula: 'Why + Question? | Because + Reason',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.help_outline_rounded,
    color: _teal,
    keywords: <String>[
      'Why',
      'Because',
      'Reason',
      'Question',
    ],
    examples: <RuleExample>[
      _example('তুমি কেন দেরি করেছো?', 'Why are you late?', 'late'),
      _example('তুমি কেন কাঁদছো?', 'Why are you crying?', 'crying'),
      _example(
        'সে কেন স্কুলে যায়নি?',
        'Why did he not go to school?',
        'school',
      ),
      _example(
        'তুমি কেন English শিখছো?',
        'Why are you learning English?',
        'learning',
      ),
      _example(
        'তারা কেন এখানে এসেছে?',
        'Why did they come here?',
        'come',
      ),
      _example('তুমি কেন ব্যস্ত?', 'Why are you busy?', 'busy'),
      _example(
        'আমি দেরি করেছি কারণ বৃষ্টি হচ্ছিল।',
        'I was late because it was raining.',
        'rain',
      ),
      _example(
        'আমি English শিখি কারণ এটি দরকারি।',
        'I learn English because it is useful.',
        'useful',
      ),
      _example(
        'সে বাড়িতে আছে কারণ সে অসুস্থ।',
        'He is at home because he is sick.',
        'sick',
      ),
      _example(
        'তারা আসেনি কারণ তারা ব্যস্ত ছিল।',
        'They did not come because they were busy.',
        'not_come',
      ),
      _example(
        'সে হাসছে কারণ সে খুশি।',
        'She is smiling because she is happy.',
        'happy',
      ),
      _example(
        'আমি পানি পান করি কারণ আমি তৃষ্ণার্ত।',
        'I drink water because I am thirsty.',
        'thirsty',
      ),
      _example(
        'তুমি কেন এটি চাও?',
        'Why do you want this?',
        'want',
      ),
      _example(
        'সে কেন চলে গেল?',
        'Why did she leave?',
        'leave',
      ),
      _example(
        'আমরা এখানে আছি কারণ আমরা অপেক্ষা করছি।',
        'We are here because we are waiting.',
        'waiting',
      ),
    ],
    tests: <RuleTest>[
      _test(
        'why_because_test_01',
        '___ are you late?',
        <String>['Why', 'What', 'Where'],
        'Why',
        'কারণ জানতে Why ব্যবহার হয়।',
      ),
      _test(
        'why_because_test_02',
        '___ are you crying?',
        <String>['Why', 'When', 'Who'],
        'Why',
        'কাঁদার কারণ জানতে Why হবে।',
      ),
      _test(
        'why_because_test_03',
        'I was late ___ it was raining.',
        <String>['because', 'why', 'where'],
        'because',
        'কারণ বলার সময় because ব্যবহার হয়।',
      ),
      _test(
        'why_because_test_04',
        'I learn English ___ it is useful.',
        <String>['because', 'why', 'when'],
        'because',
        'কারণ প্রকাশ করতে because বসে।',
      ),
      _test(
        'why_because_test_05',
        'তুমি কেন ব্যস্ত?',
        <String>[
          'Why are you busy?',
          'What are you busy?',
          'Where are you busy?',
        ],
        'Why are you busy?',
        'কারণ জানতে Why are ব্যবহার হয়।',
      ),
      _test(
        'why_because_test_06',
        'সে কেন স্কুলে যায়নি?',
        <String>[
          'Why did he not go to school?',
          'Why does he not went to school?',
          'What did he not go to school?',
        ],
        'Why did he not go to school?',
        'Did-এর পরে go-এর base form হয়।',
      ),
      _test(
        'why_because_test_07',
        'সে বাড়িতে আছে কারণ সে অসুস্থ।',
        <String>[
          'He is at home because he is sick.',
          'He is at home why he is sick.',
          'He are at home because he sick.',
        ],
        'He is at home because he is sick.',
        'কারণ যুক্ত করতে because ব্যবহার হয়।',
      ),
      _test(
        'why_because_test_08',
        'সে কেন চলে গেল?',
        <String>[
          'Why did she leave?',
          'Why did she left?',
          'Why does she leave yesterday?',
        ],
        'Why did she leave?',
        'Did-এর পরে leave-এর base form হবে।',
      ),
      _test(
        'why_because_test_09',
        'তুমি কেন এটি চাও?',
        <String>[
          'Why do you want this?',
          'Why does you want this?',
          'What do you want this?',
        ],
        'Why do you want this?',
        'You-এর সঙ্গে do ব্যবহার হয়।',
      ),
      _test(
        'why_because_test_10',
        'তারা আসেনি কারণ তারা ব্যস্ত ছিল।',
        <String>[
          'They did not come because they were busy.',
          'They did not came because they was busy.',
          'They does not come because they were busy.',
        ],
        'They did not come because they were busy.',
        'Did not-এর পরে come এবং They-এর সঙ্গে were হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'why_because_speaking_01',
        'প্রশ্ন করুন: তুমি কেন দেরি করেছো?',
        'Why are you late?',
        Icons.schedule_rounded,
        _teal,
      ),
      _speaking(
        'why_because_speaking_02',
        'প্রশ্ন করুন: তুমি কেন English শিখছো?',
        'Why are you learning English?',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'why_because_speaking_03',
        'বলুন: আমি দেরি করেছি কারণ বৃষ্টি হচ্ছিল।',
        'I was late because it was raining.',
        Icons.umbrella_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'why_because_speaking_04',
        'বলুন: সে বাড়িতে আছে কারণ সে অসুস্থ।',
        'He is at home because he is sick.',
        Icons.home_rounded,
        Colors.orange,
      ),
      _speaking(
        'why_because_speaking_05',
        'প্রশ্ন করুন: সে কেন চলে গেল?',
        'Why did she leave?',
        Icons.exit_to_app_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _how = RuleContent(
    id: 'how',
    order: 56,
    title: 'How',
    shortMeaning: 'কীভাবে বা কেমন জানতে',
    usage: 'কোনো কাজ কীভাবে হয় বা কেউ কেমন আছে জানতে How ব্যবহার হয়।',
    formula: 'How + Helping Verb + Subject + Verb?',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.route_rounded,
    color: _teal,
    keywords: <String>[
      'How',
      'Method',
      'Condition',
      'Manner',
    ],
    examples: <RuleExample>[
      _example('তুমি কেমন আছো?', 'How are you?', 'feeling'),
      _example(
        'তুমি কীভাবে English শেখো?',
        'How do you learn English?',
        'learn',
      ),
      _example(
        'সে কীভাবে কাজটি করেছে?',
        'How did he do the work?',
        'work',
      ),
      _example(
        'আমি কীভাবে সেখানে যেতে পারি?',
        'How can I go there?',
        'go',
      ),
      _example('তুমি কীভাবে রান্না করো?', 'How do you cook?', 'cook'),
      _example(
        'সে কেমন অনুভব করছে?',
        'How is she feeling?',
        'feeling_girl',
      ),
      _example(
        'তোমার দিন কেমন গেল?',
        'How was your day?',
        'day',
      ),
      _example(
        'এই machine কীভাবে কাজ করে?',
        'How does this machine work?',
        'machine',
      ),
      _example(
        'তুমি কীভাবে এটি বানিয়েছো?',
        'How did you make this?',
        'make',
      ),
      _example(
        'আমরা কীভাবে শুরু করতে পারি?',
        'How can we start?',
        'start',
      ),
      _example(
        'তুমি কীভাবে এত দ্রুত দৌড়াও?',
        'How do you run so fast?',
        'run',
      ),
      _example(
        'সে কীভাবে এটি জানে?',
        'How does he know this?',
        'know',
      ),
      _example(
        'তুমি কেমন অনুভব করছো?',
        'How are you feeling?',
        'feeling',
      ),
      _example(
        'আমি কীভাবে সাহায্য করতে পারি?',
        'How can I help?',
        'help',
      ),
      _example(
        'তারা কীভাবে এখানে এসেছে?',
        'How did they come here?',
        'arrive',
      ),
    ],
    tests: <RuleTest>[
      _test(
        'how_test_01',
        '___ are you?',
        <String>['How', 'What', 'Why'],
        'How',
        'কেমন আছো জানতে How are you? হয়।',
      ),
      _test(
        'how_test_02',
        '___ do you learn English?',
        <String>['How', 'Where', 'When'],
        'How',
        'কীভাবে জানতে How ব্যবহার হয়।',
      ),
      _test(
        'how_test_03',
        '___ did he do the work?',
        <String>['How', 'Why', 'Who'],
        'How',
        'কাজের পদ্ধতি জানতে How did হয়।',
      ),
      _test(
        'how_test_04',
        '___ can I go there?',
        <String>['How', 'Where', 'When'],
        'How',
        'কীভাবে যেতে হয় জানতে How can হয়।',
      ),
      _test(
        'how_test_05',
        'এই machine কীভাবে কাজ করে?',
        <String>[
          'How does this machine work?',
          'How do this machine works?',
          'What does this machine work?',
        ],
        'How does this machine work?',
        'Machine singular, তাই does ব্যবহার হয়।',
      ),
      _test(
        'how_test_06',
        'তোমার দিন কেমন গেল?',
        <String>[
          'How was your day?',
          'How were your day?',
          'What was your day?',
        ],
        'How was your day?',
        'Day singular, তাই was হবে।',
      ),
      _test(
        'how_test_07',
        'আমি কীভাবে সাহায্য করতে পারি?',
        <String>[
          'How can I help?',
          'How can I helps?',
          'How do I can help?',
        ],
        'How can I help?',
        'Can-এর পরে base verb help হয়।',
      ),
      _test(
        'how_test_08',
        'তুমি কীভাবে এটি বানিয়েছো?',
        <String>[
          'How did you make this?',
          'How did you made this?',
          'How do you made this?',
        ],
        'How did you make this?',
        'Did-এর পরে make-এর base form হয়।',
      ),
      _test(
        'how_test_09',
        'সে কেমন অনুভব করছে?',
        <String>[
          'How is she feeling?',
          'How are she feeling?',
          'What is she feeling?',
        ],
        'How is she feeling?',
        'She-এর সঙ্গে is ব্যবহার হয়।',
      ),
      _test(
        'how_test_10',
        'তারা কীভাবে এখানে এসেছে?',
        <String>[
          'How did they come here?',
          'How did they came here?',
          'How do they came here?',
        ],
        'How did they come here?',
        'Did-এর পরে come-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'how_speaking_01',
        'প্রশ্ন করুন: তুমি কেমন আছো?',
        'How are you?',
        Icons.sentiment_satisfied_rounded,
        _teal,
      ),
      _speaking(
        'how_speaking_02',
        'প্রশ্ন করুন: তুমি কীভাবে English শেখো?',
        'How do you learn English?',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'how_speaking_03',
        'প্রশ্ন করুন: আমি কীভাবে সেখানে যেতে পারি?',
        'How can I go there?',
        Icons.directions_walk_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'how_speaking_04',
        'প্রশ্ন করুন: তোমার দিন কেমন গেল?',
        'How was your day?',
        Icons.today_rounded,
        Colors.orange,
      ),
      _speaking(
        'how_speaking_05',
        'প্রশ্ন করুন: আমি কীভাবে সাহায্য করতে পারি?',
        'How can I help?',
        Icons.help_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _howManyMuch = RuleContent(
    id: 'how_many_much',
    order: 57,
    title: 'How many & How much',
    shortMeaning: 'সংখ্যা ও পরিমাণ জানতে',
    usage:
    'Countable noun-এর সংখ্যা জানতে How many এবং uncountable noun-এর পরিমাণ জানতে How much ব্যবহার হয়।',
    formula: 'How many + Plural Noun? | How much + Uncountable Noun?',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.calculate_rounded,
    color: _teal,
    keywords: <String>[
      'How many',
      'How much',
      'Countable',
      'Uncountable',
      'Quantity',
    ],
    examples: <RuleExample>[
      _example(
        'তোমার কয়টি বই আছে?',
        'How many books do you have?',
        'books',
      ),
      _example(
        'তোমার কয়জন বন্ধু আছে?',
        'How many friends do you have?',
        'friends',
      ),
      _example(
        'ক্লাসে কয়জন ছাত্র আছে?',
        'How many students are in the class?',
        'students',
      ),
      _example(
        'তুমি কয়টি আপেল কিনেছো?',
        'How many apples did you buy?',
        'apples',
      ),
      _example(
        'তোমার কয়টি কলম আছে?',
        'How many pens do you have?',
        'pens',
      ),
      _example(
        'এখানে কয়টি চেয়ার আছে?',
        'How many chairs are here?',
        'chairs',
      ),
      _example(
        'তোমার কত পানি দরকার?',
        'How much water do you need?',
        'water',
      ),
      _example(
        'এই বইটির দাম কত?',
        'How much is this book?',
        'price',
      ),
      _example(
        'তুমি কত টাকা চাও?',
        'How much money do you want?',
        'money',
      ),
      _example(
        'কত দুধ আছে?',
        'How much milk is there?',
        'milk',
      ),
      _example(
        'তুমি কত সময় চাও?',
        'How much time do you need?',
        'time',
      ),
      _example(
        'এই ফোনটির দাম কত?',
        'How much does this phone cost?',
        'phone_price',
      ),
      _example(
        'তোমার কয়টি জুতা আছে?',
        'How many shoes do you have?',
        'shoes',
      ),
      _example(
        'তারা কয়টি গাড়ি কিনেছে?',
        'How many cars did they buy?',
        'cars',
      ),
      _example(
        'তুমি কত চিনি চাও?',
        'How much sugar do you want?',
        'sugar',
      ),
    ],
    tests: <RuleTest>[
      _test(
        'how_many_much_test_01',
        'How ___ books do you have?',
        <String>['many', 'much', 'more'],
        'many',
        'Books countable plural, তাই how many হবে।',
      ),
      _test(
        'how_many_much_test_02',
        'How ___ water do you need?',
        <String>['many', 'much', 'more'],
        'much',
        'Water uncountable, তাই how much হবে।',
      ),
      _test(
        'how_many_much_test_03',
        'How ___ friends do you have?',
        <String>['many', 'much', 'more'],
        'many',
        'Friends গণনা করা যায়, তাই many হবে।',
      ),
      _test(
        'how_many_much_test_04',
        'How ___ money do you want?',
        <String>['many', 'much', 'more'],
        'much',
        'Money uncountable, তাই much হবে।',
      ),
      _test(
        'how_many_much_test_05',
        'তোমার কয়টি কলম আছে?',
        <String>[
          'How many pens do you have?',
          'How much pens do you have?',
          'How many pen do you has?',
        ],
        'How many pens do you have?',
        'Pens plural countable noun।',
      ),
      _test(
        'how_many_much_test_06',
        'তোমার কত পানি দরকার?',
        <String>[
          'How much water do you need?',
          'How many water do you need?',
          'How much waters do you need?',
        ],
        'How much water do you need?',
        'Water uncountable noun।',
      ),
      _test(
        'how_many_much_test_07',
        'এই বইটির দাম কত?',
        <String>[
          'How much is this book?',
          'How many is this book?',
          'How much are this book?',
        ],
        'How much is this book?',
        'Price জানতে How much is ব্যবহার হয়।',
      ),
      _test(
        'how_many_much_test_08',
        'ক্লাসে কয়জন ছাত্র আছে?',
        <String>[
          'How many students are in the class?',
          'How much students are in the class?',
          'How many student is in the class?',
        ],
        'How many students are in the class?',
        'Students plural, তাই are হবে।',
      ),
      _test(
        'how_many_much_test_09',
        'তারা কয়টি গাড়ি কিনেছে?',
        <String>[
          'How many cars did they buy?',
          'How much cars did they buy?',
          'How many cars did they bought?',
        ],
        'How many cars did they buy?',
        'Did-এর পরে buy-এর base form হয়।',
      ),
      _test(
        'how_many_much_test_10',
        'তুমি কত চিনি চাও?',
        <String>[
          'How much sugar do you want?',
          'How many sugar do you want?',
          'How much sugars do you want?',
        ],
        'How much sugar do you want?',
        'Sugar uncountable noun, তাই much হবে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'how_many_much_speaking_01',
        'প্রশ্ন করুন: তোমার কয়টি বই আছে?',
        'How many books do you have?',
        Icons.menu_book_rounded,
        _teal,
      ),
      _speaking(
        'how_many_much_speaking_02',
        'প্রশ্ন করুন: তোমার কত পানি দরকার?',
        'How much water do you need?',
        Icons.water_drop_rounded,
        Colors.blue,
      ),
      _speaking(
        'how_many_much_speaking_03',
        'প্রশ্ন করুন: এই বইটির দাম কত?',
        'How much is this book?',
        Icons.attach_money_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'how_many_much_speaking_04',
        'প্রশ্ন করুন: তোমার কয়জন বন্ধু আছে?',
        'How many friends do you have?',
        Icons.groups_rounded,
        Colors.orange,
      ),
      _speaking(
        'how_many_much_speaking_05',
        'প্রশ্ন করুন: তুমি কত সময় চাও?',
        'How much time do you need?',
        Icons.schedule_rounded,
        Colors.green,
      ),
    ],
  );
}