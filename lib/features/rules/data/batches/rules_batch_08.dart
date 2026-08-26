import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch08Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _presentSimple,
    _doDoesQuestions,
    _doNotDoesNot,
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

  static final RuleContent _presentSimple = RuleContent(
    id: 'present_simple',
    order: 22,
    title: 'Present Simple',
    shortMeaning: 'অভ্যাস, নিয়মিত কাজ ও সাধারণ সত্য',
    usage:
        'নিয়মিত কাজ, অভ্যাস এবং সাধারণ সত্য প্রকাশ করতে Present Simple ব্যবহার হয়।',
    formula: 'Subject + base verb/verb-s + object',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.repeat_rounded,
    color: AppColors.purple,
    keywords: <String>[
      'Present Simple',
      'Habit',
      'Routine',
      'Fact',
    ],
    examples: <RuleExample>[
      _example('আমি প্রতিদিন কাজ করি।', 'I work every day.', 'work'),
      _example('তুমি সকালে ওঠো।', 'You wake up in the morning.', 'wake_up'),
      _example('সে English শেখে।', 'She learns English.', 'learn'),
      _example('সে অফিসে যায়।', 'He goes to the office.', 'office'),
      _example('আমরা একসঙ্গে খাই।', 'We eat together.', 'eat_together'),
      _example('তারা ফুটবল খেলে।', 'They play football.', 'football'),
      _example('সূর্য পূর্ব দিকে ওঠে।', 'The sun rises in the east.', 'sunrise'),
      _example('আমি চা পান করি।', 'I drink tea.', 'tea'),
      _example('সে প্রতিদিন বই পড়ে।', 'She reads a book every day.', 'read'),
      _example('সে বাসে যায়।', 'He goes by bus.', 'bus'),
      _example('আমরা English বলি।', 'We speak English.', 'speak'),
      _example('তারা এখানে থাকে।', 'They live here.', 'live'),
      _example(
        'পানি একশ ডিগ্রিতে ফুটে।',
        'Water boils at one hundred degrees.',
        'boil',
      ),
      _example(
        'আমার ভাই ক্রিকেট খেলে।',
        'My brother plays cricket.',
        'cricket',
      ),
      _example('সে রাতে ঘুমায়।', 'She sleeps at night.', 'sleep'),
    ],
    tests: <RuleTest>[
      _test(
        'present_simple_test_01',
        'I ___ every day.',
        <String>['work', 'works', 'working'],
        'work',
        'I-এর সঙ্গে base verb work হয়।',
      ),
      _test(
        'present_simple_test_02',
        'She ___ English.',
        <String>['learn', 'learns', 'learning'],
        'learns',
        'She-এর সঙ্গে verb-এ s যোগ হয়।',
      ),
      _test(
        'present_simple_test_03',
        'He ___ to the office.',
        <String>['go', 'goes', 'going'],
        'goes',
        'He-এর সঙ্গে goes হবে।',
      ),
      _test(
        'present_simple_test_04',
        'They ___ football.',
        <String>['play', 'plays', 'playing'],
        'play',
        'They-এর সঙ্গে base verb play হয়।',
      ),
      _test(
        'present_simple_test_05',
        'We ___ together.',
        <String>['eat', 'eats', 'eating'],
        'eat',
        'We-এর সঙ্গে eat হবে।',
      ),
      _test(
        'present_simple_test_06',
        'She ___ a book every day.',
        <String>['read', 'reads', 'reading'],
        'reads',
        'She-এর সঙ্গে reads হবে।',
      ),
      _test(
        'present_simple_test_07',
        'Choose the correct sentence:',
        <String>[
          'I drinks tea.',
          'I drink tea.',
          'I drinking tea.',
        ],
        'I drink tea.',
        'I-এর সঙ্গে drink হবে, drinks নয়।',
      ),
      _test(
        'present_simple_test_08',
        'সে বাসে যায়।',
        <String>[
          'He go by bus.',
          'He goes by bus.',
          'He going by bus.',
        ],
        'He goes by bus.',
        'He-এর সঙ্গে goes ব্যবহার হয়।',
      ),
      _test(
        'present_simple_test_09',
        'পানি ফুটে।',
        <String>[
          'Water boil.',
          'Water boils.',
          'Water boiling.',
        ],
        'Water boils.',
        'Water singular, তাই boils হবে।',
      ),
      _test(
        'present_simple_test_10',
        'সে রাতে ঘুমায়।',
        <String>[
          'She sleep at night.',
          'She sleeps at night.',
          'She sleeping at night.',
        ],
        'She sleeps at night.',
        'She-এর সঙ্গে sleeps হবে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'present_simple_speaking_01',
        'বলুন: আমি প্রতিদিন কাজ করি।',
        'I work every day.',
        Icons.work_rounded,
        AppColors.primary,
      ),
      _speaking(
        'present_simple_speaking_02',
        'বলুন: সে English শেখে।',
        'She learns English.',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'present_simple_speaking_03',
        'বলুন: সে অফিসে যায়।',
        'He goes to the office.',
        Icons.business_center_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'present_simple_speaking_04',
        'বলুন: আমরা একসঙ্গে খাই।',
        'We eat together.',
        Icons.restaurant_rounded,
        Colors.orange,
      ),
      _speaking(
        'present_simple_speaking_05',
        'বলুন: তারা ফুটবল খেলে।',
        'They play football.',
        Icons.sports_soccer_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _doDoesQuestions = RuleContent(
    id: 'do_does_questions',
    order: 23,
    title: 'Do & Does Questions',
    shortMeaning: 'বর্তমানের কাজ ও অভ্যাস সম্পর্কে প্রশ্ন',
    usage:
        'I, You, We, They-এর সঙ্গে Do এবং He, She, It-এর সঙ্গে Does ব্যবহার হয়।',
    formula: 'Do/Does + Subject + Base Verb?',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.question_answer_rounded,
    color: AppColors.purple,
    keywords: <String>[
      'Do',
      'Does',
      'Question',
      'Present',
    ],
    examples: <RuleExample>[
      _example('তুমি কি English বলো?', 'Do you speak English?', 'speak_question'),
      _example('তুমি কি বই পড়ো?', 'Do you read books?', 'read_question'),
      _example('তারা কি ফুটবল খেলে?', 'Do they play football?', 'football_question'),
      _example('আমরা কি এখন যাব?', 'Do we go now?', 'go_question'),
      _example('আমি কি সঠিক বলি?', 'Do I speak correctly?', 'correct_question'),
      _example('সে কি English শেখে?', 'Does she learn English?', 'learn_question'),
      _example('সে কি অফিসে যায়?', 'Does he go to the office?', 'office_question'),
      _example('এটি কি ভালো কাজ করে?', 'Does it work well?', 'device_question'),
      _example('তোমার ভাই কি ক্রিকেট খেলে?', 'Does your brother play cricket?', 'cricket_question'),
      _example('সে কি চা পান করে?', 'Does she drink tea?', 'tea_question'),
      _example('তারা কি এখানে থাকে?', 'Do they live here?', 'live_question'),
      _example('তুমি কি প্রতিদিন কাজ করো?', 'Do you work every day?', 'work_question'),
      _example('সে কি বই পড়ে?', 'Does he read books?', 'book_question'),
      _example('আমরা কি একসঙ্গে খাই?', 'Do we eat together?', 'eat_question'),
      _example('সে কি রাতে ঘুমায়?', 'Does she sleep at night?', 'sleep_question'),
    ],
    tests: <RuleTest>[
      _test(
        'do_does_questions_test_01',
        '___ you speak English?',
        <String>['Do', 'Does', 'Are'],
        'Do',
        'You-এর সঙ্গে Do বসে।',
      ),
      _test(
        'do_does_questions_test_02',
        '___ she learn English?',
        <String>['Do', 'Does', 'Is'],
        'Does',
        'She-এর সঙ্গে Does বসে।',
      ),
      _test(
        'do_does_questions_test_03',
        '___ they play football?',
        <String>['Do', 'Does', 'Are'],
        'Do',
        'They-এর সঙ্গে Do বসে।',
      ),
      _test(
        'do_does_questions_test_04',
        '___ he go to the office?',
        <String>['Do', 'Does', 'Is'],
        'Does',
        'He-এর সঙ্গে Does বসে।',
      ),
      _test(
        'do_does_questions_test_05',
        '___ we eat together?',
        <String>['Do', 'Does', 'Are'],
        'Do',
        'We-এর সঙ্গে Do বসে।',
      ),
      _test(
        'do_does_questions_test_06',
        '___ it work well?',
        <String>['Do', 'Does', 'Is'],
        'Does',
        'It-এর সঙ্গে Does বসে।',
      ),
      _test(
        'do_does_questions_test_07',
        'তুমি কি বই পড়ো?',
        <String>[
          'Do you read books?',
          'Does you read books?',
          'Are you read books?',
        ],
        'Do you read books?',
        'You-এর question-এ Do ব্যবহার হয়।',
      ),
      _test(
        'do_does_questions_test_08',
        'সে কি চা পান করে?',
        <String>[
          'Do she drink tea?',
          'Does she drink tea?',
          'Is she drink tea?',
        ],
        'Does she drink tea?',
        'Does-এর পরে base verb drink হয়।',
      ),
      _test(
        'do_does_questions_test_09',
        'তারা কি এখানে থাকে?',
        <String>[
          'Do they live here?',
          'Does they live here?',
          'Are they live here?',
        ],
        'Do they live here?',
        'They-এর সঙ্গে Do হয়।',
      ),
      _test(
        'do_does_questions_test_10',
        'সে কি বই পড়ে?',
        <String>[
          'Does he read books?',
          'Does he reads books?',
          'Do he read books?',
        ],
        'Does he read books?',
        'Does-এর পরে verb-এর base form read হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'do_does_questions_speaking_01',
        'প্রশ্ন করুন: তুমি কি English বলো?',
        'Do you speak English?',
        Icons.record_voice_over_rounded,
        AppColors.primary,
      ),
      _speaking(
        'do_does_questions_speaking_02',
        'প্রশ্ন করুন: সে কি English শেখে?',
        'Does she learn English?',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'do_does_questions_speaking_03',
        'প্রশ্ন করুন: তারা কি ফুটবল খেলে?',
        'Do they play football?',
        Icons.sports_soccer_rounded,
        Colors.orange,
      ),
      _speaking(
        'do_does_questions_speaking_04',
        'প্রশ্ন করুন: সে কি অফিসে যায়?',
        'Does he go to the office?',
        Icons.business_center_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'do_does_questions_speaking_05',
        'প্রশ্ন করুন: তুমি কি প্রতিদিন কাজ করো?',
        'Do you work every day?',
        Icons.work_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _doNotDoesNot = RuleContent(
    id: 'do_not_does_not',
    order: 24,
    title: 'Do not & Does not',
    shortMeaning: 'বর্তমানের negative sentence তৈরি করতে',
    usage:
        'বর্তমান সময়ে কোনো কাজ হয় না বোঝাতে Do not বা Does not ব্যবহার হয়।',
    formula: 'Subject + do/does not + Base Verb',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.block_rounded,
    color: AppColors.purple,
    keywords: <String>[
      'Do not',
      'Does not',
      'Negative',
      'Present',
    ],
    examples: <RuleExample>[
      _example('আমি চা পান করি না।', 'I do not drink tea.', 'not_tea'),
      _example('তুমি এখানে থাকো না।', 'You do not live here.', 'not_live'),
      _example('আমরা মিথ্যা বলি না।', 'We do not tell lies.', 'not_lie'),
      _example('তারা ফুটবল খেলে না।', 'They do not play football.', 'not_play'),
      _example('সে English শেখে না।', 'She does not learn English.', 'not_learn'),
      _example('সে অফিসে যায় না।', 'He does not go to the office.', 'not_office'),
      _example('এটি ভালো কাজ করে না।', 'It does not work well.', 'not_work'),
      _example('আমার ভাই ক্রিকেট খেলে না.', 'My brother does not play cricket.', 'not_cricket'),
      _example('আমি রাতে কাজ করি না।', 'I do not work at night.', 'not_night_work'),
      _example('তুমি বই পড়ো না।', 'You do not read books.', 'not_read'),
      _example('আমরা দেরি করি না।', 'We do not get late.', 'not_late'),
      _example('তারা এখানে আসে না।', 'They do not come here.', 'not_come'),
      _example('সে কফি পান করে না।', 'She does not drink coffee.', 'not_coffee'),
      _example('সে মিথ্যা বলে না।', 'He does not tell lies.', 'not_lies'),
      _example('আমি তাকে চিনি না।', 'I do not know him.', 'not_know'),
    ],
    tests: <RuleTest>[
      _test(
        'do_not_does_not_test_01',
        'I ___ drink tea.',
        <String>['do not', 'does not', 'am not'],
        'do not',
        'I-এর সঙ্গে do not হয়।',
      ),
      _test(
        'do_not_does_not_test_02',
        'She ___ learn English.',
        <String>['do not', 'does not', 'is not'],
        'does not',
        'She-এর সঙ্গে does not হয়।',
      ),
      _test(
        'do_not_does_not_test_03',
        'They ___ play football.',
        <String>['do not', 'does not', 'are not'],
        'do not',
        'They-এর সঙ্গে do not হয়।',
      ),
      _test(
        'do_not_does_not_test_04',
        'He ___ go to the office.',
        <String>['do not', 'does not', 'is not'],
        'does not',
        'He-এর সঙ্গে does not হয়।',
      ),
      _test(
        'do_not_does_not_test_05',
        'We ___ tell lies.',
        <String>['do not', 'does not', 'are not'],
        'do not',
        'We-এর সঙ্গে do not হয়।',
      ),
      _test(
        'do_not_does_not_test_06',
        'It ___ work well.',
        <String>['do not', 'does not', 'is not'],
        'does not',
        'It-এর সঙ্গে does not হয়।',
      ),
      _test(
        'do_not_does_not_test_07',
        'সে English শেখে না।',
        <String>[
          'She does not learn English.',
          'She do not learns English.',
          'She is not learn English.',
        ],
        'She does not learn English.',
        'Does not-এর পরে base verb learn হয়।',
      ),
      _test(
        'do_not_does_not_test_08',
        'আমি চা পান করি না।',
        <String>[
          'I does not drink tea.',
          'I do not drink tea.',
          'I am not drink tea.',
        ],
        'I do not drink tea.',
        'I-এর সঙ্গে do not ব্যবহার হয়।',
      ),
      _test(
        'do_not_does_not_test_09',
        'সে অফিসে যায় না।',
        <String>[
          'He does not go to the office.',
          'He does not goes to the office.',
          'He do not go to the office.',
        ],
        'He does not go to the office.',
        'Does not-এর পরে go হবে, goes নয়।',
      ),
      _test(
        'do_not_does_not_test_10',
        'তারা এখানে আসে না।',
        <String>[
          'They does not come here.',
          'They do not come here.',
          'They are not come here.',
        ],
        'They do not come here.',
        'They-এর সঙ্গে do not হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'do_not_does_not_speaking_01',
        'বলুন: আমি চা পান করি না।',
        'I do not drink tea.',
        Icons.local_cafe_rounded,
        AppColors.primary,
      ),
      _speaking(
        'do_not_does_not_speaking_02',
        'বলুন: সে English শেখে না।',
        'She does not learn English.',
        Icons.school_rounded,
        Colors.blue,
      ),
      _speaking(
        'do_not_does_not_speaking_03',
        'বলুন: তারা ফুটবল খেলে না।',
        'They do not play football.',
        Icons.sports_soccer_rounded,
        Colors.orange,
      ),
      _speaking(
        'do_not_does_not_speaking_04',
        'বলুন: সে অফিসে যায় না।',
        'He does not go to the office.',
        Icons.business_center_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'do_not_does_not_speaking_05',
        'বলুন: আমি তাকে চিনি না।',
        'I do not know him.',
        Icons.person_off_rounded,
        Colors.green,
      ),
    ],
  );
}