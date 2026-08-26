import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch09Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _presentContinuous,
    _amIsAreQuestions,
    _simpleVsContinuous,
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

  static final RuleContent _presentContinuous = RuleContent(
    id: 'present_continuous',
    order: 25,
    title: 'Present Continuous',
    shortMeaning: 'এখন কোনো কাজ চলছে বোঝাতে',
    usage:
    'কথা বলার সময় কোনো কাজ চলমান থাকলে Present Continuous ব্যবহার হয়।',
    formula: 'Subject + am/is/are + Verb-ing',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.play_circle_rounded,
    color: AppColors.purple,
    keywords: <String>['Present Continuous', 'Now', 'Verb-ing'],
    examples: <RuleExample>[
      _example('আমি এখন কাজ করছি।', 'I am working now.', 'working'),
      _example('তুমি English শিখছো।', 'You are learning English.', 'learning'),
      _example('সে বই পড়ছে।', 'She is reading a book.', 'reading'),
      _example('সে ফুটবল খেলছে।', 'He is playing football.', 'playing'),
      _example('আমরা একসঙ্গে খাচ্ছি।', 'We are eating together.', 'eating'),
      _example('তারা গান শুনছে।', 'They are listening to music.', 'listening'),
      _example('বৃষ্টি হচ্ছে।', 'It is raining.', 'raining'),
      _example('আমি একটি চিঠি লিখছি।', 'I am writing a letter.', 'writing'),
      _example('সে রান্না করছে।', 'She is cooking.', 'cooking'),
      _example('সে গাড়ি চালাচ্ছে।', 'He is driving a car.', 'driving'),
      _example('তুমি কি আমাকে শুনছো?', 'You are listening to me.', 'hearing'),
      _example('আমরা TV দেখছি।', 'We are watching TV.', 'watching'),
      _example('তারা মাঠে খেলছে।', 'They are playing in the field.', 'field_play'),
      _example('শিশুটি ঘুমাচ্ছে।', 'The baby is sleeping.', 'sleeping'),
      _example('আমি English বলার practice করছি।', 'I am practicing English.', 'practice'),
    ],
    tests: <RuleTest>[
      _test('present_continuous_test_01', 'I ___ working now.', <String>['am', 'is', 'are'], 'am', 'I-এর সঙ্গে am বসে।'),
      _test('present_continuous_test_02', 'She ___ reading a book.', <String>['am', 'is', 'are'], 'is', 'She-এর সঙ্গে is বসে।'),
      _test('present_continuous_test_03', 'They ___ playing football.', <String>['am', 'is', 'are'], 'are', 'They-এর সঙ্গে are বসে।'),
      _test('present_continuous_test_04', 'We ___ eating together.', <String>['am', 'is', 'are'], 'are', 'We-এর সঙ্গে are বসে।'),
      _test('present_continuous_test_05', 'It ___ raining.', <String>['am', 'is', 'are'], 'is', 'It-এর সঙ্গে is বসে।'),
      _test('present_continuous_test_06', 'He is ___ a car.', <String>['drive', 'drives', 'driving'], 'driving', 'Is-এর পরে verb-ing হয়।'),
      _test('present_continuous_test_07', 'আমি এখন কাজ করছি।', <String>['I am working now.', 'I is working now.', 'I work now.'], 'I am working now.', 'এখন চলছে, তাই Present Continuous।'),
      _test('present_continuous_test_08', 'বৃষ্টি হচ্ছে।', <String>['It is raining.', 'It are raining.', 'It rains now.'], 'It is raining.', 'চলমান আবহাওয়ার জন্য is raining।'),
      _test('present_continuous_test_09', 'সে বই পড়ছে।', <String>['She is reading a book.', 'She is read a book.', 'She are reading a book.'], 'She is reading a book.', 'She + is + reading সঠিক।'),
      _test('present_continuous_test_10', 'তারা গান শুনছে।', <String>['They are listening to music.', 'They is listening to music.', 'They listen music now.'], 'They are listening to music.', 'They-এর সঙ্গে are + verb-ing হয়।'),
    ],
    speakingTests: <SpeakingTest>[
      _speaking('present_continuous_speaking_01', 'বলুন: আমি এখন কাজ করছি।', 'I am working now.', Icons.work_rounded, AppColors.primary),
      _speaking('present_continuous_speaking_02', 'বলুন: সে বই পড়ছে।', 'She is reading a book.', Icons.menu_book_rounded, Colors.blue),
      _speaking('present_continuous_speaking_03', 'বলুন: সে ফুটবল খেলছে।', 'He is playing football.', Icons.sports_soccer_rounded, Colors.orange),
      _speaking('present_continuous_speaking_04', 'বলুন: আমরা একসঙ্গে খাচ্ছি।', 'We are eating together.', Icons.restaurant_rounded, Colors.deepPurple),
      _speaking('present_continuous_speaking_05', 'বলুন: বৃষ্টি হচ্ছে।', 'It is raining.', Icons.umbrella_rounded, Colors.green),
    ],
  );

  static final RuleContent _amIsAreQuestions = RuleContent(
    id: 'am_is_are_questions',
    order: 26,
    title: 'Am/Is/Are Questions',
    shortMeaning: 'অবস্থা বা চলমান কাজ সম্পর্কে প্রশ্ন',
    usage:
    'Be verb sentence এবং Present Continuous-এর Yes/No question তৈরি করতে ব্যবহার হয়।',
    formula: 'Am/Is/Are + Subject + Information?',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.live_help_rounded,
    color: AppColors.purple,
    keywords: <String>['Am', 'Is', 'Are', 'Question', 'Continuous'],
    examples: <RuleExample>[
      _example('আমি কি সঠিক?', 'Am I right?', 'right_question'),
      _example('আমি কি দেরি করেছি?', 'Am I late?', 'late_question'),
      _example('তুমি কি প্রস্তুত?', 'Are you ready?', 'ready_question'),
      _example('তুমি কি English শিখছো?', 'Are you learning English?', 'learn_question'),
      _example('সে কি ব্যস্ত?', 'Is he busy?', 'busy_question'),
      _example('সে কি কাজ করছে?', 'Is she working?', 'work_question'),
      _example('এটি কি নতুন?', 'Is it new?', 'new_question'),
      _example('আমরা কি ঠিক আছি?', 'Are we okay?', 'okay_question'),
      _example('আমরা কি যাচ্ছি?', 'Are we going?', 'go_question'),
      _example('তারা কি প্রস্তুত?', 'Are they ready?', 'ready_group_question'),
      _example('তারা কি খেলছে?', 'Are they playing?', 'play_question'),
      _example('সে কি ঘুমাচ্ছে?', 'Is he sleeping?', 'sleep_question'),
      _example('তুমি কি আমাকে শুনছো?', 'Are you listening to me?', 'listen_question'),
      _example('বৃষ্টি কি হচ্ছে?', 'Is it raining?', 'rain_question'),
      _example('আমি কি ভালো করছি?', 'Am I doing well?', 'doing_well'),
    ],
    tests: <RuleTest>[
      _test('am_is_are_questions_test_01', '___ I right?', <String>['Am', 'Is', 'Are'], 'Am', 'I-এর question-এ Am বসে।'),
      _test('am_is_are_questions_test_02', '___ you ready?', <String>['Am', 'Is', 'Are'], 'Are', 'You-এর সঙ্গে Are বসে।'),
      _test('am_is_are_questions_test_03', '___ he busy?', <String>['Am', 'Is', 'Are'], 'Is', 'He-এর সঙ্গে Is বসে।'),
      _test('am_is_are_questions_test_04', '___ she working?', <String>['Am', 'Is', 'Are'], 'Is', 'She-এর সঙ্গে Is বসে।'),
      _test('am_is_are_questions_test_05', '___ we going?', <String>['Am', 'Is', 'Are'], 'Are', 'We-এর সঙ্গে Are বসে।'),
      _test('am_is_are_questions_test_06', '___ they playing?', <String>['Am', 'Is', 'Are'], 'Are', 'They-এর সঙ্গে Are বসে।'),
      _test('am_is_are_questions_test_07', 'তুমি কি English শিখছো?', <String>['Are you learning English?', 'Is you learning English?', 'Do you learning English?'], 'Are you learning English?', 'Present Continuous question-এ Are + you + verb-ing হয়।'),
      _test('am_is_are_questions_test_08', 'সে কি ঘুমাচ্ছে?', <String>['Is he sleeping?', 'Are he sleeping?', 'Does he sleeping?'], 'Is he sleeping?', 'He-এর সঙ্গে Is বসে।'),
      _test('am_is_are_questions_test_09', 'বৃষ্টি কি হচ্ছে?', <String>['Is it raining?', 'Are it raining?', 'Does it raining?'], 'Is it raining?', 'It-এর সঙ্গে Is বসে।'),
      _test('am_is_are_questions_test_10', 'আমি কি ভালো করছি?', <String>['Am I doing well?', 'Is I doing well?', 'Do I doing well?'], 'Am I doing well?', 'I-এর সঙ্গে Am বসে।'),
    ],
    speakingTests: <SpeakingTest>[
      _speaking('am_is_are_questions_speaking_01', 'প্রশ্ন করুন: তুমি কি প্রস্তুত?', 'Are you ready?', Icons.check_circle_rounded, AppColors.primary),
      _speaking('am_is_are_questions_speaking_02', 'প্রশ্ন করুন: সে কি ব্যস্ত?', 'Is he busy?', Icons.person_rounded, Colors.blue),
      _speaking('am_is_are_questions_speaking_03', 'প্রশ্ন করুন: সে কি কাজ করছে?', 'Is she working?', Icons.work_rounded, Colors.deepPurple),
      _speaking('am_is_are_questions_speaking_04', 'প্রশ্ন করুন: তারা কি খেলছে?', 'Are they playing?', Icons.sports_soccer_rounded, Colors.orange),
      _speaking('am_is_are_questions_speaking_05', 'প্রশ্ন করুন: বৃষ্টি কি হচ্ছে?', 'Is it raining?', Icons.umbrella_rounded, Colors.green),
    ],
  );

  static final RuleContent _simpleVsContinuous = RuleContent(
    id: 'present_simple_vs_continuous',
    order: 27,
    title: 'Simple vs Continuous',
    shortMeaning: 'নিয়মিত কাজ ও এখনকার কাজের পার্থক্য',
    usage:
    'Present Simple নিয়মিত কাজ এবং Present Continuous এখন চলমান কাজ বোঝায়।',
    formula: 'I work every day / I am working now',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.compare_arrows_rounded,
    color: AppColors.purple,
    keywords: <String>['Simple', 'Continuous', 'Routine', 'Now'],
    examples: <RuleExample>[
      _example('আমি প্রতিদিন কাজ করি।', 'I work every day.', 'routine_work'),
      _example('আমি এখন কাজ করছি।', 'I am working now.', 'now_work'),
      _example('সে প্রতিদিন বই পড়ে।', 'She reads books every day.', 'routine_read'),
      _example('সে এখন বই পড়ছে।', 'She is reading a book now.', 'now_read'),
      _example('সে প্রতি শুক্রবার ফুটবল খেলে।', 'He plays football every Friday.', 'routine_play'),
      _example('সে এখন ফুটবল খেলছে।', 'He is playing football now.', 'now_play'),
      _example('আমরা সকালে চা পান করি।', 'We drink tea in the morning.', 'routine_tea'),
      _example('আমরা এখন চা পান করছি।', 'We are drinking tea now.', 'now_tea'),
      _example('তারা এখানে থাকে।', 'They live here.', 'routine_live'),
      _example('তারা এখন এখানে বসে আছে।', 'They are sitting here now.', 'now_sit'),
      _example('আমি English শিখি।', 'I learn English.', 'routine_learn'),
      _example('আমি এখন English শিখছি।', 'I am learning English now.', 'now_learn'),
      _example('সে প্রতিদিন রান্না করে।', 'She cooks every day.', 'routine_cook'),
      _example('সে এখন রান্না করছে।', 'She is cooking now.', 'now_cook'),
      _example('বৃষ্টি সাধারণত জুনে হয়।', 'It usually rains in June.', 'usual_rain'),
    ],
    tests: <RuleTest>[
      _test('present_simple_vs_continuous_test_01', 'I ___ every day.', <String>['work', 'am working', 'working'], 'work', 'Every day নিয়মিত কাজ বোঝায়।'),
      _test('present_simple_vs_continuous_test_02', 'I ___ now.', <String>['work', 'am working', 'works'], 'am working', 'Now চলমান কাজ বোঝায়।'),
      _test('present_simple_vs_continuous_test_03', 'She ___ books every day.', <String>['reads', 'is reading', 'read now'], 'reads', 'Every day-এর সঙ্গে Present Simple হয়।'),
      _test('present_simple_vs_continuous_test_04', 'She ___ a book now.', <String>['reads', 'is reading', 'read'], 'is reading', 'Now-এর সঙ্গে Present Continuous হয়।'),
      _test('present_simple_vs_continuous_test_05', 'He ___ football every Friday.', <String>['plays', 'is playing', 'play now'], 'plays', 'নিয়মিত কাজের জন্য plays হবে।'),
      _test('present_simple_vs_continuous_test_06', 'He ___ football now.', <String>['plays', 'is playing', 'play'], 'is playing', 'এখন চলছে, তাই is playing।'),
      _test('present_simple_vs_continuous_test_07', 'আমি এখন English শিখছি।', <String>['I learn English.', 'I am learning English now.', 'I learns English.'], 'I am learning English now.', 'Now থাকলে am learning হবে।'),
      _test('present_simple_vs_continuous_test_08', 'সে প্রতিদিন রান্না করে।', <String>['She cooks every day.', 'She is cooking every day now.', 'She cook every day.'], 'She cooks every day.', 'প্রতিদিনের অভ্যাসে cooks হবে।'),
      _test('present_simple_vs_continuous_test_09', 'আমরা এখন চা পান করছি।', <String>['We drink tea.', 'We are drinking tea now.', 'We drinks tea.'], 'We are drinking tea now.', 'Now-এর জন্য are drinking হবে।'),
      _test('present_simple_vs_continuous_test_10', 'তারা এখানে থাকে।', <String>['They live here.', 'They are living here now.', 'They lives here.'], 'They live here.', 'সাধারণ সত্য বা স্থায়ী অবস্থায় Present Simple হয়।'),
    ],
    speakingTests: <SpeakingTest>[
      _speaking('present_simple_vs_continuous_speaking_01', 'বলুন: আমি প্রতিদিন কাজ করি।', 'I work every day.', Icons.work_rounded, AppColors.primary),
      _speaking('present_simple_vs_continuous_speaking_02', 'বলুন: আমি এখন কাজ করছি।', 'I am working now.', Icons.play_circle_rounded, Colors.blue),
      _speaking('present_simple_vs_continuous_speaking_03', 'বলুন: সে প্রতিদিন বই পড়ে।', 'She reads books every day.', Icons.menu_book_rounded, Colors.deepPurple),
      _speaking('present_simple_vs_continuous_speaking_04', 'বলুন: সে এখন বই পড়ছে।', 'She is reading a book now.', Icons.book_rounded, Colors.orange),
      _speaking('present_simple_vs_continuous_speaking_05', 'বলুন: তারা এখন এখানে বসে আছে।', 'They are sitting here now.', Icons.groups_rounded, Colors.green),
    ],
  );
}