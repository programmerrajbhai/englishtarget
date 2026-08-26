
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch03Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _aAn,
    _the,
    _singularPlural,
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

  static final RuleContent _aAn = RuleContent(
    id: 'a_an',
    order: 7,
    title: 'A & An',
    shortMeaning: 'অনির্দিষ্ট একটি ব্যক্তি বা বস্তু বোঝাতে',
    usage:
    'Consonant sound-এর আগে A এবং vowel sound-এর আগে An ব্যবহার হয়।',
    formula: 'A/An + Singular Noun',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.looks_one_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'A',
      'An',
      'Singular',
      'Noun',
      'Vowel Sound',
    ],
    examples: <RuleExample>[
      _example('আমার একটি বই আছে।', 'I have a book.', 'book'),
      _example('সে একটি আপেল খায়।', 'She eats an apple.', 'apple'),
      _example('সে একজন শিক্ষক।', 'He is a teacher.', 'teacher'),
      _example('আমার একটি ছাতা আছে।', 'I have an umbrella.', 'umbrella'),
      _example('এটি একটি গাড়ি।', 'It is a car.', 'car'),
      _example('সে একটি ডিম খায়।', 'He eats an egg.', 'egg'),
      _example('আমি একজন ছাত্র।', 'I am a student.', 'student'),
      _example('সে একটি কমলা কিনেছে।', 'She bought an orange.', 'orange'),
      _example(
        'সে একজন প্রকৌশলী।',
        'He is an engineer.',
        'engineer',
      ),
      _example(
        'এটি একটি পুরোনো ঘড়ি।',
        'It is an old clock.',
        'clock',
      ),
      _example(
        'সে এক ঘণ্টা অপেক্ষা করেছে।',
        'She waited for an hour.',
        'hour',
      ),
      _example(
        'সে একটি বিশ্ববিদ্যালয়ে পড়ে।',
        'He studies at a university.',
        'university',
      ),
      _example(
        'আমার একটি নতুন ব্যাগ আছে।',
        'I have a new bag.',
        'bag',
      ),
      _example(
        'সে একটি আকর্ষণীয় গল্প বলেছে।',
        'She told an interesting story.',
        'story',
      ),
      _example(
        'এটি একটি সহজ প্রশ্ন।',
        'This is an easy question.',
        'question',
      ),
    ],
    tests: <RuleTest>[
      _test(
        'a_an_test_01',
        'I have ___ book.',
        <String>['a', 'an', 'the'],
        'a',
        'Book consonant sound দিয়ে শুরু, তাই a হবে।',
      ),
      _test(
        'a_an_test_02',
        'She eats ___ apple.',
        <String>['a', 'an', 'the'],
        'an',
        'Apple vowel sound দিয়ে শুরু, তাই an হবে।',
      ),
      _test(
        'a_an_test_03',
        'He is ___ teacher.',
        <String>['a', 'an', 'the'],
        'a',
        'Teacher consonant sound দিয়ে শুরু।',
      ),
      _test(
        'a_an_test_04',
        'I have ___ umbrella.',
        <String>['a', 'an', 'the'],
        'an',
        'Umbrella vowel sound দিয়ে শুরু।',
      ),
      _test(
        'a_an_test_05',
        'She bought ___ orange.',
        <String>['a', 'an', 'the'],
        'an',
        'Orange vowel sound দিয়ে শুরু।',
      ),
      _test(
        'a_an_test_06',
        'He is ___ engineer.',
        <String>['a', 'an', 'the'],
        'an',
        'Engineer vowel sound দিয়ে শুরু।',
      ),
      _test(
        'a_an_test_07',
        'Choose the correct sentence:',
        <String>[
          'I have a pen.',
          'I have an pen.',
          'I have the pen.',
        ],
        'I have a pen.',
        'Pen-এর আগে a ব্যবহার হয়।',
      ),
      _test(
        'a_an_test_08',
        'Choose the correct sentence:',
        <String>[
          'She is a artist.',
          'She is an artist.',
          'She is the artist.',
        ],
        'She is an artist.',
        'Artist vowel sound দিয়ে শুরু।',
      ),
      _test(
        'a_an_test_09',
        'He studies at ___ university.',
        <String>['a', 'an', 'the'],
        'a',
        'University “yu” sound দিয়ে শুরু, তাই a হবে।',
      ),
      _test(
        'a_an_test_10',
        'She waited for ___ hour.',
        <String>['a', 'an', 'the'],
        'an',
        'Hour-এর h silent, তাই vowel sound; an হবে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'a_an_speaking_01',
        'বলুন: আমার একটি বই আছে।',
        'I have a book.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'a_an_speaking_02',
        'বলুন: সে একটি আপেল খায়।',
        'She eats an apple.',
        Icons.fastfood_rounded,
        Colors.red,
      ),
      _speaking(
        'a_an_speaking_03',
        'বলুন: সে একজন শিক্ষক।',
        'He is a teacher.',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'a_an_speaking_04',
        'বলুন: আমার একটি ছাতা আছে।',
        'I have an umbrella.',
        Icons.umbrella_rounded,
        Colors.orange,
      ),
      _speaking(
        'a_an_speaking_05',
        'বলুন: এটি একটি গাড়ি।',
        'It is a car.',
        Icons.directions_car_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _the = RuleContent(
    id: 'the',
    order: 8,
    title: 'The',
    shortMeaning: 'নির্দিষ্ট ব্যক্তি বা বস্তু বোঝাতে',
    usage:
    'নির্দিষ্ট, পরিচিত বা আগে বলা ব্যক্তি ও বস্তুর আগে The ব্যবহার হয়।',
    formula: 'The + Specific Noun',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.label_important_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'The',
      'Specific',
      'Known',
      'Unique',
    ],
    examples: <RuleExample>[
      _example('সূর্য উজ্জ্বল।', 'The sun is bright.', 'sun'),
      _example('চাঁদ রাতে দেখা যায়।', 'The moon appears at night.', 'moon'),
      _example('দরজাটি বন্ধ করো।', 'Close the door.', 'door'),
      _example('শিক্ষকটি ক্লাসে আছেন।', 'The teacher is in the class.', 'teacher'),
      _example('বইটি টেবিলের উপর আছে।', 'The book is on the table.', 'book_table'),
      _example('গাড়িটি খুব দ্রুত।', 'The car is very fast.', 'car'),
      _example('আকাশ নীল।', 'The sky is blue.', 'sky'),
      _example('আমি জানালাটি খুলেছি।', 'I opened the window.', 'window'),
      _example('কুকুরটি বাগানে আছে।', 'The dog is in the garden.', 'dog'),
      _example('প্রথম প্রশ্নটি সহজ।', 'The first question is easy.', 'question'),
      _example('পৃথিবী গোল।', 'The earth is round.', 'earth'),
      _example('নদীটি অনেক বড়।', 'The river is very wide.', 'river'),
      _example('রান্নাঘরের আলোটি জ্বলছে।', 'The light in the kitchen is on.', 'light'),
      _example('ছেলেটি দরজার পাশে দাঁড়িয়ে আছে।', 'The boy is standing near the door.', 'boy'),
      _example('আমি যে ফোনটির কথা বলেছিলাম সেটি নতুন।', 'The phone I mentioned is new.', 'phone'),
    ],
    tests: <RuleTest>[
      _test(
        'the_test_01',
        '___ sun is bright.',
        <String>['A', 'An', 'The'],
        'The',
        'সূর্য একটি নির্দিষ্ট ও unique জিনিস।',
      ),
      _test(
        'the_test_02',
        'Close ___ door.',
        <String>['a', 'an', 'the'],
        'the',
        'নির্দিষ্ট দরজার কথা বলা হয়েছে।',
      ),
      _test(
        'the_test_03',
        '___ moon appears at night.',
        <String>['A', 'An', 'The'],
        'The',
        'চাঁদ নির্দিষ্ট একটি জিনিস।',
      ),
      _test(
        'the_test_04',
        'The book is on ___ table.',
        <String>['a', 'an', 'the'],
        'the',
        'নির্দিষ্ট টেবিল বোঝানো হয়েছে।',
      ),
      _test(
        'the_test_05',
        'Choose the correct sentence:',
        <String>[
          'The sky is blue.',
          'A sky is blue.',
          'An sky is blue.',
        ],
        'The sky is blue.',
        'আকাশ unique, তাই The sky হবে।',
      ),
      _test(
        'the_test_06',
        'I opened ___ window.',
        <String>['a', 'an', 'the'],
        'the',
        'নির্দিষ্ট জানালা বোঝানো হয়েছে।',
      ),
      _test(
        'the_test_07',
        '___ first question is easy.',
        <String>['A', 'An', 'The'],
        'The',
        'ক্রমবাচক শব্দের আগে The ব্যবহার হয়।',
      ),
      _test(
        'the_test_08',
        'Choose the correct sentence:',
        <String>[
          'The earth is round.',
          'An earth is round.',
          'A earth is round.',
        ],
        'The earth is round.',
        'পৃথিবী unique, তাই The earth হবে।',
      ),
      _test(
        'the_test_09',
        'The dog is in ___ garden.',
        <String>['a', 'an', 'the'],
        'the',
        'নির্দিষ্ট বাগানের কথা বলা হয়েছে।',
      ),
      _test(
        'the_test_10',
        '___ teacher is in the class.',
        <String>['A', 'An', 'The'],
        'The',
        'পরিচিত বা নির্দিষ্ট শিক্ষক বোঝানো হয়েছে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'the_speaking_01',
        'বলুন: সূর্য উজ্জ্বল।',
        'The sun is bright.',
        Icons.wb_sunny_rounded,
        Colors.orange,
      ),
      _speaking(
        'the_speaking_02',
        'বলুন: চাঁদ রাতে দেখা যায়।',
        'The moon appears at night.',
        Icons.nightlight_round,
        Colors.indigo,
      ),
      _speaking(
        'the_speaking_03',
        'বলুন: দরজাটি বন্ধ করো।',
        'Close the door.',
        Icons.door_front_door_rounded,
        Colors.brown,
      ),
      _speaking(
        'the_speaking_04',
        'বলুন: আকাশ নীল।',
        'The sky is blue.',
        Icons.cloud_rounded,
        Colors.blue,
      ),
      _speaking(
        'the_speaking_05',
        'বলুন: বইটি টেবিলের উপর আছে।',
        'The book is on the table.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
    ],
  );

  static final RuleContent _singularPlural = RuleContent(
    id: 'singular_plural',
    order: 9,
    title: 'Singular & Plural',
    shortMeaning: 'একটি ও একাধিক ব্যক্তি বা বস্তু বোঝাতে',
    usage:
    'একটি ব্যক্তি বা বস্তুকে Singular এবং একাধিক ব্যক্তি বা বস্তুকে Plural বলা হয়।',
    formula: 'Singular: one book | Plural: two books',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.format_list_numbered_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Singular',
      'Plural',
      'One',
      'Many',
      'Noun',
    ],
    examples: <RuleExample>[
      _example('এটি একটি বই।', 'This is a book.', 'one_book'),
      _example('এগুলো দুটি বই।', 'These are two books.', 'two_books'),
      _example('এটি একটি কলম।', 'This is a pen.', 'one_pen'),
      _example('এগুলো তিনটি কলম।', 'These are three pens.', 'three_pens'),
      _example('আমার একটি বন্ধু আছে।', 'I have a friend.', 'one_friend'),
      _example('আমার অনেক বন্ধু আছে।', 'I have many friends.', 'many_friends'),
      _example('সে একটি শিশু।', 'She is a child.', 'child'),
      _example('তারা শিশু।', 'They are children.', 'children'),
      _example('সে একজন মানুষ।', 'He is a man.', 'man'),
      _example('তারা পুরুষ।', 'They are men.', 'men'),
      _example('সে একজন মহিলা।', 'She is a woman.', 'woman'),
      _example('তারা মহিলা।', 'They are women.', 'women'),
      _example('টেবিলে একটি বাক্স আছে।', 'There is a box on the table.', 'one_box'),
      _example('টেবিলে দুটি বাক্স আছে।', 'There are two boxes on the table.', 'two_boxes'),
      _example('বাগানে অনেক গাছ আছে।', 'There are many trees in the garden.', 'many_trees'),
    ],
    tests: <RuleTest>[
      _test(
        'singular_plural_test_01',
        'One ___',
        <String>['book', 'books', 'bookes'],
        'book',
        'One-এর পরে singular noun হয়।',
      ),
      _test(
        'singular_plural_test_02',
        'Two ___',
        <String>['pen', 'pens', 'pен'],
        'pens',
        'Two-এর পরে plural noun হয়।',
      ),
      _test(
        'singular_plural_test_03',
        'Choose the correct sentence:',
        <String>[
          'This is a book.',
          'These is a book.',
          'This are a book.',
        ],
        'This is a book.',
        'একটি বই singular।',
      ),
      _test(
        'singular_plural_test_04',
        'Choose the correct sentence:',
        <String>[
          'These are two books.',
          'This is two books.',
          'These is two books.',
        ],
        'These are two books.',
        'দুটি বই plural।',
      ),
      _test(
        'singular_plural_test_05',
        'Plural form of “child” is:',
        <String>['childs', 'children', 'childes'],
        'children',
        'Child-এর irregular plural হলো children।',
      ),
      _test(
        'singular_plural_test_06',
        'Plural form of “man” is:',
        <String>['mans', 'men', 'manes'],
        'men',
        'Man-এর irregular plural হলো men।',
      ),
      _test(
        'singular_plural_test_07',
        'Plural form of “woman” is:',
        <String>['womans', 'women', 'womanes'],
        'women',
        'Woman-এর irregular plural হলো women।',
      ),
      _test(
        'singular_plural_test_08',
        'There ___ two boxes on the table.',
        <String>['is', 'are', 'am'],
        'are',
        'Two boxes plural, তাই are হবে।',
      ),
      _test(
        'singular_plural_test_09',
        'There ___ a box on the table.',
        <String>['is', 'are', 'am'],
        'is',
        'একটি box singular, তাই is হবে।',
      ),
      _test(
        'singular_plural_test_10',
        'Choose the correct sentence:',
        <String>[
          'They are children.',
          'They are childs.',
          'They is children.',
        ],
        'They are children.',
        'Children হলো child-এর সঠিক plural form।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'singular_plural_speaking_01',
        'একটি বই দেখে বলুন।',
        'This is a book.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'singular_plural_speaking_02',
        'দুটি বই দেখে বলুন।',
        'These are two books.',
        Icons.library_books_rounded,
        Colors.blue,
      ),
      _speaking(
        'singular_plural_speaking_03',
        'একজন শিশুকে দেখে বলুন।',
        'She is a child.',
        Icons.child_care_rounded,
        Colors.pink,
      ),
      _speaking(
        'singular_plural_speaking_04',
        'কয়েকজন শিশুকে দেখে বলুন।',
        'They are children.',
        Icons.groups_rounded,
        Colors.orange,
      ),
      _speaking(
        'singular_plural_speaking_05',
        'বাগানের অনেক গাছ সম্পর্কে বলুন।',
        'There are many trees in the garden.',
        Icons.park_rounded,
        Colors.green,
      ),
    ],
  );
}