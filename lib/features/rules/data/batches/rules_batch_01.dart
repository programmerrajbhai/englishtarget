import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch01Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _subjectPronouns,
    _amIsAre,
    _thisThat,
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

  static final RuleContent _subjectPronouns = RuleContent(
    id: 'subject_pronouns',
    order: 1,
    title: 'Subject Pronouns',
    shortMeaning: 'I, You, He, She, It, We, They',
    usage:
    'কে কাজ করছে বা কার সম্পর্কে বলা হচ্ছে তা বোঝাতে Subject Pronoun ব্যবহার হয়।',
    formula: 'Subject Pronoun + Verb + Object',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.people_alt_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'I',
      'You',
      'He',
      'She',
      'It',
      'We',
      'They',
    ],
    examples: <RuleExample>[
      _example('আমি একজন ছাত্র।', 'I am a student.', 'student'),
      _example('আমি ইংরেজি শিখি।', 'I learn English.', 'learning'),
      _example('তুমি আমার বন্ধু।', 'You are my friend.', 'friend'),
      _example(
        'তুমি ভালো English বলো।',
        'You speak English well.',
        'speaking',
        type: RuleExampleType.positive,
      ),
      _example('সে একজন ছেলে।', 'He is a boy.', 'boy'),
      _example(
        'সে প্রতিদিন কাজ করে।',
        'He works every day.',
        'work',
        type: RuleExampleType.positive,
      ),
      _example('সে একজন মেয়ে।', 'She is a girl.', 'girl'),
      _example(
        'সে সুন্দর গান গায়।',
        'She sings beautifully.',
        'singing',
        type: RuleExampleType.positive,
      ),
      _example('এটি আমার ফোন।', 'It is my phone.', 'phone'),
      _example(
        'এটি ভালো কাজ করে।',
        'It works well.',
        'device',
        type: RuleExampleType.positive,
      ),
      _example(
        'আমরা বাংলাদেশে থাকি।',
        'We live in Bangladesh.',
        'home',
        type: RuleExampleType.positive,
      ),
      _example(
        'আমরা একসঙ্গে English শিখি।',
        'We learn English together.',
        'learning_together',
        type: RuleExampleType.positive,
      ),
      _example('তারা আমার বন্ধু।', 'They are my friends.', 'friends'),
      _example(
        'তারা মাঠে খেলে।',
        'They play in the field.',
        'football',
        type: RuleExampleType.positive,
      ),
      _example(
        'আমরা প্রস্তুত, কিন্তু তারা প্রস্তুত নয়।',
        'We are ready, but they are not ready.',
        'ready',
        type: RuleExampleType.negative,
      ),
    ],
    tests: <RuleTest>[
      _test(
        'subject_pronouns_test_01',
        'Rahim is my brother. ___ is a student.',
        <String>['She', 'He', 'It'],
        'He',
        'Rahim ছেলে, তাই He ব্যবহার হবে।',
      ),
      _test(
        'subject_pronouns_test_02',
        'Mina is a teacher. ___ teaches English.',
        <String>['She', 'He', 'They'],
        'She',
        'Mina মেয়ে, তাই She ব্যবহার হবে।',
      ),
      _test(
        'subject_pronouns_test_03',
        'The phone is new. ___ works well.',
        <String>['He', 'It', 'We'],
        'It',
        'Phone একটি বস্তু, তাই It ব্যবহার হবে।',
      ),
      _test(
        'subject_pronouns_test_04',
        'Karim and I are friends. ___ study together.',
        <String>['We', 'They', 'He'],
        'We',
        'নিজেকে ও অন্যজনকে বোঝাতে We ব্যবহার হয়।',
      ),
      _test(
        'subject_pronouns_test_05',
        'Rina and Mina live here. ___ are sisters.',
        <String>['They', 'We', 'She'],
        'They',
        'একাধিক ব্যক্তির জন্য They ব্যবহার হয়।',
      ),
      _test(
        'subject_pronouns_test_06',
        'আমি English শিখি।',
        <String>[
          'He learns English.',
          'I learn English.',
          'They learn English.',
        ],
        'I learn English.',
        'আমি বোঝাতে I ব্যবহার হয়।',
      ),
      _test(
        'subject_pronouns_test_07',
        'Choose the correct sentence:',
        <String>[
          'We are ready.',
          'Are We ready.',
          'Ready We are.',
        ],
        'We are ready.',
        'সঠিক structure হলো Subject + Verb + Description।',
      ),
      _test(
        'subject_pronouns_test_08',
        'Choose the correct sentence:',
        <String>[
          'They play football.',
          'Play they football.',
          'Football they play.',
        ],
        'They play football.',
        'সঠিক structure হলো Subject + Verb + Object।',
      ),
      _test(
        'subject_pronouns_test_09',
        'Rina is my sister. ___ is kind.',
        <String>['He', 'She', 'It'],
        'She',
        'Rina মেয়ে, তাই She ব্যবহার হবে।',
      ),
      _test(
        'subject_pronouns_test_10',
        'আমার বইটি নতুন। এটি সুন্দর।',
        <String>[
          'My book is new. He is beautiful.',
          'My book is new. It is beautiful.',
          'My book is new. They are beautiful.',
        ],
        'My book is new. It is beautiful.',
        'Book একটি বস্তু, তাই It ব্যবহার হবে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'subject_pronouns_speaking_01',
        'বলুন: আমি একজন developer।',
        'I am a developer.',
        Icons.code_rounded,
        AppColors.primary,
      ),
      _speaking(
        'subject_pronouns_speaking_02',
        'বলুন: সে প্রতিদিন কাজ করে।',
        'He works every day.',
        Icons.work_rounded,
        Colors.blue,
      ),
      _speaking(
        'subject_pronouns_speaking_03',
        'বলুন: সে একজন ছাত্রী।',
        'She is a student.',
        Icons.school_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'subject_pronouns_speaking_04',
        'বলুন: তারা আমার বন্ধু।',
        'They are my friends.',
        Icons.groups_rounded,
        Colors.orange,
      ),
      _speaking(
        'subject_pronouns_speaking_05',
        'বলুন: আমরা একসঙ্গে English শিখি।',
        'We learn English together.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
    ],
  );

  static final RuleContent _amIsAre = RuleContent(
    id: 'am_is_are',
    order: 2,
    title: 'Am, Is & Are',
    shortMeaning: 'পরিচয়, অবস্থা ও অবস্থান বোঝাতে',
    usage:
    'বর্তমান সময়ে পরিচয়, অবস্থা, পেশা বা অবস্থান প্রকাশ করতে Am, Is এবং Are ব্যবহার হয়।',
    formula: 'I + am | He/She/It + is | You/We/They + are',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.merge_type_rounded,
    color: AppColors.primary,
    keywords: <String>['Am', 'Is', 'Are', 'Be Verb'],
    examples: <RuleExample>[
      _example('আমি একজন ছাত্র।', 'I am a student.', 'student'),
      _example('আমি খুশি।', 'I am happy.', 'happy'),
      _example('তুমি আমার বন্ধু।', 'You are my friend.', 'friend'),
      _example('তুমি প্রস্তুত।', 'You are ready.', 'ready'),
      _example('সে একজন ডাক্তার।', 'He is a doctor.', 'doctor'),
      _example('সে বাড়িতে আছে।', 'He is at home.', 'home'),
      _example('সে একজন শিক্ষক।', 'She is a teacher.', 'teacher'),
      _example('সে দয়ালু।', 'She is kind.', 'kind'),
      _example('এটি একটি বিড়াল।', 'It is a cat.', 'cat'),
      _example('এটি নতুন।', 'It is new.', 'new'),
      _example('আমরা শিক্ষার্থী।', 'We are learners.', 'learners'),
      _example('আমরা প্রস্তুত।', 'We are ready.', 'team_ready'),
      _example('তারা ব্যস্ত।', 'They are busy.', 'busy'),
      _example('তারা বন্ধু।', 'They are friends.', 'friends'),
      _example(
        'আমরা দেরি করিনি।',
        'We are not late.',
        'on_time',
        type: RuleExampleType.negative,
      ),
    ],
    tests: <RuleTest>[
      _test(
        'am_is_are_test_01',
        'I ___ a student.',
        <String>['am', 'is', 'are'],
        'am',
        'I-এর সঙ্গে am বসে।',
      ),
      _test(
        'am_is_are_test_02',
        'You ___ my friend.',
        <String>['am', 'is', 'are'],
        'are',
        'You-এর সঙ্গে are বসে।',
      ),
      _test(
        'am_is_are_test_03',
        'He ___ a doctor.',
        <String>['am', 'is', 'are'],
        'is',
        'He-এর সঙ্গে is বসে।',
      ),
      _test(
        'am_is_are_test_04',
        'She ___ happy.',
        <String>['am', 'is', 'are'],
        'is',
        'She-এর সঙ্গে is বসে।',
      ),
      _test(
        'am_is_are_test_05',
        'It ___ new.',
        <String>['am', 'is', 'are'],
        'is',
        'It-এর সঙ্গে is বসে।',
      ),
      _test(
        'am_is_are_test_06',
        'We ___ ready.',
        <String>['am', 'is', 'are'],
        'are',
        'We-এর সঙ্গে are বসে।',
      ),
      _test(
        'am_is_are_test_07',
        'They ___ busy.',
        <String>['am', 'is', 'are'],
        'are',
        'They-এর সঙ্গে are বসে।',
      ),
      _test(
        'am_is_are_test_08',
        'Choose the correct sentence:',
        <String>[
          'I is ready.',
          'I am ready.',
          'I are ready.',
        ],
        'I am ready.',
        'I-এর সঙ্গে am ব্যবহার হয়।',
      ),
      _test(
        'am_is_are_test_09',
        'Choose the correct sentence:',
        <String>[
          'They is friends.',
          'They am friends.',
          'They are friends.',
        ],
        'They are friends.',
        'They-এর সঙ্গে are ব্যবহার হয়।',
      ),
      _test(
        'am_is_are_test_10',
        'আমরা প্রস্তুত।',
        <String>[
          'We am ready.',
          'We is ready.',
          'We are ready.',
        ],
        'We are ready.',
        'We-এর সঙ্গে are ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'am_is_are_speaking_01',
        'বলুন: আমি একজন ছাত্র।',
        'I am a student.',
        Icons.school_rounded,
        AppColors.primary,
      ),
      _speaking(
        'am_is_are_speaking_02',
        'বলুন: তুমি আমার বন্ধু।',
        'You are my friend.',
        Icons.person_rounded,
        Colors.blue,
      ),
      _speaking(
        'am_is_are_speaking_03',
        'বলুন: সে একজন শিক্ষক।',
        'She is a teacher.',
        Icons.menu_book_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'am_is_are_speaking_04',
        'বলুন: আমরা প্রস্তুত।',
        'We are ready.',
        Icons.groups_rounded,
        Colors.orange,
      ),
      _speaking(
        'am_is_are_speaking_05',
        'বলুন: তারা ব্যস্ত।',
        'They are busy.',
        Icons.work_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _thisThat = RuleContent(
    id: 'this_that',
    order: 3,
    title: 'This & That',
    shortMeaning: 'কাছের ও দূরের একটি বস্তু বোঝাতে',
    usage:
    'কাছের একটি ব্যক্তি বা বস্তু বোঝাতে This এবং দূরের একটি ব্যক্তি বা বস্তু বোঝাতে That ব্যবহার হয়।',
    formula: 'This/That + is + singular noun',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.touch_app_rounded,
    color: AppColors.primary,
    keywords: <String>['This', 'That', 'Near', 'Far'],
    examples: <RuleExample>[
      _example('এটি আমার বই।', 'This is my book.', 'book_near'),
      _example('এটি একটি কলম।', 'This is a pen.', 'pen_near'),
      _example('এটি আমার ফোন।', 'This is my phone.', 'phone_near'),
      _example('এটি একটি কাপ।', 'This is a cup.', 'cup_near'),
      _example('ওটি একটি গাড়ি।', 'That is a car.', 'car_far'),
      _example('ওটি একটি বাড়ি।', 'That is a house.', 'house_far'),
      _example('ওটি আমার স্কুল।', 'That is my school.', 'school_far'),
      _example('ওটি একটি গাছ।', 'That is a tree.', 'tree_far'),
      _example('এটি একটি লাল বল।', 'This is a red ball.', 'ball_near'),
      _example('ওটি একটি বড় বাস।', 'That is a big bus.', 'bus_far'),
      _example('এটি আমার চেয়ার।', 'This is my chair.', 'chair_near'),
      _example('ওটি একটি সুন্দর ফুল।', 'That is a beautiful flower.', 'flower_far'),
      _example('এটি একটি কম্পিউটার।', 'This is a computer.', 'computer_near'),
      _example('ওটি একটি হাসপাতাল।', 'That is a hospital.', 'hospital_far'),
      _example(
        'এটি আমার ব্যাগ নয়।',
        'This is not my bag.',
        'bag_near',
        type: RuleExampleType.negative,
      ),
    ],
    tests: <RuleTest>[
      _test(
        'this_that_test_01',
        '___ is my book. (near)',
        <String>['This', 'That', 'They'],
        'This',
        'কাছের একটি জিনিসের জন্য This ব্যবহার হয়।',
      ),
      _test(
        'this_that_test_02',
        '___ is a car. (far)',
        <String>['This', 'That', 'These'],
        'That',
        'দূরের একটি জিনিসের জন্য That ব্যবহার হয়।',
      ),
      _test(
        'this_that_test_03',
        'Choose the correct sentence:',
        <String>[
          'This are my pen.',
          'This is my pen.',
          'This am my pen.',
        ],
        'This is my pen.',
        'This-এর সঙ্গে is বসে।',
      ),
      _test(
        'this_that_test_04',
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
        'this_that_test_05',
        'কাছের একটি ফোন বোঝাতে কোনটি হবে?',
        <String>[
          'This is a phone.',
          'That are a phone.',
          'Those is a phone.',
        ],
        'This is a phone.',
        'কাছের singular object-এর জন্য This ব্যবহার হয়।',
      ),
      _test(
        'this_that_test_06',
        'দূরের একটি বাড়ি বোঝাতে কোনটি হবে?',
        <String>[
          'This is a house.',
          'That is a house.',
          'These are a house.',
        ],
        'That is a house.',
        'দূরের singular object-এর জন্য That ব্যবহার হয়।',
      ),
      _test(
        'this_that_test_07',
        '___ is my chair. (near)',
        <String>['This', 'That', 'Those'],
        'This',
        'কাছের একটি chair-এর জন্য This হবে।',
      ),
      _test(
        'this_that_test_08',
        '___ is my school. (far)',
        <String>['This', 'That', 'These'],
        'That',
        'দূরের একটি school-এর জন্য That হবে।',
      ),
      _test(
        'this_that_test_09',
        'Choose the correct sentence:',
        <String>[
          'That is a red car.',
          'That are a red car.',
          'That am a red car.',
        ],
        'That is a red car.',
        'That + is + singular noun সঠিক structure।',
      ),
      _test(
        'this_that_test_10',
        'এটি আমার ব্যাগ নয়।',
        <String>[
          'This is not my bag.',
          'That are not my bag.',
          'This am not my bag.',
        ],
        'This is not my bag.',
        'Negative sentence-এ This-এর সঙ্গে is not বসে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'this_that_speaking_01',
        'কাছের একটি বই দেখে বলুন।',
        'This is my book.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'this_that_speaking_02',
        'দূরের একটি গাড়ি দেখে বলুন।',
        'That is a car.',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'this_that_speaking_03',
        'কাছের একটি ফোন দেখে বলুন।',
        'This is my phone.',
        Icons.phone_android_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'this_that_speaking_04',
        'দূরের একটি বাড়ি দেখে বলুন।',
        'That is a house.',
        Icons.home_rounded,
        Colors.orange,
      ),
      _speaking(
        'this_that_speaking_05',
        'কাছের একটি চেয়ার দেখে বলুন।',
        'This is my chair.',
        Icons.chair_rounded,
        Colors.green,
      ),
    ],
  );
}