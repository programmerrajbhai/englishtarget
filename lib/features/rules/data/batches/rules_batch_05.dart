import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch05Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _thisIsThatIs,
    _isThisThat,
    _areTheseThose,
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

  static final RuleContent _thisIsThatIs = RuleContent(
    id: 'this_is_that_is',
    order: 13,
    title: 'This is & That is',
    shortMeaning: 'কাছের বা দূরের কিছু পরিচয় করাতে',
    usage:
    'কাছের বা দূরের কোনো ব্যক্তি বা বস্তুকে পরিচয় করিয়ে দিতে This is এবং That is ব্যবহার হয়।',
    formula: 'This/That + is + noun',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.touch_app_rounded,
    color: AppColors.blue,
    keywords: <String>['This is', 'That is', 'Near', 'Far'],
    examples: <RuleExample>[
      _example('এটি আমার বই।', 'This is my book.', 'book_near'),
      _example('এটি একটি কলম।', 'This is a pen.', 'pen_near'),
      _example('এটি আমার ফোন।', 'This is my phone.', 'phone_near'),
      _example('এটি একটি চেয়ার।', 'This is a chair.', 'chair_near'),
      _example('ওটি একটি গাড়ি।', 'That is a car.', 'car_far'),
      _example('ওটি একটি বাড়ি।', 'That is a house.', 'house_far'),
      _example('ওটি আমার স্কুল।', 'That is my school.', 'school_far'),
      _example('ওটি একটি গাছ।', 'That is a tree.', 'tree_far'),
      _example('এটি একটি লাল বল।', 'This is a red ball.', 'ball_near'),
      _example('ওটি একটি বড় বাস।', 'That is a big bus.', 'bus_far'),
      _example('এটি আমার ব্যাগ।', 'This is my bag.', 'bag_near'),
      _example('ওটি একটি হাসপাতাল।', 'That is a hospital.', 'hospital_far'),
      _example('এটি একটি কম্পিউটার।', 'This is a computer.', 'computer_near'),
      _example('ওটি একটি সুন্দর ফুল।', 'That is a beautiful flower.', 'flower_far'),
      _example(
        'এটি আমার ব্যাগ নয়।',
        'This is not my bag.',
        'bag_not_near',
        type: RuleExampleType.negative,
      ),
    ],
    tests: <RuleTest>[
      _test(
        'this_is_that_is_test_01',
        '___ is my book. (near)',
        <String>['This', 'That', 'Those'],
        'This',
        'কাছের একটি জিনিসের জন্য This is ব্যবহার হয়।',
      ),
      _test(
        'this_is_that_is_test_02',
        '___ is a car. (far)',
        <String>['This', 'That', 'These'],
        'That',
        'দূরের একটি জিনিসের জন্য That is ব্যবহার হয়।',
      ),
      _test(
        'this_is_that_is_test_03',
        'Choose the correct sentence:',
        <String>[
          'This is a pen.',
          'This are a pen.',
          'This am a pen.',
        ],
        'This is a pen.',
        'This-এর সঙ্গে is বসে।',
      ),
      _test(
        'this_is_that_is_test_04',
        'Choose the correct sentence:',
        <String>[
          'That is a house.',
          'That are a house.',
          'That am a house.',
        ],
        'That is a house.',
        'That-এর সঙ্গে is বসে।',
      ),
      _test(
        'this_is_that_is_test_05',
        'এটি আমার ফোন।',
        <String>[
          'This is my phone.',
          'That are my phone.',
          'This am my phone.',
        ],
        'This is my phone.',
        'কাছের একটি ফোনের জন্য This is হবে।',
      ),
      _test(
        'this_is_that_is_test_06',
        'ওটি একটি গাছ।',
        <String>[
          'This is a tree.',
          'That is a tree.',
          'Those are a tree.',
        ],
        'That is a tree.',
        'দূরের একটি গাছের জন্য That is হবে।',
      ),
      _test(
        'this_is_that_is_test_07',
        '___ is my bag. (near)',
        <String>['This', 'That', 'Those'],
        'This',
        'কাছের একটি ব্যাগের জন্য This ব্যবহার হয়।',
      ),
      _test(
        'this_is_that_is_test_08',
        '___ is my school. (far)',
        <String>['This', 'That', 'These'],
        'That',
        'দূরের একটি school-এর জন্য That ব্যবহার হয়।',
      ),
      _test(
        'this_is_that_is_test_09',
        'Choose the correct negative sentence:',
        <String>[
          'This is not my bag.',
          'This are not my bag.',
          'This am not my bag.',
        ],
        'This is not my bag.',
        'Negative sentence-এ This-এর সঙ্গে is not বসে।',
      ),
      _test(
        'this_is_that_is_test_10',
        'ওটি একটি হাসপাতাল।',
        <String>[
          'That is a hospital.',
          'That are a hospital.',
          'This are a hospital.',
        ],
        'That is a hospital.',
        'দূরের একটি hospital-এর জন্য That is হবে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'this_is_that_is_speaking_01',
        'কাছের একটি বই দেখে বলুন।',
        'This is my book.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'this_is_that_is_speaking_02',
        'দূরের একটি গাড়ি দেখে বলুন।',
        'That is a car.',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'this_is_that_is_speaking_03',
        'কাছের একটি ফোন দেখে বলুন।',
        'This is my phone.',
        Icons.phone_android_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'this_is_that_is_speaking_04',
        'দূরের একটি বাড়ি দেখে বলুন।',
        'That is a house.',
        Icons.home_rounded,
        Colors.orange,
      ),
      _speaking(
        'this_is_that_is_speaking_05',
        'কাছের একটি ব্যাগ দেখে বলুন।',
        'This is my bag.',
        Icons.backpack_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _isThisThat = RuleContent(
    id: 'is_this_that',
    order: 14,
    title: 'Is this? & Is that?',
    shortMeaning: 'একটি বস্তু সম্পর্কে প্রশ্ন করতে',
    usage:
    'কাছের বা দূরের একটি ব্যক্তি বা বস্তু সম্পর্কে Yes/No question করতে ব্যবহার হয়।',
    formula: 'Is + this/that + noun?',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.help_outline_rounded,
    color: AppColors.blue,
    keywords: <String>['Is this?', 'Is that?', 'Question', 'Yes/No'],
    examples: <RuleExample>[
      _example('এটি কি তোমার বই?', 'Is this your book?', 'book_question'),
      _example('এটি কি একটি কলম?', 'Is this a pen?', 'pen_question'),
      _example('এটি কি তোমার ফোন?', 'Is this your phone?', 'phone_question'),
      _example('এটি কি একটি ব্যাগ?', 'Is this a bag?', 'bag_question'),
      _example('ওটি কি একটি গাড়ি?', 'Is that a car?', 'car_question'),
      _example('ওটি কি তোমার বাড়ি?', 'Is that your house?', 'house_question'),
      _example('ওটি কি একটি স্কুল?', 'Is that a school?', 'school_question'),
      _example('ওটি কি একটি গাছ?', 'Is that a tree?', 'tree_question'),
      _example('এটি কি নতুন বই?', 'Is this a new book?', 'new_book_question'),
      _example('ওটি কি একটি হাসপাতাল?', 'Is that a hospital?', 'hospital_question'),
      _example('এটি কি তোমার চেয়ার?', 'Is this your chair?', 'chair_question'),
      _example('ওটি কি একটি বাস?', 'Is that a bus?', 'bus_question'),
      _example('এটি কি লাল বল?', 'Is this a red ball?', 'red_ball_question'),
      _example('ওটি কি সুন্দর ফুল?', 'Is that a beautiful flower?', 'flower_question'),
      _example('এটি কি তোমার ব্যাগ নয়?', 'Is this not your bag?', 'bag_negative_question'),
    ],
    tests: <RuleTest>[
      _test(
        'is_this_that_test_01',
        '___ this your book?',
        <String>['Is', 'Are', 'Am'],
        'Is',
        'This-এর question form হলো Is this...? ',
      ),
      _test(
        'is_this_that_test_02',
        '___ that a car?',
        <String>['Is', 'Are', 'Am'],
        'Is',
        'That-এর সঙ্গে Is বসে।',
      ),
      _test(
        'is_this_that_test_03',
        'Choose the correct question:',
        <String>[
          'Is this a pen?',
          'Are this a pen?',
          'Am this a pen?',
        ],
        'Is this a pen?',
        'Singular object-এর জন্য Is this...? ব্যবহার হয়।',
      ),
      _test(
        'is_this_that_test_04',
        'ওটি কি তোমার বাড়ি?',
        <String>[
          'Is that your house?',
          'Are that your house?',
          'Is those your house?',
        ],
        'Is that your house?',
        'দূরের singular object-এর জন্য Is that...? হবে।',
      ),
      _test(
        'is_this_that_test_05',
        '___ this your phone?',
        <String>['Is', 'Are', 'Does'],
        'Is',
        'This-এর আগে Is বসে।',
      ),
      _test(
        'is_this_that_test_06',
        '___ that a school?',
        <String>['Is', 'Are', 'Do'],
        'Is',
        'That-এর আগে Is বসে।',
      ),
      _test(
        'is_this_that_test_07',
        'Choose the correct question:',
        <String>[
          'Is this a new book?',
          'Are this a new book?',
          'Does this a new book?',
        ],
        'Is this a new book?',
        'Be verb question-এ Is শুরুতে বসে।',
      ),
      _test(
        'is_this_that_test_08',
        'এটি কি একটি ব্যাগ?',
        <String>[
          'Is this a bag?',
          'Is that a bag?',
          'Are this a bag?',
        ],
        'Is this a bag?',
        'কাছের একটি bag-এর জন্য Is this হবে।',
      ),
      _test(
        'is_this_that_test_09',
        'ওটি কি একটি বাস?',
        <String>[
          'Is this a bus?',
          'Is that a bus?',
          'Are that a bus?',
        ],
        'Is that a bus?',
        'দূরের একটি bus-এর জন্য Is that হবে।',
      ),
      _test(
        'is_this_that_test_10',
        'এটি কি তোমার ব্যাগ নয়?',
        <String>[
          'Is this not your bag?',
          'Are this not your bag?',
          'Is these not your bag?',
        ],
        'Is this not your bag?',
        'Negative question-এ Is this not...? ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'is_this_that_speaking_01',
        'একটি বই দেখে প্রশ্ন করুন।',
        'Is this your book?',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'is_this_that_speaking_02',
        'দূরের গাড়ি দেখে প্রশ্ন করুন।',
        'Is that a car?',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'is_this_that_speaking_03',
        'একটি ফোন দেখে প্রশ্ন করুন।',
        'Is this your phone?',
        Icons.phone_android_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'is_this_that_speaking_04',
        'দূরের বাড়ি দেখে প্রশ্ন করুন।',
        'Is that your house?',
        Icons.home_rounded,
        Colors.orange,
      ),
      _speaking(
        'is_this_that_speaking_05',
        'একটি ব্যাগ দেখে প্রশ্ন করুন।',
        'Is this a bag?',
        Icons.backpack_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _areTheseThose = RuleContent(
    id: 'are_these_those',
    order: 15,
    title: 'Are these? & Are those?',
    shortMeaning: 'একাধিক বস্তু সম্পর্কে প্রশ্ন করতে',
    usage:
    'কাছের বা দূরের একাধিক ব্যক্তি বা বস্তু সম্পর্কে Yes/No question করতে ব্যবহার হয়।',
    formula: 'Are + these/those + plural noun?',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.help_center_rounded,
    color: AppColors.blue,
    keywords: <String>['Are these?', 'Are those?', 'Plural', 'Question'],
    examples: <RuleExample>[
      _example('এগুলো কি তোমার বই?', 'Are these your books?', 'books_question'),
      _example('এগুলো কি কলম?', 'Are these pens?', 'pens_question'),
      _example('এগুলো কি তোমার জুতা?', 'Are these your shoes?', 'shoes_question'),
      _example('এগুলো কি নতুন ব্যাগ?', 'Are these new bags?', 'bags_question'),
      _example('ওগুলো কি গাড়ি?', 'Are those cars?', 'cars_question'),
      _example('ওগুলো কি বড় বাড়ি?', 'Are those big houses?', 'houses_question'),
      _example('ওগুলো কি তোমার বন্ধু?', 'Are those your friends?', 'friends_question'),
      _example('ওগুলো কি গাছ?', 'Are those trees?', 'trees_question'),
      _example('এগুলো কি লাল বল?', 'Are these red balls?', 'balls_question'),
      _example('ওগুলো কি সুন্দর ফুল?', 'Are those beautiful flowers?', 'flowers_question'),
      _example('এগুলো কি তোমার চাবি?', 'Are these your keys?', 'keys_question'),
      _example('ওগুলো কি বাস?', 'Are those buses?', 'buses_question'),
      _example('এগুলো কি নতুন ফোন?', 'Are these new phones?', 'phones_question'),
      _example('ওগুলো কি পুরোনো বই?', 'Are those old books?', 'old_books_question'),
      _example('এগুলো কি তোমার জুতা নয়?', 'Are these not your shoes?', 'shoes_negative_question'),
    ],
    tests: <RuleTest>[
      _test(
        'are_these_those_test_01',
        '___ these your books?',
        <String>['Are', 'Is', 'Am'],
        'Are',
        'These-এর question form হলো Are these...? ',
      ),
      _test(
        'are_these_those_test_02',
        '___ those cars?',
        <String>['Are', 'Is', 'Am'],
        'Are',
        'Those-এর সঙ্গে Are বসে।',
      ),
      _test(
        'are_these_those_test_03',
        'Choose the correct question:',
        <String>[
          'Are these pens?',
          'Is these pens?',
          'Am these pens?',
        ],
        'Are these pens?',
        'Plural object-এর জন্য Are these...? ব্যবহার হয়।',
      ),
      _test(
        'are_these_those_test_04',
        'ওগুলো কি বড় বাড়ি?',
        <String>[
          'Are those big houses?',
          'Is those big houses?',
          'Are that big houses?',
        ],
        'Are those big houses?',
        'দূরের plural object-এর জন্য Are those...? হবে।',
      ),
      _test(
        'are_these_those_test_05',
        '___ these your shoes?',
        <String>['Are', 'Is', 'Does'],
        'Are',
        'These-এর আগে Are বসে।',
      ),
      _test(
        'are_these_those_test_06',
        '___ those trees?',
        <String>['Are', 'Is', 'Do'],
        'Are',
        'Those-এর আগে Are বসে।',
      ),
      _test(
        'are_these_those_test_07',
        'এগুলো কি লাল বল?',
        <String>[
          'Are these red balls?',
          'Is these red balls?',
          'Are this red balls?',
        ],
        'Are these red balls?',
        'কাছের plural object-এর জন্য Are these হবে।',
      ),
      _test(
        'are_these_those_test_08',
        'ওগুলো কি সুন্দর ফুল?',
        <String>[
          'Are those beautiful flowers?',
          'Is those beautiful flowers?',
          'Are that beautiful flowers?',
        ],
        'Are those beautiful flowers?',
        'দূরের plural object-এর জন্য Are those হবে।',
      ),
      _test(
        'are_these_those_test_09',
        'Choose the correct sentence:',
        <String>[
          'Are these your keys?',
          'Is these your keys?',
          'Are this your keys?',
        ],
        'Are these your keys?',
        'These plural, তাই Are ব্যবহার হবে।',
      ),
      _test(
        'are_these_those_test_10',
        'এগুলো কি তোমার জুতা নয়?',
        <String>[
          'Are these not your shoes?',
          'Is these not your shoes?',
          'Are this not your shoes?',
        ],
        'Are these not your shoes?',
        'Negative question-এ Are these not...? ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'are_these_those_speaking_01',
        'কয়েকটি বই দেখে প্রশ্ন করুন।',
        'Are these your books?',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'are_these_those_speaking_02',
        'দূরের গাড়িগুলো দেখে প্রশ্ন করুন।',
        'Are those cars?',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'are_these_those_speaking_03',
        'কাছের জুতাগুলো দেখে প্রশ্ন করুন।',
        'Are these your shoes?',
        Icons.shopping_bag_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'are_these_those_speaking_04',
        'দূরের বাড়িগুলো দেখে প্রশ্ন করুন।',
        'Are those big houses?',
        Icons.home_work_rounded,
        Colors.orange,
      ),
      _speaking(
        'are_these_those_speaking_05',
        'কাছের চাবিগুলো দেখে প্রশ্ন করুন।',
        'Are these your keys?',
        Icons.key_rounded,
        Colors.green,
      ),
    ],
  );
}