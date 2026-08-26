import 'package:flutter/material.dart';

import '../../models/rule_content.dart';

abstract final class Batch20Rules {
  static const Color _teal = Color(0xFF0E9F6E);

  static final List<RuleContent> rules = <RuleContent>[
    _inOnAt,
    _toFromForWithBy,
    _connectingWords,
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

  static final RuleContent _inOnAt = RuleContent(
    id: 'in_on_at',
    order: 58,
    title: 'In / On / At',
    shortMeaning: 'সময় ও স্থান বোঝাতে',
    usage:
    'In বড় স্থান বা দীর্ঘ সময়, On দিন বা কোনো surface এবং At নির্দিষ্ট স্থান বা সময় বোঝাতে ব্যবহার হয়।',
    formula: 'In + Place/Month/Year | On + Day/Surface | At + Exact Time/Place',
    category: 'Prepositions',
    level: RuleLevel.beginner,
    icon: Icons.location_on_rounded,
    color: _teal,
    keywords: <String>[
      'In',
      'On',
      'At',
      'Place',
      'Time',
    ],
    examples: <RuleExample>[
      _example(
        'আমি বাংলাদেশে থাকি।',
        'I live in Bangladesh.',
        'country',
      ),
      _example(
        'বইটি টেবিলের উপর আছে।',
        'The book is on the table.',
        'table',
      ),
      _example(
        'আমি সকাল ৭টায় উঠি।',
        'I wake up at 7 o’clock.',
        'morning',
      ),
      _example(
        'সে ২০০০ সালে জন্মগ্রহণ করেছে।',
        'He was born in 2000.',
        'year',
      ),
      _example(
        'আমাদের সোমবার ক্লাস আছে।',
        'We have class on Monday.',
        'monday',
      ),
      _example(
        'সে বাড়িতে আছে।',
        'She is at home.',
        'home',
      ),
      _example(
        'আমি সকালে হাঁটি।',
        'I walk in the morning.',
        'walk',
      ),
      _example(
        'ছবিটি দেয়ালের উপর আছে।',
        'The picture is on the wall.',
        'wall',
      ),
      _example(
        'আমি রাতে পড়াশোনা করি।',
        'I study at night.',
        'night',
      ),
      _example(
        'সে ঢাকায় থাকে।',
        'She lives in Dhaka.',
        'dhaka',
      ),
      _example(
        'আমি বাসে আছি।',
        'I am on the bus.',
        'bus',
      ),
      _example(
        'ছাত্ররা স্কুলে আছে।',
        'The students are at school.',
        'school',
      ),
      _example(
        'চাবিটি বাক্সের মধ্যে আছে।',
        'The key is in the box.',
        'box',
      ),
      _example(
        'রবিবার আমরা বিশ্রাম নিই।',
        'We rest on Sunday.',
        'sunday',
      ),
      _example(
        'মিটিং বিকেল ৫টায় হবে।',
        'The meeting will be at 5 pm.',
        'meeting',
      ),
    ],
    tests: <RuleTest>[
      _test(
        'in_on_at_test_01',
        'I live ___ Bangladesh.',
        <String>['in', 'on', 'at'],
        'in',
        'দেশ বা বড় স্থানের আগে in বসে।',
      ),
      _test(
        'in_on_at_test_02',
        'The book is ___ the table.',
        <String>['on', 'in', 'at'],
        'on',
        'কোনো surface-এর উপর বোঝাতে on হয়।',
      ),
      _test(
        'in_on_at_test_03',
        'I wake up ___ 7 o’clock.',
        <String>['at', 'in', 'on'],
        'at',
        'নির্দিষ্ট সময়ের আগে at হয়।',
      ),
      _test(
        'in_on_at_test_04',
        'He was born ___ 2000.',
        <String>['in', 'on', 'at'],
        'in',
        'বছরের আগে in ব্যবহার হয়।',
      ),
      _test(
        'in_on_at_test_05',
        'We have class ___ Monday.',
        <String>['on', 'in', 'at'],
        'on',
        'দিনের আগে on ব্যবহার হয়।',
      ),
      _test(
        'in_on_at_test_06',
        'সে বাড়িতে আছে।',
        <String>[
          'She is at home.',
          'She is in home.',
          'She is on home.',
        ],
        'She is at home.',
        'নির্দিষ্ট অবস্থান বোঝাতে at home হয়।',
      ),
      _test(
        'in_on_at_test_07',
        'আমি সকালে হাঁটি।',
        <String>[
          'I walk in the morning.',
          'I walk on the morning.',
          'I walk at the morning.',
        ],
        'I walk in the morning.',
        'সকাল বা সময়ের অংশের আগে in হয়।',
      ),
      _test(
        'in_on_at_test_08',
        'ছবিটি দেয়ালের উপর আছে।',
        <String>[
          'The picture is on the wall.',
          'The picture is in the wall.',
          'The picture is at the wall.',
        ],
        'The picture is on the wall.',
        'দেয়ালের উপর বোঝাতে on হয়।',
      ),
      _test(
        'in_on_at_test_09',
        'আমি রাতে পড়াশোনা করি।',
        <String>[
          'I study at night.',
          'I study on night.',
          'I study in night.',
        ],
        'I study at night.',
        'Night-এর আগে সাধারণত at ব্যবহার হয়।',
      ),
      _test(
        'in_on_at_test_10',
        'মিটিং বিকেল ৫টায় হবে।',
        <String>[
          'The meeting will be at 5 pm.',
          'The meeting will be in 5 pm.',
          'The meeting will be on 5 pm.',
        ],
        'The meeting will be at 5 pm.',
        'নির্দিষ্ট clock time-এর আগে at হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'in_on_at_speaking_01',
        'বলুন: আমি বাংলাদেশে থাকি।',
        'I live in Bangladesh.',
        Icons.public_rounded,
        _teal,
      ),
      _speaking(
        'in_on_at_speaking_02',
        'বলুন: বইটি টেবিলের উপর আছে।',
        'The book is on the table.',
        Icons.menu_book_rounded,
        Colors.blue,
      ),
      _speaking(
        'in_on_at_speaking_03',
        'বলুন: আমি সকাল ৭টায় উঠি।',
        'I wake up at 7 o’clock.',
        Icons.alarm_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'in_on_at_speaking_04',
        'বলুন: সে ঢাকায় থাকে।',
        'She lives in Dhaka.',
        Icons.location_city_rounded,
        Colors.orange,
      ),
      _speaking(
        'in_on_at_speaking_05',
        'বলুন: মিটিং বিকেল ৫টায় হবে।',
        'The meeting will be at 5 pm.',
        Icons.event_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _toFromForWithBy = RuleContent(
    id: 'to_from_for_with_by',
    order: 59,
    title: 'To / From / For / With / By',
    shortMeaning: 'দিক, উৎস, উদ্দেশ্য ও মাধ্যম বোঝাতে',
    usage:
    'To দিক বা গন্তব্য, From উৎস, For উদ্দেশ্য, With সঙ্গী বা উপকরণ এবং By মাধ্যম বা কর্তা বোঝাতে ব্যবহার হয়।',
    formula:
    'To + Destination | From + Source | For + Purpose | With + Person/Tool | By + Method/Agent',
    category: 'Prepositions',
    level: RuleLevel.basic,
    icon: Icons.compare_arrows_rounded,
    color: Colors.blue,
    keywords: <String>[
      'To',
      'From',
      'For',
      'With',
      'By',
    ],
    examples: <RuleExample>[
      _example('আমি স্কুলে যাই।', 'I go to school.', 'school'),
      _example('সে ঢাকা থেকে এসেছে।', 'She came from Dhaka.', 'dhaka'),
      _example('এই উপহারটি তোমার জন্য।', 'This gift is for you.', 'gift'),
      _example('আমি আমার বন্ধুর সঙ্গে আছি।', 'I am with my friend.', 'friend'),
      _example('চিঠিটি রাজ দ্বারা লেখা।', 'The letter was written by Raj.', 'letter'),
      _example('আমি বাজারে হাঁটতে যাই।', 'I walk to the market.', 'market'),
      _example('সে অফিস থেকে এসেছে।', 'He came from the office.', 'office'),
      _example('আমি বাসের জন্য অপেক্ষা করছি।', 'I am waiting for the bus.', 'bus'),
      _example('সে ছুরি দিয়ে আপেল কাটে।', 'She cuts the apple with a knife.', 'knife'),
      _example('আমরা বাসে ভ্রমণ করি।', 'We travel by bus.', 'travel'),
      _example('আমি মাকে চিঠি পাঠাই।', 'I send a letter to my mother.', 'mother'),
      _example('সে একটি কোম্পানির জন্য কাজ করে।', 'He works for a company.', 'company'),
      _example('এটি হাতে তৈরি।', 'It is made by hand.', 'hand'),
      _example('আমি শিক্ষকের সঙ্গে কথা বলি।', 'I talk with my teacher.', 'teacher'),
      _example('আমি আমার বোনের জন্য এটি কিনেছি।', 'I bought it for my sister.', 'sister'),
    ],
    tests: <RuleTest>[
      _test(
        'to_from_for_with_by_test_01',
        'I go ___ school.',
        <String>['to', 'from', 'for'],
        'to',
        'গন্তব্য বোঝাতে to ব্যবহার হয়।',
      ),
      _test(
        'to_from_for_with_by_test_02',
        'She came ___ Dhaka.',
        <String>['from', 'to', 'with'],
        'from',
        'উৎস বা কোথা থেকে বোঝাতে from হয়।',
      ),
      _test(
        'to_from_for_with_by_test_03',
        'This gift is ___ you.',
        <String>['for', 'to', 'by'],
        'for',
        'কারও জন্য বোঝাতে for ব্যবহার হয়।',
      ),
      _test(
        'to_from_for_with_by_test_04',
        'I am ___ my friend.',
        <String>['with', 'from', 'by'],
        'with',
        'কারও সঙ্গে বোঝাতে with হয়।',
      ),
      _test(
        'to_from_for_with_by_test_05',
        'The letter was written ___ Raj.',
        <String>['by', 'with', 'for'],
        'by',
        'কাজটি কে করেছে বোঝাতে by হয়।',
      ),
      _test(
        'to_from_for_with_by_test_06',
        'আমি বাজারে যাই।',
        <String>[
          'I go to the market.',
          'I go from the market.',
          'I go for the market.',
        ],
        'I go to the market.',
        'গন্তব্যের আগে to ব্যবহার হয়।',
      ),
      _test(
        'to_from_for_with_by_test_07',
        'আমি বাসের জন্য অপেক্ষা করছি।',
        <String>[
          'I am waiting for the bus.',
          'I am waiting to the bus.',
          'I am waiting by the bus.',
        ],
        'I am waiting for the bus.',
        'কোনো কিছুর জন্য অপেক্ষা করতে for হয়।',
      ),
      _test(
        'to_from_for_with_by_test_08',
        'সে ছুরি দিয়ে আপেল কাটে।',
        <String>[
          'She cuts the apple with a knife.',
          'She cuts the apple by a knife.',
          'She cuts the apple for a knife.',
        ],
        'She cuts the apple with a knife.',
        'উপকরণ বোঝাতে with ব্যবহার হয়।',
      ),
      _test(
        'to_from_for_with_by_test_09',
        'আমরা বাসে ভ্রমণ করি।',
        <String>[
          'We travel by bus.',
          'We travel with bus.',
          'We travel to bus.',
        ],
        'We travel by bus.',
        'যাতায়াতের মাধ্যম বোঝাতে by হয়।',
      ),
      _test(
        'to_from_for_with_by_test_10',
        'সে একটি কোম্পানির জন্য কাজ করে।',
        <String>[
          'He works for a company.',
          'He works to a company.',
          'He works from a company.',
        ],
        'He works for a company.',
        'কারও বা কোনো প্রতিষ্ঠানের জন্য কাজ করতে for হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'to_from_for_with_by_speaking_01',
        'বলুন: আমি স্কুলে যাই।',
        'I go to school.',
        Icons.school_rounded,
        _teal,
      ),
      _speaking(
        'to_from_for_with_by_speaking_02',
        'বলুন: সে ঢাকা থেকে এসেছে।',
        'She came from Dhaka.',
        Icons.location_city_rounded,
        Colors.blue,
      ),
      _speaking(
        'to_from_for_with_by_speaking_03',
        'বলুন: এই উপহারটি তোমার জন্য।',
        'This gift is for you.',
        Icons.card_giftcard_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'to_from_for_with_by_speaking_04',
        'বলুন: আমি আমার বন্ধুর সঙ্গে আছি।',
        'I am with my friend.',
        Icons.people_rounded,
        Colors.orange,
      ),
      _speaking(
        'to_from_for_with_by_speaking_05',
        'বলুন: আমরা বাসে ভ্রমণ করি।',
        'We travel by bus.',
        Icons.directions_bus_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _connectingWords = RuleContent(
    id: 'connecting_words',
    order: 60,
    title: 'And / But / Or / Because / So',
    shortMeaning: 'দুইটি idea যুক্ত করতে',
    usage:
    'And যোগ করতে, But বিপরীত idea বলতে, Or বিকল্প দিতে, Because কারণ জানাতে এবং So ফলাফল বোঝাতে ব্যবহার হয়।',
    formula:
    'Idea 1 + And/But/Or/Because/So + Idea 2',
    category: 'Connecting Words',
    level: RuleLevel.basic,
    icon: Icons.link_rounded,
    color: Colors.deepPurple,
    keywords: <String>[
      'And',
      'But',
      'Or',
      'Because',
      'So',
      'Connector',
    ],
    examples: <RuleExample>[
      _example(
        'আমি চা এবং কফি পছন্দ করি।',
        'I like tea and coffee.',
        'tea',
      ),
      _example(
        'সে দরিদ্র কিন্তু সুখী।',
        'He is poor but happy.',
        'happy',
      ),
      _example(
        'তুমি চা অথবা কফি নিতে পারো।',
        'You can have tea or coffee.',
        'choice',
      ),
      _example(
        'আমি বাড়িতে থাকি কারণ বৃষ্টি হচ্ছে।',
        'I stay home because it is raining.',
        'rain',
      ),
      _example(
        'আমি অসুস্থ তাই আমি বিশ্রাম নিচ্ছি।',
        'I am sick, so I am resting.',
        'rest',
      ),
      _example(
        'সে পড়ে এবং লেখে।',
        'She reads and writes.',
        'read_write',
      ),
      _example(
        'আমি যেতে চেয়েছিলাম কিন্তু আমি ব্যস্ত ছিলাম।',
        'I wanted to go, but I was busy.',
        'busy',
      ),
      _example(
        'তুমি বাসে অথবা ট্রেনে যেতে পারো।',
        'You can go by bus or train.',
        'transport',
      ),
      _example(
        'সে হাসছে কারণ সে খুশি।',
        'She is smiling because she is happy.',
        'smile',
      ),
      _example(
        'বৃষ্টি হচ্ছিল তাই আমরা বাইরে যাইনি।',
        'It was raining, so we did not go outside.',
        'outside',
      ),
      _example(
        'আমি English এবং বাংলা বলি।',
        'I speak English and Bengali.',
        'language',
      ),
      _example(
        'কাজটি কঠিন কিন্তু মজার।',
        'The work is difficult but interesting.',
        'work',
      ),
      _example(
        'তুমি এখন অথবা পরে আসতে পারো।',
        'You can come now or later.',
        'later',
      ),
      _example(
        'সে দেরি করেছে কারণ বাস দেরি করেছিল।',
        'He is late because the bus was late.',
        'late',
      ),
      _example(
        'আমার ক্ষুধা লেগেছে তাই আমি খাবার কিনেছি।',
        'I was hungry, so I bought food.',
        'food',
      ),
    ],
    tests: <RuleTest>[
      _test(
        'connecting_words_test_01',
        'I like tea ___ coffee.',
        <String>['and', 'but', 'or'],
        'and',
        'দুইটি পছন্দ যোগ করতে and ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_02',
        'He is poor ___ happy.',
        <String>['but', 'and', 'because'],
        'but',
        'বিপরীত idea বোঝাতে but ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_03',
        'You can have tea ___ coffee.',
        <String>['or', 'and', 'so'],
        'or',
        'বিকল্প দিতে or ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_04',
        'I stay home ___ it is raining.',
        <String>['because', 'but', 'or'],
        'because',
        'কারণ জানাতে because ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_05',
        'I am sick, ___ I am resting.',
        <String>['so', 'but', 'or'],
        'so',
        'ফলাফল বোঝাতে so ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_06',
        'সে পড়ে এবং লেখে।',
        <String>[
          'She reads and writes.',
          'She reads but writes.',
          'She reads or writes.',
        ],
        'She reads and writes.',
        'দুইটি কাজ যোগ করতে and হয়।',
      ),
      _test(
        'connecting_words_test_07',
        'আমি যেতে চেয়েছিলাম কিন্তু ব্যস্ত ছিলাম।',
        <String>[
          'I wanted to go, but I was busy.',
          'I wanted to go, and I was busy.',
          'I wanted to go, or I was busy.',
        ],
        'I wanted to go, but I was busy.',
        'বিপরীত ভাব বোঝাতে but বসে।',
      ),
      _test(
        'connecting_words_test_08',
        'তুমি বাসে অথবা ট্রেনে যেতে পারো।',
        <String>[
          'You can go by bus or train.',
          'You can go by bus and train.',
          'You can go by bus because train.',
        ],
        'You can go by bus or train.',
        'দুটি বিকল্পের মধ্যে or ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_09',
        'বৃষ্টি হচ্ছিল তাই আমরা বাইরে যাইনি।',
        <String>[
          'It was raining, so we did not go outside.',
          'It was raining, but we did not go outside.',
          'It was raining, or we did not go outside.',
        ],
        'It was raining, so we did not go outside.',
        'ফলাফল বোঝাতে so ব্যবহার হয়।',
      ),
      _test(
        'connecting_words_test_10',
        'সে দেরি করেছে কারণ বাস দেরি করেছিল।',
        <String>[
          'He is late because the bus was late.',
          'He is late but the bus was late.',
          'He is late or the bus was late.',
        ],
        'He is late because the bus was late.',
        'কারণ বোঝাতে because ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'connecting_words_speaking_01',
        'বলুন: আমি চা এবং কফি পছন্দ করি।',
        'I like tea and coffee.',
        Icons.local_cafe_rounded,
        _teal,
      ),
      _speaking(
        'connecting_words_speaking_02',
        'বলুন: সে দরিদ্র কিন্তু সুখী।',
        'He is poor but happy.',
        Icons.sentiment_satisfied_rounded,
        Colors.blue,
      ),
      _speaking(
        'connecting_words_speaking_03',
        'বলুন: তুমি চা অথবা কফি নিতে পারো।',
        'You can have tea or coffee.',
        Icons.restaurant_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'connecting_words_speaking_04',
        'বলুন: আমি বাড়িতে থাকি কারণ বৃষ্টি হচ্ছে।',
        'I stay home because it is raining.',
        Icons.umbrella_rounded,
        Colors.orange,
      ),
      _speaking(
        'connecting_words_speaking_05',
        'বলুন: আমি অসুস্থ তাই আমি বিশ্রাম নিচ্ছি।',
        'I am sick, so I am resting.',
        Icons.healing_rounded,
        Colors.green,
      ),
    ],
  );
}