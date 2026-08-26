import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch06Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _whoIsThisThat,
    _whatIsThisThat,
    _itIs,
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

  static final RuleContent _whoIsThisThat = RuleContent(
    id: 'who_is_this_that',
    order: 16,
    title: 'Who is this/that?',
    shortMeaning: 'কোনো ব্যক্তির পরিচয় জানতে',
    usage:
    'কাছের বা দূরের কোনো ব্যক্তি কে, তা জানতে Who is this? বা Who is that? ব্যবহার হয়।',
    formula: 'Who + is + this/that?',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.person_search_rounded,
    color: AppColors.blue,
    keywords: <String>['Who', 'This', 'That', 'Person'],
    examples: <RuleExample>[
      _example('এই ব্যক্তি কে?', 'Who is this?', 'person_near'),
      _example('ওই ব্যক্তি কে?', 'Who is that?', 'person_far'),
      _example('এই ছেলেটি কে?', 'Who is this boy?', 'boy_near'),
      _example('ওই মেয়েটি কে?', 'Who is that girl?', 'girl_far'),
      _example('এই শিক্ষক কে?', 'Who is this teacher?', 'teacher_near'),
      _example('ওই ডাক্তার কে?', 'Who is that doctor?', 'doctor_far'),
      _example('এই লোকটি কে?', 'Who is this man?', 'man_near'),
      _example('ওই মহিলাটি কে?', 'Who is that woman?', 'woman_far'),
      _example('এই ব্যক্তি আমার ভাই।', 'This person is my brother.', 'brother'),
      _example('ওই ব্যক্তি আমার বন্ধু।', 'That person is my friend.', 'friend'),
      _example('এই ছেলেটি আমার ছাত্র।', 'This boy is my student.', 'student'),
      _example('ওই মেয়েটি আমার বোন।', 'That girl is my sister.', 'sister'),
      _example('এই শিক্ষকটি ভালো।', 'This teacher is kind.', 'teacher_kind'),
      _example('ওই ডাক্তারটি ব্যস্ত।', 'That doctor is busy.', 'doctor_busy'),
      _example('এই ব্যক্তি কে নয়?', 'Who is this person?', 'person_question'),
    ],
    tests: <RuleTest>[
      _test(
        'who_is_this_that_test_01',
        '___ is this?',
        <String>['Who', 'What', 'Where'],
        'Who',
        'ব্যক্তির পরিচয় জানতে Who ব্যবহার হয়।',
      ),
      _test(
        'who_is_this_that_test_02',
        '___ is that?',
        <String>['Who', 'What', 'When'],
        'Who',
        'দূরের ব্যক্তির পরিচয় জানতে Who is that? বলা হয়।',
      ),
      _test(
        'who_is_this_that_test_03',
        'এই ব্যক্তি কে?',
        <String>[
          'Who is this?',
          'What is this?',
          'Where is this?',
        ],
        'Who is this?',
        'ব্যক্তি সম্পর্কে প্রশ্ন, তাই Who হবে।',
      ),
      _test(
        'who_is_this_that_test_04',
        'ওই মেয়েটি কে?',
        <String>[
          'Who is that girl?',
          'What is that girl?',
          'Where is that girl?',
        ],
        'Who is that girl?',
        'মেয়েটির পরিচয় জানতে Who ব্যবহার হয়।',
      ),
      _test(
        'who_is_this_that_test_05',
        '___ is this boy?',
        <String>['Who', 'What', 'How'],
        'Who',
        'Boy একজন ব্যক্তি, তাই Who হবে।',
      ),
      _test(
        'who_is_this_that_test_06',
        '___ is that doctor?',
        <String>['Who', 'What', 'Where'],
        'Who',
        'Doctor একজন ব্যক্তি, তাই Who হবে।',
      ),
      _test(
        'who_is_this_that_test_07',
        'Choose the correct question:',
        <String>[
          'Who is this teacher?',
          'Who are this teacher?',
          'What are this teacher?',
        ],
        'Who is this teacher?',
        'একজন ব্যক্তির জন্য Who is ব্যবহার হয়।',
      ),
      _test(
        'who_is_this_that_test_08',
        'ওই ব্যক্তি আমার বন্ধু।',
        <String>[
          'That person is my friend.',
          'Those person are my friend.',
          'That person are my friend.',
        ],
        'That person is my friend.',
        'একজন ব্যক্তির সঙ্গে is বসে।',
      ),
      _test(
        'who_is_this_that_test_09',
        'এই ছেলেটি আমার ছাত্র।',
        <String>[
          'This boy is my student.',
          'This boy are my student.',
          'These boy is my student.',
        ],
        'This boy is my student.',
        'This boy singular, তাই is হবে।',
      ),
      _test(
        'who_is_this_that_test_10',
        'Choose the correct question:',
        <String>[
          'Who is that woman?',
          'Who are that woman?',
          'What is that woman?',
        ],
        'Who is that woman?',
        'একজন মহিলার পরিচয় জানতে Who is ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'who_is_this_that_speaking_01',
        'একজন ব্যক্তিকে দেখে প্রশ্ন করুন।',
        'Who is this?',
        Icons.person_rounded,
        AppColors.primary,
      ),
      _speaking(
        'who_is_this_that_speaking_02',
        'দূরের একজন ব্যক্তিকে দেখে প্রশ্ন করুন।',
        'Who is that?',
        Icons.person_search_rounded,
        Colors.blue,
      ),
      _speaking(
        'who_is_this_that_speaking_03',
        'একজন ছেলেকে দেখে প্রশ্ন করুন।',
        'Who is this boy?',
        Icons.boy_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'who_is_this_that_speaking_04',
        'দূরের একজন মেয়েকে দেখে প্রশ্ন করুন।',
        'Who is that girl?',
        Icons.girl_rounded,
        Colors.pink,
      ),
      _speaking(
        'who_is_this_that_speaking_05',
        'একজন শিক্ষককে দেখে প্রশ্ন করুন।',
        'Who is this teacher?',
        Icons.school_rounded,
        Colors.orange,
      ),
    ],
  );

  static final RuleContent _whatIsThisThat = RuleContent(
    id: 'what_is_this_that',
    order: 17,
    title: 'What is this/that?',
    shortMeaning: 'কোনো বস্তু কী জানতে',
    usage:
    'কাছের বা দূরের কোনো অপরিচিত বস্তু কী, তা জানতে What is this? বা What is that? ব্যবহার হয়।',
    formula: 'What + is + this/that?',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.help_center_rounded,
    color: AppColors.blue,
    keywords: <String>['What', 'This', 'That', 'Object'],
    examples: <RuleExample>[
      _example('এটি কী?', 'What is this?', 'object_near'),
      _example('ওটি কী?', 'What is that?', 'object_far'),
      _example('এটি কী জিনিস?', 'What is this thing?', 'thing_near'),
      _example('ওটি কী গাড়ি?', 'What is that vehicle?', 'vehicle_far'),
      _example('এটি কী বই?', 'What is this book?', 'book_near'),
      _example('ওটি কী বাড়ি?', 'What is that house?', 'house_far'),
      _example('এটি কী ফোন?', 'What is this phone?', 'phone_near'),
      _example('ওটি কী গাছ?', 'What is that tree?', 'tree_far'),
      _example('এটি একটি কলম।', 'This is a pen.', 'pen'),
      _example('ওটি একটি গাড়ি।', 'That is a car.', 'car'),
      _example('এটি আমার ব্যাগ।', 'This is my bag.', 'bag'),
      _example('ওটি একটি স্কুল।', 'That is a school.', 'school'),
      _example('এটি একটি কম্পিউটার।', 'This is a computer.', 'computer'),
      _example('ওটি একটি হাসপাতাল।', 'That is a hospital.', 'hospital'),
      _example('এটি কী জিনিস?', 'What is this thing?', 'thing_question'),
    ],
    tests: <RuleTest>[
      _test(
        'what_is_this_that_test_01',
        '___ is this?',
        <String>['What', 'Who', 'Where'],
        'What',
        'বস্তু সম্পর্কে জানতে What ব্যবহার হয়।',
      ),
      _test(
        'what_is_this_that_test_02',
        '___ is that?',
        <String>['What', 'Who', 'When'],
        'What',
        'দূরের বস্তু সম্পর্কে জানতে What is that? বলা হয়।',
      ),
      _test(
        'what_is_this_that_test_03',
        'এটি কী?',
        <String>[
          'What is this?',
          'Who is this?',
          'Where is this?',
        ],
        'What is this?',
        'বস্তু সম্পর্কে প্রশ্ন, তাই What হবে।',
      ),
      _test(
        'what_is_this_that_test_04',
        'ওটি কী?',
        <String>[
          'What is that?',
          'Who is that?',
          'Where is that?',
        ],
        'What is that?',
        'দূরের বস্তুর জন্য What is that? হবে।',
      ),
      _test(
        'what_is_this_that_test_05',
        '___ is this book?',
        <String>['What', 'Who', 'How'],
        'What',
        'Book একটি বস্তু, তাই What হবে।',
      ),
      _test(
        'what_is_this_that_test_06',
        '___ is that vehicle?',
        <String>['What', 'Who', 'Where'],
        'What',
        'Vehicle একটি বস্তু, তাই What হবে।',
      ),
      _test(
        'what_is_this_that_test_07',
        'Choose the correct question:',
        <String>[
          'What is this phone?',
          'What are this phone?',
          'Who is this phone?',
        ],
        'What is this phone?',
        'Singular object-এর জন্য What is ব্যবহার হয়।',
      ),
      _test(
        'what_is_this_that_test_08',
        'এটি একটি কলম।',
        <String>[
          'This is a pen.',
          'This are a pen.',
          'That are a pen.',
        ],
        'This is a pen.',
        'একটি pen singular, তাই is হবে।',
      ),
      _test(
        'what_is_this_that_test_09',
        'ওটি একটি স্কুল।',
        <String>[
          'That is a school.',
          'That are a school.',
          'This are a school.',
        ],
        'That is a school.',
        'That-এর সঙ্গে is বসে।',
      ),
      _test(
        'what_is_this_that_test_10',
        'এটি কী জিনিস?',
        <String>[
          'What is this thing?',
          'Who is this thing?',
          'Where are this thing?',
        ],
        'What is this thing?',
        'কোনো জিনিস জানতে What ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'what_is_this_that_speaking_01',
        'কাছের একটি জিনিস দেখে প্রশ্ন করুন।',
        'What is this?',
        Icons.help_outline_rounded,
        AppColors.primary,
      ),
      _speaking(
        'what_is_this_that_speaking_02',
        'দূরের একটি জিনিস দেখে প্রশ্ন করুন।',
        'What is that?',
        Icons.search_rounded,
        Colors.blue,
      ),
      _speaking(
        'what_is_this_that_speaking_03',
        'একটি বই দেখে প্রশ্ন করুন।',
        'What is this book?',
        Icons.menu_book_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'what_is_this_that_speaking_04',
        'দূরের একটি বাড়ি দেখে প্রশ্ন করুন।',
        'What is that house?',
        Icons.home_rounded,
        Colors.orange,
      ),
      _speaking(
        'what_is_this_that_speaking_05',
        'একটি ফোন দেখে প্রশ্ন করুন।',
        'What is this phone?',
        Icons.phone_android_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _itIs = RuleContent(
    id: 'it_is',
    order: 18,
    title: 'It is & It’s',
    shortMeaning: 'বস্তু, সময়, আবহাওয়া ও পরিস্থিতি বোঝাতে',
    usage:
    'কোনো বস্তু, সময়, দিন, আবহাওয়া বা সাধারণ পরিস্থিতি বোঝাতে It is এবং সংক্ষিপ্তভাবে It’s ব্যবহার হয়।',
    formula: 'It is + information | It’s + information',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.info_rounded,
    color: AppColors.blue,
    keywords: <String>['It is', 'It’s', 'Object', 'Weather', 'Time'],
    examples: <RuleExample>[
      _example('এটি আমার ফোন।', 'It is my phone.', 'phone'),
      _example('এটি একটি বই।', 'It is a book.', 'book'),
      _example('আজ সোমবার।', 'It is Monday.', 'monday'),
      _example('এখন সকাল।', 'It is morning.', 'morning'),
      _example('আজ গরম।', 'It is hot today.', 'hot'),
      _example('আজ ঠান্ডা।', 'It is cold today.', 'cold'),
      _example('বৃষ্টি হচ্ছে।', 'It is raining.', 'rain'),
      _example('দেরি হয়ে গেছে।', 'It is late.', 'late'),
      _example('এটি সহজ।', 'It is easy.', 'easy'),
      _example('এটি কঠিন।', 'It is difficult.', 'difficult'),
      _example('এটি আমার নয়।', 'It is not mine.', 'not_mine'),
      _example('এটি সত্যি।', 'It is true.', 'true'),
      _example('এটি মজার।', 'It is funny.', 'funny'),
      _example('এখন রাত।', 'It is night.', 'night'),
      _example('এটি ভালো ধারণা।', 'It is a good idea.', 'idea'),
    ],
    tests: <RuleTest>[
      _test(
        'it_is_test_01',
        '___ is my phone.',
        <String>['It', 'They', 'He'],
        'It',
        'বস্তুর জন্য It ব্যবহার হয়।',
      ),
      _test(
        'it_is_test_02',
        '___ is Monday.',
        <String>['It', 'They', 'We'],
        'It',
        'দিন বা সময় বোঝাতে It ব্যবহার হয়।',
      ),
      _test(
        'it_is_test_03',
        '___ is hot today.',
        <String>['It', 'He', 'They'],
        'It',
        'আবহাওয়া বোঝাতে It ব্যবহার হয়।',
      ),
      _test(
        'it_is_test_04',
        'বৃষ্টি হচ্ছে।',
        <String>[
          'It is raining.',
          'He is raining.',
          'They are raining.',
        ],
        'It is raining.',
        'আবহাওয়ার জন্য It is ব্যবহার হয়।',
      ),
      _test(
        'it_is_test_05',
        'It is-এর short form কোনটি?',
        <String>['It’s', 'Its', 'Its’'],
        'It’s',
        'It is-এর contraction হলো It’s।',
      ),
      _test(
        'it_is_test_06',
        'Choose the correct sentence:',
        <String>[
          'It’s easy.',
          'Its easy.',
          'It are easy.',
        ],
        'It’s easy.',
        'It is-এর short form It’s।',
      ),
      _test(
        'it_is_test_07',
        'এখন রাত।',
        <String>[
          'It is night.',
          'They are night.',
          'He is night.',
        ],
        'It is night.',
        'সময় বা দিনের অংশ বোঝাতে It is ব্যবহার হয়।',
      ),
      _test(
        'it_is_test_08',
        'এটি আমার নয়।',
        <String>[
          'It is not mine.',
          'It are not mine.',
          'They is not mine.',
        ],
        'It is not mine.',
        'It-এর negative form হলো It is not।',
      ),
      _test(
        'it_is_test_09',
        'It ___ a good idea.',
        <String>['is', 'are', 'am'],
        'is',
        'It-এর সঙ্গে is বসে।',
      ),
      _test(
        'it_is_test_10',
        'দেরি হয়ে গেছে।',
        <String>[
          'It is late.',
          'He is late.',
          'They are late.',
        ],
        'It is late.',
        'সাধারণ পরিস্থিতি বোঝাতে It is ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'it_is_speaking_01',
        'বলুন: এটি আমার ফোন।',
        'It is my phone.',
        Icons.phone_android_rounded,
        AppColors.primary,
      ),
      _speaking(
        'it_is_speaking_02',
        'বলুন: আজ গরম।',
        'It is hot today.',
        Icons.wb_sunny_rounded,
        Colors.orange,
      ),
      _speaking(
        'it_is_speaking_03',
        'বলুন: বৃষ্টি হচ্ছে।',
        'It is raining.',
        Icons.umbrella_rounded,
        Colors.blue,
      ),
      _speaking(
        'it_is_speaking_04',
        'বলুন: এটি সহজ।',
        'It is easy.',
        Icons.check_circle_rounded,
        Colors.green,
      ),
      _speaking(
        'it_is_speaking_05',
        'বলুন: দেরি হয়ে গেছে।',
        'It is late.',
        Icons.schedule_rounded,
        Colors.deepPurple,
      ),
    ],
  );
}