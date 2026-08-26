import 'package:flutter/material.dart';

import '../../models/rule_content.dart';

abstract final class Batch17Rules {
  static const Color _teal = Color(0xFF0E9F6E);

  static final List<RuleContent> rules = <RuleContent>[
    _lets,
    _imperativeSentences,
    _what,
  ];

  static RuleExample _example(
      String bangla,
      String english,
      String visualKey, {
        RuleExampleType type = RuleExampleType.simple,
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

  static final RuleContent _lets = RuleContent(
    id: 'lets',
    order: 49,
    title: "Let's",
    shortMeaning: 'চলুন বা একসঙ্গে কিছু করতে',
    usage: "কাউকে সঙ্গে নিয়ে কোনো কাজ করার প্রস্তাব দিতে Let's ব্যবহার হয়।",
    formula: "Let's + Base Verb",
    category: 'Basic',
    level: RuleLevel.beginner,
    icon: Icons.groups_rounded,
    color: _teal,
    keywords: <String>[
      "Let's",
      'Suggestion',
      'Together',
      'Proposal',
    ],
    examples: <RuleExample>[
      _example('চলো বাড়ি যাই।', "Let's go home.", 'home'),
      _example('চলো দুপুরের খাবার খাই।', "Let's eat lunch.", 'lunch'),
      _example('চলো English শিখি।', "Let's learn English.", 'learn'),
      _example('চলো শুরু করি।', "Let's start.", 'start'),
      _example('চলো তাকে সাহায্য করি।', "Let's help him.", 'help'),
      _example('চলো ফুটবল খেলি।', "Let's play football.", 'football'),
      _example('চলো একটি সিনেমা দেখি।', "Let's watch a movie.", 'movie'),
      _example('চলো অপেক্ষা করি।', "Let's wait.", 'wait'),
      _example('চলো আগামীকাল দেখা করি।', "Let's meet tomorrow.", 'meet'),
      _example('চলো একটু বিরতি নিই।', "Let's take a break.", 'break'),
      _example('চলো তর্ক না করি।', "Let's not argue.", 'argue'),
      _example('চলো সময় নষ্ট না করি।', "Let's not waste time.", 'time'),
      _example(
        'চলো কথা বলার অনুশীলন করি।',
        "Let's practice speaking.",
        'speaking',
      ),
      _example('চলো ঘর পরিষ্কার করি।', "Let's clean the room.", 'clean'),
      _example('চলো মাকে ফোন করি।', "Let's call mother.", 'call'),
    ],
    tests: <RuleTest>[
      _test(
        'lets_test_01',
        '___ go home.',
        <String>["Let's", 'Let', 'Lets to'],
        "Let's",
        "একসঙ্গে কাজের প্রস্তাবে Let's ব্যবহার হয়।",
      ),
      _test(
        'lets_test_02',
        '___ learn English.',
        <String>["Let's", 'Let us to', 'Lets'],
        "Let's",
        "Let's-এর পরে verb-এর base form হয়।",
      ),
      _test(
        'lets_test_03',
        "চলো শুরু করি।",
        <String>[
          "Let's start.",
          "Let's to start.",
          'Let start.',
        ],
        "Let's start.",
        "Let's-এর পরে start-এর base form বসে।",
      ),
      _test(
        'lets_test_04',
        "চলো তাকে সাহায্য করি।",
        <String>[
          "Let's help him.",
          "Let's helps him.",
          "Let's helping him.",
        ],
        "Let's help him.",
        "Let's-এর পরে help হবে, helps নয়।",
      ),
      _test(
        'lets_test_05',
        "চলো অপেক্ষা করি।",
        <String>[
          "Let's wait.",
          "Let's waits.",
          "Let waiting.",
        ],
        "Let's wait.",
        "প্রস্তাব দিতে Let's wait বলা হয়।",
      ),
      _test(
        'lets_test_06',
        "চলো তর্ক না করি।",
        <String>[
          "Let's not argue.",
          "Let's don't argue.",
          "Let's not arguing.",
        ],
        "Let's not argue.",
        "নেতিবাচক প্রস্তাবে Let's not + verb হয়।",
      ),
      _test(
        'lets_test_07',
        "চলো ফুটবল খেলি।",
        <String>[
          "Let's play football.",
          "Let's plays football.",
          "Let's playing football.",
        ],
        "Let's play football.",
        "Let's-এর পরে play-এর base form হয়।",
      ),
      _test(
        'lets_test_08',
        "চলো একটু বিরতি নিই।",
        <String>[
          "Let's take a break.",
          "Let's takes a break.",
          "Let's taking a break.",
        ],
        "Let's take a break.",
        "Take হলো base verb।",
      ),
      _test(
        'lets_test_09',
        "চলো আগামীকাল দেখা করি।",
        <String>[
          "Let's meet tomorrow.",
          "Let's meets tomorrow.",
          "Let's meeting tomorrow.",
        ],
        "Let's meet tomorrow.",
        "Let's-এর পরে meet-এর base form বসে।",
      ),
      _test(
        'lets_test_10',
        "চলো ঘর পরিষ্কার করি।",
        <String>[
          "Let's clean the room.",
          "Let's cleans the room.",
          "Let's cleaning the room.",
        ],
        "Let's clean the room.",
        "Let's + base verb ব্যবহার করতে হয়।",
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'lets_speaking_01',
        'বলুন: চলো বাড়ি যাই।',
        "Let's go home.",
        Icons.home_rounded,
        _teal,
      ),
      _speaking(
        'lets_speaking_02',
        'বলুন: চলো English শিখি।',
        "Let's learn English.",
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'lets_speaking_03',
        'বলুন: চলো তাকে সাহায্য করি।',
        "Let's help him.",
        Icons.volunteer_activism_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'lets_speaking_04',
        'বলুন: চলো একটু বিরতি নিই।',
        "Let's take a break.",
        Icons.free_breakfast_rounded,
        Colors.orange,
      ),
      _speaking(
        'lets_speaking_05',
        'বলুন: চলো তর্ক না করি।',
        "Let's not argue.",
        Icons.sentiment_neutral_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _imperativeSentences = RuleContent(
    id: 'imperative_sentences',
    order: 50,
    title: 'Imperative Sentences',
    shortMeaning: 'আদেশ, অনুরোধ ও নির্দেশ',
    usage:
    'কাউকে আদেশ, অনুরোধ, পরামর্শ বা কোনো নির্দেশ দিতে Imperative Sentence ব্যবহার হয়।',
    formula: 'Base Verb + Object',
    category: 'Basic',
    level: RuleLevel.beginner,
    icon: Icons.campaign_rounded,
    color: Colors.orange,
    keywords: <String>[
      'Command',
      'Request',
      'Instruction',
      'Advice',
    ],
    examples: <RuleExample>[
      _example('দরজা খোলো।', 'Open the door.', 'door'),
      _example('বসো।', 'Sit down.', 'sit'),
      _example('দাঁড়াও।', 'Stand up.', 'stand'),
      _example('মনোযোগ দিয়ে শোনো।', 'Listen carefully.', 'listen'),
      _example('আস্তে কথা বলো।', 'Speak slowly.', 'speak'),
      _example('বাক্যটি পড়ো।', 'Read the sentence.', 'read'),
      _example('তোমার নাম লেখো।', 'Write your name.', 'write'),
      _example('এখানে আসো।', 'Come here.', 'come'),
      _example('এক মিনিট অপেক্ষা করো।', 'Wait a minute.', 'wait'),
      _example('সাবধানে থেকো।', 'Be careful.', 'careful'),
      _example('দৌড়াবে না।', "Don't run.", 'run'),
      _example('এটি স্পর্শ করবে না।', "Don't touch it.", 'touch'),
      _example('দয়া করে আমাকে সাহায্য করো।', 'Please help me.', 'help'),
      _example('বামে ঘুরো।', 'Turn left.', 'left'),
      _example('চুপ থাকো।', 'Keep quiet.', 'quiet'),
    ],
    tests: <RuleTest>[
      _test(
        'imperative_test_01',
        '___ the door.',
        <String>['Open', 'Opens', 'Opening'],
        'Open',
        'Imperative sentence-এ base verb ব্যবহার হয়।',
      ),
      _test(
        'imperative_test_02',
        '___ down.',
        <String>['Sit', 'Sits', 'Sitting'],
        'Sit',
        'আদেশে Sit down বলা হয়।',
      ),
      _test(
        'imperative_test_03',
        'মনোযোগ দিয়ে শোনো।',
        <String>[
          'Listen carefully.',
          'Listens carefully.',
          'Listening carefully.',
        ],
        'Listen carefully.',
        'Listen হলো base verb।',
      ),
      _test(
        'imperative_test_04',
        'আস্তে কথা বলো।',
        <String>[
          'Speak slowly.',
          'Speaks slowly.',
          'Speaking slowly.',
        ],
        'Speak slowly.',
        'নির্দেশ দিতে Speak slowly ব্যবহার হয়।',
      ),
      _test(
        'imperative_test_05',
        'তোমার নাম লেখো।',
        <String>[
          'Write your name.',
          'Writes your name.',
          'Writing your name.',
        ],
        'Write your name.',
        'Imperative sentence-এ Write-এর base form হয়।',
      ),
      _test(
        'imperative_test_06',
        'এখানে আসো।',
        <String>[
          'Come here.',
          'Comes here.',
          'Coming here.',
        ],
        'Come here.',
        'আদেশ বা নির্দেশে Come here বলা হয়।',
      ),
      _test(
        'imperative_test_07',
        'দৌড়াবে না।',
        <String>[
          "Don't run.",
          "Doesn't run.",
          "Don't running.",
        ],
        "Don't run.",
        "নেতিবাচক আদেশে Don't + base verb হয়।",
      ),
      _test(
        'imperative_test_08',
        'এটি স্পর্শ করবে না।',
        <String>[
          "Don't touch it.",
          "Don't touches it.",
          "Doesn't touch it.",
        ],
        "Don't touch it.",
        "Don't-এর পরে touch-এর base form হয়।",
      ),
      _test(
        'imperative_test_09',
        'বামে ঘুরো।',
        <String>[
          'Turn left.',
          'Turns left.',
          'Turning left.',
        ],
        'Turn left.',
        'নির্দেশ দিতে Turn left বলা হয়।',
      ),
      _test(
        'imperative_test_10',
        'দয়া করে আমাকে সাহায্য করো।',
        <String>[
          'Please help me.',
          'Please helps me.',
          'Please helping me.',
        ],
        'Please help me.',
        'Please-এর পরে base verb ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'imperative_speaking_01',
        'বলুন: দরজা খোলো।',
        'Open the door.',
        Icons.door_front_door_rounded,
        _teal,
      ),
      _speaking(
        'imperative_speaking_02',
        'বলুন: মনোযোগ দিয়ে শোনো।',
        'Listen carefully.',
        Icons.hearing_rounded,
        Colors.blue,
      ),
      _speaking(
        'imperative_speaking_03',
        'বলুন: আস্তে কথা বলো।',
        'Speak slowly.',
        Icons.record_voice_over_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'imperative_speaking_04',
        'বলুন: দৌড়াবে না।',
        "Don't run.",
        Icons.directions_run_rounded,
        Colors.orange,
      ),
      _speaking(
        'imperative_speaking_05',
        'বলুন: দয়া করে আমাকে সাহায্য করো।',
        'Please help me.',
        Icons.help_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _what = RuleContent(
    id: 'what',
    order: 51,
    title: 'What',
    shortMeaning: 'কী বা কোন বিষয় জানতে',
    usage: 'কোনো ব্যক্তি, বস্তু, কাজ বা তথ্য সম্পর্কে জানতে What ব্যবহার হয়।',
    formula: 'What + Helping Verb + Subject + Verb?',
    category: 'Questions',
    level: RuleLevel.beginner,
    icon: Icons.question_mark_rounded,
    color: Colors.blue,
    keywords: <String>[
      'What',
      'Question',
      'Thing',
      'Information',
    ],
    examples: <RuleExample>[
      _example(
        'তোমার নাম কী?',
        'What is your name?',
        'name',
        type: RuleExampleType.question,
      ),
      _example(
        'তুমি কী করো?',
        'What do you do?',
        'work',
        type: RuleExampleType.question,
      ),
      _example(
        'এটি কী?',
        'What is this?',
        'this',
        type: RuleExampleType.question,
      ),
      _example(
        'তুমি কী করছো?',
        'What are you doing?',
        'doing',
        type: RuleExampleType.question,
      ),
      _example(
        'তুমি কী চাও?',
        'What do you want?',
        'want',
        type: RuleExampleType.question,
      ),
      _example(
        'এখন কয়টা বাজে?',
        'What time is it?',
        'time',
        type: RuleExampleType.question,
      ),
      _example(
        'কী ঘটেছে?',
        'What happened?',
        'happened',
        type: RuleExampleType.question,
      ),
      _example(
        'তুমি কী কিনেছো?',
        'What did you buy?',
        'buy',
        type: RuleExampleType.question,
      ),
      _example(
        'আমি কী করতে পারি?',
        'What can I do?',
        'can_do',
        type: RuleExampleType.question,
      ),
      _example(
        'ওগুলো কী?',
        'What are those?',
        'those',
        type: RuleExampleType.question,
      ),
      _example(
        'তোমার প্রিয় রং কী?',
        'What is your favorite color?',
        'color',
        type: RuleExampleType.question,
      ),
      _example(
        'তোমার কী দরকার?',
        'What do you need?',
        'need',
        type: RuleExampleType.question,
      ),
      _example(
        'সে কী পড়ায়?',
        'What does she teach?',
        'teach',
        type: RuleExampleType.question,
      ),
      _example(
        'তুমি কী খাবে?',
        'What will you eat?',
        'eat',
        type: RuleExampleType.question,
      ),
      _example(
        'কী তোমাকে খুশি করে?',
        'What makes you happy?',
        'happy',
        type: RuleExampleType.question,
      ),
    ],
    tests: <RuleTest>[
      _test(
        'what_test_01',
        '___ is your name?',
        <String>['What', 'Why', 'Where'],
        'What',
        'নাম জানতে What is your name? বলা হয়।',
      ),
      _test(
        'what_test_02',
        '___ do you do?',
        <String>['What', 'Who', 'When'],
        'What',
        'কাজ বা পেশা জানতে What do you do? হয়।',
      ),
      _test(
        'what_test_03',
        'এটি কী?',
        <String>[
          'What is this?',
          'What are this?',
          'Why is this?',
        ],
        'What is this?',
        'একটি জিনিস সম্পর্কে জানতে What is this? হয়।',
      ),
      _test(
        'what_test_04',
        'তুমি কী করছো?',
        <String>[
          'What are you doing?',
          'What is you doing?',
          'What do you doing?',
        ],
        'What are you doing?',
        'You-এর সঙ্গে are এবং doing ব্যবহার হয়।',
      ),
      _test(
        'what_test_05',
        'তুমি কী চাও?',
        <String>[
          'What do you want?',
          'What does you want?',
          'What are you want?',
        ],
        'What do you want?',
        'You-এর সঙ্গে do ব্যবহার হয়।',
      ),
      _test(
        'what_test_06',
        'এখন কয়টা বাজে?',
        <String>[
          'What time is it?',
          'What time are it?',
          'What is time it?',
        ],
        'What time is it?',
        'সময় জানতে What time is it? বলা হয়।',
      ),
      _test(
        'what_test_07',
        'তুমি কী কিনেছো?',
        <String>[
          'What did you buy?',
          'What did you bought?',
          'What do you bought?',
        ],
        'What did you buy?',
        'Did-এর পরে buy-এর base form হয়।',
      ),
      _test(
        'what_test_08',
        'আমি কী করতে পারি?',
        <String>[
          'What can I do?',
          'What can I does?',
          'What do I can do?',
        ],
        'What can I do?',
        'Can-এর পরে do-এর base form হয়।',
      ),
      _test(
        'what_test_09',
        'সে কী পড়ায়?',
        <String>[
          'What does she teach?',
          'What do she teach?',
          'What does she teaches?',
        ],
        'What does she teach?',
        'Does-এর পরে teach-এর base form হয়।',
      ),
      _test(
        'what_test_10',
        'তুমি কী খাবে?',
        <String>[
          'What will you eat?',
          'What will you eats?',
          'What do you will eat?',
        ],
        'What will you eat?',
        'Will-এর পরে eat-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'what_speaking_01',
        'প্রশ্ন করুন: তোমার নাম কী?',
        'What is your name?',
        Icons.badge_rounded,
        _teal,
      ),
      _speaking(
        'what_speaking_02',
        'প্রশ্ন করুন: তুমি কী করো?',
        'What do you do?',
        Icons.work_rounded,
        Colors.blue,
      ),
      _speaking(
        'what_speaking_03',
        'প্রশ্ন করুন: এটি কী?',
        'What is this?',
        Icons.help_outline_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'what_speaking_04',
        'প্রশ্ন করুন: তুমি কী করছো?',
        'What are you doing?',
        Icons.directions_run_rounded,
        Colors.orange,
      ),
      _speaking(
        'what_speaking_05',
        'প্রশ্ন করুন: তুমি কী চাও?',
        'What do you want?',
        Icons.shopping_cart_rounded,
        Colors.green,
      ),
    ],
  );
}