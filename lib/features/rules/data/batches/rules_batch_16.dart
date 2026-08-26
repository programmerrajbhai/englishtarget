import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch16Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _wouldLike,
    _haveToHasTo,
    _wantToNeedTo,
  ];

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

  static final RuleContent _wouldLike = RuleContent(
    id: 'would_like',
    order: 46,
    title: 'Would like',
    shortMeaning: 'ভদ্রভাবে কিছু চাইতে',
    usage:
    'ভদ্রভাবে কোনো কিছু চাওয়া বা কোনো কাজ করতে চাইলে Would like ব্যবহার হয়।',
    formula: 'Subject + would like + noun/to + verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.volunteer_activism_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Would like',
      'Polite',
      'Request',
      'Offer',
    ],
    examples: <RuleExample>[
      _example('আমি এক কাপ চা চাই।', 'I would like a cup of tea.', 'tea'),
      _example('আমি কিছু পানি চাই।', 'I would like some water.', 'water'),
      _example('আমি ভাত খেতে চাই।', 'I would like to eat rice.', 'eat'),
      _example('তুমি কি কফি চাইবে?', 'Would you like some coffee?', 'coffee'),
      _example('সে একটি নতুন ফোন চাইবে।', 'She would like a new phone.', 'phone'),
      _example('সে English শিখতে চাইবে।', 'He would like to learn English.', 'learn'),
      _example('আমরা বাইরে যেতে চাই।', 'We would like to go outside.', 'outside'),
      _example('তারা আপনার সঙ্গে দেখা করতে চাইবে।', 'They would like to meet you.', 'meet'),
      _example('আমি একটি প্রশ্ন করতে চাই।', 'I would like to ask a question.', 'question'),
      _example('আপনি কি কিছু খাবার চাইবেন?', 'Would you like some food?', 'food'),
      _example('আমি আপনাকে সাহায্য করতে চাই।', 'I would like to help you.', 'help'),
      _example('সে একটি টিকিট চাইবে।', 'She would like a ticket.', 'ticket'),
      _example('আমরা একটি টেবিল বুক করতে চাই।', 'We would like to book a table.', 'table'),
      _example('তুমি কি বসতে চাইবে?', 'Would you like to sit?', 'sit'),
      _example('আমি আরেক কাপ চা চাই।', 'I would like another cup of tea.', 'another_tea'),
    ],
    tests: <RuleTest>[
      _test(
        'would_like_test_01',
        'I ___ a cup of tea.',
        <String>['would like', 'would likes', 'would liking'],
        'would like',
        'ভদ্রভাবে কিছু চাইতে would like ব্যবহার হয়।',
      ),
      _test(
        'would_like_test_02',
        'I would like ___ rice.',
        <String>['to eat', 'eat', 'eating'],
        'to eat',
        'Would like-এর পরে কাজ হলে to + verb হয়।',
      ),
      _test(
        'would_like_test_03',
        '___ you like some coffee?',
        <String>['Would', 'Do', 'Are'],
        'Would',
        'ভদ্র offer বা question-এ Would you like...? হয়।',
      ),
      _test(
        'would_like_test_04',
        'She would like ___ new phone.',
        <String>['a', 'an', 'to'],
        'a',
        'Singular noun-এর আগে a বসে।',
      ),
      _test(
        'would_like_test_05',
        'He would like ___ English.',
        <String>['to learn', 'learns', 'learning'],
        'to learn',
        'Would like-এর পরে to learn হবে।',
      ),
      _test(
        'would_like_test_06',
        'We would like ___ outside.',
        <String>['to go', 'goes', 'going'],
        'to go',
        'Would like to + base verb ব্যবহার হয়।',
      ),
      _test(
        'would_like_test_07',
        'আমি এক কাপ চা চাই।',
        <String>[
          'I would like a cup of tea.',
          'I would likes a cup of tea.',
          'I would liking a cup of tea.',
        ],
        'I would like a cup of tea.',
        'Would like-এর পরে noun বসে।',
      ),
      _test(
        'would_like_test_08',
        'আমি একটি প্রশ্ন করতে চাই।',
        <String>[
          'I would like to ask a question.',
          'I would like ask a question.',
          'I would likes to ask a question.',
        ],
        'I would like to ask a question.',
        'Would like-এর পরে to + ask হবে।',
      ),
      _test(
        'would_like_test_09',
        'আপনি কি কিছু খাবার চাইবেন?',
        <String>[
          'Would you like some food?',
          'Do you would like some food?',
          'Would you likes some food?',
        ],
        'Would you like some food?',
        'ভদ্র offer-এর সঠিক structure এটি।',
      ),
      _test(
        'would_like_test_10',
        'আমরা একটি table book করতে চাই।',
        <String>[
          'We would like to book a table.',
          'We would like book a table.',
          'We would likes to book a table.',
        ],
        'We would like to book a table.',
        'Would like to + base verb ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'would_like_speaking_01',
        'ভদ্রভাবে বলুন: আমি এক কাপ চা চাই।',
        'I would like a cup of tea.',
        Icons.local_cafe_rounded,
        AppColors.primary,
      ),
      _speaking(
        'would_like_speaking_02',
        'বলুন: আমি ভাত খেতে চাই।',
        'I would like to eat rice.',
        Icons.restaurant_rounded,
        Colors.blue,
      ),
      _speaking(
        'would_like_speaking_03',
        'Offer করুন: আপনি কি কিছু কফি চাইবেন?',
        'Would you like some coffee?',
        Icons.coffee_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'would_like_speaking_04',
        'বলুন: আমি আপনাকে সাহায্য করতে চাই।',
        'I would like to help you.',
        Icons.volunteer_activism_rounded,
        Colors.orange,
      ),
      _speaking(
        'would_like_speaking_05',
        'বলুন: আমরা বাইরে যেতে চাই।',
        'We would like to go outside.',
        Icons.directions_walk_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _haveToHasTo = RuleContent(
    id: 'have_to_has_to',
    order: 47,
    title: 'Have to & Has to',
    shortMeaning: 'কোনো কাজ করতেই হবে বোঝাতে',
    usage:
    'নিয়ম, দায়িত্ব বা প্রয়োজনের কারণে কোনো কাজ করতেই হবে বোঝাতে Have to এবং Has to ব্যবহার হয়।',
    formula: 'I/You/We/They + have to | He/She/It + has to',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.assignment_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Have to',
      'Has to',
      'Duty',
      'Necessity',
    ],
    examples: <RuleExample>[
      _example('আমাকে প্রতিদিন কাজ করতে হয়।', 'I have to work every day.', 'work'),
      _example('তোমাকে সময়মতো আসতে হবে।', 'You have to come on time.', 'on_time'),
      _example('তাকে স্কুলে যেতে হয়।', 'He has to go to school.', 'school'),
      _example('তাকে রান্না করতে হয়।', 'She has to cook.', 'cook'),
      _example('আমাদের নিয়ম মেনে চলতে হয়।', 'We have to follow the rules.', 'rules'),
      _example('তাদের সকাল সকাল উঠতে হয়।', 'They have to wake up early.', 'wake_up'),
      _example('আমাকে আজ পড়তে হবে।', 'I have to study today.', 'study'),
      _example('তোমার form পূরণ করতে হবে।', 'You have to fill out the form.', 'form'),
      _example('তাকে ডাক্তার দেখাতে হবে।', 'He has to see a doctor.', 'doctor'),
      _example('তার English practice করতে হয়।', 'She has to practice English.', 'practice'),
      _example('আমাদের এখন যেতে হবে।', 'We have to go now.', 'go'),
      _example('তাদের helmet পরতে হবে।', 'They have to wear helmets.', 'helmet'),
      _example('আমাকে তাকে ফোন করতে হবে।', 'I have to call him.', 'call'),
      _example('তোমাকে মনোযোগ দিয়ে শুনতে হবে।', 'You have to listen carefully.', 'listen'),
      _example('তাকে আজ কাজ শেষ করতে হবে।', 'He has to finish the work today.', 'finish'),
    ],
    tests: <RuleTest>[
      _test(
        'have_to_has_to_test_01',
        'I ___ work every day.',
        <String>['have to', 'has to', 'having to'],
        'have to',
        'I-এর সঙ্গে have to হয়।',
      ),
      _test(
        'have_to_has_to_test_02',
        'You ___ come on time.',
        <String>['have to', 'has to', 'are to'],
        'have to',
        'You-এর সঙ্গে have to হয়।',
      ),
      _test(
        'have_to_has_to_test_03',
        'He ___ go to school.',
        <String>['have to', 'has to', 'is to'],
        'has to',
        'He-এর সঙ্গে has to হয়।',
      ),
      _test(
        'have_to_has_to_test_04',
        'She ___ cook.',
        <String>['have to', 'has to', 'is have to'],
        'has to',
        'She-এর সঙ্গে has to হয়।',
      ),
      _test(
        'have_to_has_to_test_05',
        'We ___ follow the rules.',
        <String>['have to', 'has to', 'having to'],
        'have to',
        'We-এর সঙ্গে have to হয়।',
      ),
      _test(
        'have_to_has_to_test_06',
        'They ___ wake up early.',
        <String>['have to', 'has to', 'are have to'],
        'have to',
        'They-এর সঙ্গে have to হয়।',
      ),
      _test(
        'have_to_has_to_test_07',
        'তাকে ডাক্তার দেখাতে হবে।',
        <String>[
          'He has to see a doctor.',
          'He have to see a doctor.',
          'He has to sees a doctor.',
        ],
        'He has to see a doctor.',
        'Has to-এর পরে base verb see হয়।',
      ),
      _test(
        'have_to_has_to_test_08',
        'আমাদের এখন যেতে হবে।',
        <String>[
          'We have to go now.',
          'We has to go now.',
          'We have to goes now.',
        ],
        'We have to go now.',
        'We-এর সঙ্গে have to হয়।',
      ),
      _test(
        'have_to_has_to_test_09',
        'তোমার form পূরণ করতে হবে।',
        <String>[
          'You have to fill out the form.',
          'You has to fill out the form.',
          'You have to filled out the form.',
        ],
        'You have to fill out the form.',
        'Have to-এর পরে base verb fill হয়।',
      ),
      _test(
        'have_to_has_to_test_10',
        'তাকে আজ কাজ শেষ করতে হবে।',
        <String>[
          'He has to finish the work today.',
          'He have to finish the work today.',
          'He has to finished the work today.',
        ],
        'He has to finish the work today.',
        'Has to-এর পরে finish-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'have_to_has_to_speaking_01',
        'বলুন: আমাকে প্রতিদিন কাজ করতে হয়।',
        'I have to work every day.',
        Icons.work_rounded,
        AppColors.primary,
      ),
      _speaking(
        'have_to_has_to_speaking_02',
        'বলুন: তাকে স্কুলে যেতে হয়।',
        'He has to go to school.',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'have_to_has_to_speaking_03',
        'বলুন: আমাদের নিয়ম মেনে চলতে হয়।',
        'We have to follow the rules.',
        Icons.rule_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'have_to_has_to_speaking_04',
        'বলুন: তাদের সকাল সকাল উঠতে হয়।',
        'They have to wake up early.',
        Icons.wb_sunny_rounded,
        Colors.orange,
      ),
      _speaking(
        'have_to_has_to_speaking_05',
        'বলুন: তাকে ডাক্তার দেখাতে হবে।',
        'He has to see a doctor.',
        Icons.local_hospital_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _wantToNeedTo = RuleContent(
    id: 'want_to_need_to',
    order: 48,
    title: 'Want to & Need to',
    shortMeaning: 'কিছু করতে ইচ্ছা বা প্রয়োজন বোঝাতে',
    usage:
    'কোনো কাজ করার ইচ্ছা বোঝাতে Want to এবং কোনো কাজ করা প্রয়োজন বোঝাতে Need to ব্যবহার হয়।',
    formula: 'Subject + want/need to + Base Verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.lightbulb_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Want to',
      'Need to',
      'Desire',
      'Necessity',
    ],
    examples: <RuleExample>[
      _example('আমি English শিখতে চাই।', 'I want to learn English.', 'learn'),
      _example('আমার এখন যেতে হবে।', 'I need to go now.', 'go'),
      _example('তুমি বাইরে যেতে চাও।', 'You want to go outside.', 'outside'),
      _example('তোমার বিশ্রাম নিতে হবে।', 'You need to take rest.', 'rest'),
      _example('সে ডাক্তার হতে চায়।', 'He wants to become a doctor.', 'doctor'),
      _example('তার পড়াশোনা করতে হবে।', 'She needs to study.', 'study'),
      _example('আমরা নতুন কিছু শিখতে চাই।', 'We want to learn something new.', 'learning'),
      _example('আমাদের আরও practice করতে হবে।', 'We need to practice more.', 'practice'),
      _example('তারা ভ্রমণ করতে চায়।', 'They want to travel.', 'travel'),
      _example('তাদের এখন কাজ করতে হবে।', 'They need to work now.', 'work'),
      _example('আমি তোমার সঙ্গে কথা বলতে চাই।', 'I want to talk to you.', 'talk'),
      _example('আমার পানি পান করতে হবে।', 'I need to drink water.', 'water'),
      _example('সে একটি নতুন ফোন কিনতে চায়।', 'He wants to buy a new phone.', 'phone'),
      _example('তাকে আজ form জমা দিতে হবে।', 'She needs to submit the form today.', 'form'),
      _example('আমরা সময়মতো পৌঁছাতে চাই।', 'We want to arrive on time.', 'on_time'),
    ],
    tests: <RuleTest>[
      _test(
        'want_to_need_to_test_01',
        'I ___ to learn English.',
        <String>['want', 'wants', 'wanting'],
        'want',
        'I-এর সঙ্গে want to হয়।',
      ),
      _test(
        'want_to_need_to_test_02',
        'I ___ to go now.',
        <String>['need', 'needs', 'needing'],
        'need',
        'I-এর সঙ্গে need to হয়।',
      ),
      _test(
        'want_to_need_to_test_03',
        'He ___ to become a doctor.',
        <String>['want', 'wants', 'wanting'],
        'wants',
        'He-এর সঙ্গে wants to হয়।',
      ),
      _test(
        'want_to_need_to_test_04',
        'She ___ to study.',
        <String>['need', 'needs', 'needing'],
        'needs',
        'She-এর সঙ্গে needs to হয়।',
      ),
      _test(
        'want_to_need_to_test_05',
        'We ___ to learn something new.',
        <String>['want', 'wants', 'wanting'],
        'want',
        'We-এর সঙ্গে want to হয়।',
      ),
      _test(
        'want_to_need_to_test_06',
        'They ___ to work now.',
        <String>['need', 'needs', 'needing'],
        'need',
        'They-এর সঙ্গে need to হয়।',
      ),
      _test(
        'want_to_need_to_test_07',
        'আমি English শিখতে চাই।',
        <String>[
          'I want to learn English.',
          'I wants to learn English.',
          'I want learn English.',
        ],
        'I want to learn English.',
        'Want to-এর পরে base verb learn হয়।',
      ),
      _test(
        'want_to_need_to_test_08',
        'তার পড়াশোনা করতে হবে।',
        <String>[
          'She needs to study.',
          'She need to study.',
          'She needs study.',
        ],
        'She needs to study.',
        'She-এর সঙ্গে needs to হয়।',
      ),
      _test(
        'want_to_need_to_test_09',
        'সে একটি নতুন ফোন কিনতে চায়।',
        <String>[
          'He wants to buy a new phone.',
          'He want to buy a new phone.',
          'He wants buy a new phone.',
        ],
        'He wants to buy a new phone.',
        'He-এর সঙ্গে wants to হয়।',
      ),
      _test(
        'want_to_need_to_test_10',
        'তাকে আজ form জমা দিতে হবে।',
        <String>[
          'She needs to submit the form today.',
          'She need to submits the form today.',
          'She needs submit the form today.',
        ],
        'She needs to submit the form today.',
        'Needs to-এর পরে submit-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'want_to_need_to_speaking_01',
        'বলুন: আমি English শিখতে চাই।',
        'I want to learn English.',
        Icons.school_rounded,
        AppColors.primary,
      ),
      _speaking(
        'want_to_need_to_speaking_02',
        'বলুন: আমার এখন যেতে হবে।',
        'I need to go now.',
        Icons.arrow_forward_rounded,
        Colors.blue,
      ),
      _speaking(
        'want_to_need_to_speaking_03',
        'বলুন: সে ডাক্তার হতে চায়।',
        'He wants to become a doctor.',
        Icons.local_hospital_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'want_to_need_to_speaking_04',
        'বলুন: আমাদের আরও practice করতে হবে।',
        'We need to practice more.',
        Icons.replay_rounded,
        Colors.orange,
      ),
      _speaking(
        'want_to_need_to_speaking_05',
        'বলুন: তারা ভ্রমণ করতে চায়।',
        'They want to travel.',
        Icons.flight_takeoff_rounded,
        Colors.green,
      ),
    ],
  );
}