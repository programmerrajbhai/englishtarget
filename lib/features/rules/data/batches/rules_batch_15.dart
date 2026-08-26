import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch15Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _shouldShouldNot,
    _mustMustNot,
    _mayMight,
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

  static final RuleContent _shouldShouldNot = RuleContent(
    id: 'should_should_not',
    order: 43,
    title: 'Should & Should not',
    shortMeaning: 'পরামর্শ ও উচিত নয় বোঝাতে',
    usage:
    'কাউকে পরামর্শ দেওয়া বা কোনো কাজ করা উচিত নয় বোঝাতে Should এবং Should not ব্যবহার হয়।',
    formula: 'Subject + should/should not + Base Verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.recommend_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Should',
      'Should not',
      'Advice',
      'Suggestion',
    ],
    examples: <RuleExample>[
      _example('তোমার প্রতিদিন পড়া উচিত।', 'You should study every day.', 'study'),
      _example('তোমার বেশি পানি পান করা উচিত।', 'You should drink more water.', 'water'),
      _example('তোমার সময়মতো ঘুমানো উচিত।', 'You should sleep on time.', 'sleep'),
      _example('আমাদের নিয়মিত English practice করা উচিত।', 'We should practice English regularly.', 'practice'),
      _example('তার ডাক্তারের কাছে যাওয়া উচিত।', 'He should see a doctor.', 'doctor'),
      _example('তোমার সত্য বলা উচিত।', 'You should tell the truth.', 'truth'),
      _example('তোমার এত দেরি করা উচিত নয়।', 'You should not be so late.', 'late'),
      _example('তোমার বেশি ফাস্টফুড খাওয়া উচিত নয়।', 'You should not eat too much fast food.', 'fast_food'),
      _example('তার মিথ্যা বলা উচিত নয়।', 'She should not tell lies.', 'lie'),
      _example('আমাদের সময় নষ্ট করা উচিত নয়।', 'We should not waste time.', 'time'),
      _example('তাদের রাস্তা পার হওয়ার সময় সতর্ক থাকা উচিত।', 'They should be careful when crossing the road.', 'road'),
      _example('তোমার এই বইটি পড়া উচিত।', 'You should read this book.', 'book'),
      _example('আমার কি এখন যাওয়া উচিত?', 'Should I go now?', 'go_question'),
      _example('আমাদের কি তাকে সাহায্য করা উচিত?', 'Should we help him?', 'help_question'),
      _example('তোমার কি তাকে ফোন করা উচিত?', 'Should you call her?', 'call_question'),
    ],
    tests: <RuleTest>[
      _test(
        'should_should_not_test_01',
        'You ___ study every day.',
        <String>['should', 'shoulds', 'are should'],
        'should',
        'পরামর্শ দিতে should ব্যবহার হয়।',
      ),
      _test(
        'should_should_not_test_02',
        'You ___ drink more water.',
        <String>['should', 'shoulds', 'are'],
        'should',
        'Should-এর পরে base verb drink হয়।',
      ),
      _test(
        'should_should_not_test_03',
        'He ___ see a doctor.',
        <String>['should', 'shoulds', 'is'],
        'should',
        'He-এর সঙ্গেও should একই থাকে।',
      ),
      _test(
        'should_should_not_test_04',
        'You ___ be so late.',
        <String>['should not', 'shoulds not', 'are not should'],
        'should not',
        'উচিত নয় বোঝাতে should not হয়।',
      ),
      _test(
        'should_should_not_test_05',
        'She ___ tell lies.',
        <String>['should not', 'shoulds not', 'is not should'],
        'should not',
        'Should not-এর পরে base verb tell হয়।',
      ),
      _test(
        'should_should_not_test_06',
        'Should-এর পরে কোন verb form হয়?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Base Verb',
        'Should-এর পরে base verb বসে।',
      ),
      _test(
        'should_should_not_test_07',
        'তোমার প্রতিদিন পড়া উচিত।',
        <String>[
          'You should study every day.',
          'You should studies every day.',
          'You should studying every day.',
        ],
        'You should study every day.',
        'Should-এর পরে study-এর base form হয়।',
      ),
      _test(
        'should_should_not_test_08',
        'আমাদের সময় নষ্ট করা উচিত নয়।',
        <String>[
          'We should not waste time.',
          'We should not wasted time.',
          'We should not wasting time.',
        ],
        'We should not waste time.',
        'Should not-এর পরে waste হবে।',
      ),
      _test(
        'should_should_not_test_09',
        'আমার কি এখন যাওয়া উচিত?',
        <String>[
          'Should I go now?',
          'Should I goes now?',
          'Do I should go now?',
        ],
        'Should I go now?',
        'Question-এ Should প্রথমে বসে।',
      ),
      _test(
        'should_should_not_test_10',
        'তোমার কি তাকে ফোন করা উচিত?',
        <String>[
          'Should you call her?',
          'Should you calls her?',
          'Do you should call her?',
        ],
        'Should you call her?',
        'Should-এর পরে call-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'should_should_not_speaking_01',
        'বলুন: তোমার প্রতিদিন পড়া উচিত।',
        'You should study every day.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'should_should_not_speaking_02',
        'বলুন: তোমার বেশি পানি পান করা উচিত।',
        'You should drink more water.',
        Icons.water_drop_rounded,
        Colors.blue,
      ),
      _speaking(
        'should_should_not_speaking_03',
        'বলুন: তার ডাক্তারের কাছে যাওয়া উচিত।',
        'He should see a doctor.',
        Icons.local_hospital_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'should_should_not_speaking_04',
        'বলুন: তোমার এত দেরি করা উচিত নয়।',
        'You should not be so late.',
        Icons.schedule_rounded,
        Colors.orange,
      ),
      _speaking(
        'should_should_not_speaking_05',
        'প্রশ্ন করুন: আমার কি এখন যাওয়া উচিত?',
        'Should I go now?',
        Icons.arrow_forward_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _mustMustNot = RuleContent(
    id: 'must_must_not',
    order: 44,
    title: 'Must & Must not',
    shortMeaning: 'অবশ্যই করা এবং কঠোরভাবে নিষেধ বোঝাতে',
    usage:
    'কোনো কাজ অবশ্যই করতে হবে বা কোনো কাজ একদম করা যাবে না বোঝাতে Must এবং Must not ব্যবহার হয়।',
    formula: 'Subject + must/must not + Base Verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.gavel_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Must',
      'Must not',
      'Obligation',
      'Prohibition',
    ],
    examples: <RuleExample>[
      _example('তোমাকে অবশ্যই সময়মতো আসতে হবে।', 'You must come on time.', 'on_time'),
      _example('আমাকে আজ কাজটি শেষ করতেই হবে।', 'I must finish the work today.', 'finish_work'),
      _example('তাকে অবশ্যই সত্য বলতে হবে।', 'He must tell the truth.', 'truth'),
      _example('তোমাকে অবশ্যই মনোযোগ দিয়ে শুনতে হবে।', 'You must listen carefully.', 'listen'),
      _example('আমাদের নিয়ম মেনে চলতে হবে।', 'We must follow the rules.', 'rules'),
      _example('তাদের অবশ্যই helmet পরতে হবে।', 'They must wear helmets.', 'helmet'),
      _example('তোমার এখানে ধূমপান করা যাবে না।', 'You must not smoke here.', 'no_smoking'),
      _example('আমাদের মিথ্যা বলা যাবে না।', 'We must not tell lies.', 'no_lie'),
      _example('তাকে এই দরজা খোলা যাবে না।', 'He must not open this door.', 'closed_door'),
      _example('তোমাদের ক্লাসে কথা বলা যাবে না।', 'You must not talk in class.', 'quiet_class'),
      _example('আমার এই সুযোগটি নষ্ট করা যাবে না।', 'I must not waste this opportunity.', 'opportunity'),
      _example('তাদের রাস্তার নিয়ম ভাঙা যাবে না।', 'They must not break the traffic rules.', 'traffic'),
      _example('তোমাকে কি এখন যেতে হবে?', 'Must you go now?', 'go_question'),
      _example('আমাদের কি ফর্মটি পূরণ করতে হবে?', 'Must we fill out the form?', 'form'),
      _example('তাকে অবশ্যই আজ পড়তে হবে।', 'She must study today.', 'study_today'),
    ],
    tests: <RuleTest>[
      _test(
        'must_must_not_test_01',
        'You ___ come on time.',
        <String>['must', 'musts', 'are must'],
        'must',
        'অবশ্যই করতে হবে বোঝাতে must হয়।',
      ),
      _test(
        'must_must_not_test_02',
        'I ___ finish the work today.',
        <String>['must', 'musts', 'am must'],
        'must',
        'I-এর সঙ্গেও must একই থাকে।',
      ),
      _test(
        'must_must_not_test_03',
        'He ___ tell the truth.',
        <String>['must', 'musts', 'is'],
        'must',
        'Must-এর পরে base verb tell হয়।',
      ),
      _test(
        'must_must_not_test_04',
        'You ___ smoke here.',
        <String>['must not', 'musts not', 'are not must'],
        'must not',
        'কঠোর নিষেধ বোঝাতে must not হয়।',
      ),
      _test(
        'must_must_not_test_05',
        'We ___ tell lies.',
        <String>['must not', 'musts not', 'are not must'],
        'must not',
        'Must not-এর পরে base verb tell হয়।',
      ),
      _test(
        'must_must_not_test_06',
        'Must-এর পরে কোন verb form হয়?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Base Verb',
        'Must-এর পরে base verb বসে।',
      ),
      _test(
        'must_must_not_test_07',
        'তোমাকে অবশ্যই সময়মতো আসতে হবে।',
        <String>[
          'You must come on time.',
          'You must comes on time.',
          'You must came on time.',
        ],
        'You must come on time.',
        'Must-এর পরে come-এর base form হবে।',
      ),
      _test(
        'must_must_not_test_08',
        'তোমার এখানে ধূমপান করা যাবে না।',
        <String>[
          'You must not smoke here.',
          'You must not smoked here.',
          'You must not smokes here.',
        ],
        'You must not smoke here.',
        'Must not-এর পরে smoke হবে।',
      ),
      _test(
        'must_must_not_test_09',
        'তোমাকে কি এখন যেতে হবে?',
        <String>[
          'Must you go now?',
          'Must you goes now?',
          'Do you must go now?',
        ],
        'Must you go now?',
        'Question-এ Must প্রথমে বসে।',
      ),
      _test(
        'must_must_not_test_10',
        'আমাদের কি form পূরণ করতে হবে?',
        <String>[
          'Must we fill out the form?',
          'Must we filled out the form?',
          'Do we must fill out the form?',
        ],
        'Must we fill out the form?',
        'Must-এর পরে fill-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'must_must_not_speaking_01',
        'বলুন: তোমাকে অবশ্যই সময়মতো আসতে হবে।',
        'You must come on time.',
        Icons.schedule_rounded,
        AppColors.primary,
      ),
      _speaking(
        'must_must_not_speaking_02',
        'বলুন: আমাকে আজ কাজটি শেষ করতেই হবে।',
        'I must finish the work today.',
        Icons.task_alt_rounded,
        Colors.blue,
      ),
      _speaking(
        'must_must_not_speaking_03',
        'বলুন: তাকে অবশ্যই সত্য বলতে হবে।',
        'He must tell the truth.',
        Icons.verified_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'must_must_not_speaking_04',
        'বলুন: তোমার এখানে ধূমপান করা যাবে না।',
        'You must not smoke here.',
        Icons.smoke_free_rounded,
        Colors.orange,
      ),
      _speaking(
        'must_must_not_speaking_05',
        'প্রশ্ন করুন: তোমাকে কি এখন যেতে হবে?',
        'Must you go now?',
        Icons.arrow_forward_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _mayMight = RuleContent(
    id: 'may_might',
    order: 45,
    title: 'May & Might',
    shortMeaning: 'অনুমতি ও সম্ভাবনা বোঝাতে',
    usage:
    'ভদ্রভাবে অনুমতি চাওয়া এবং কোনো কাজ ঘটতে পারে—এমন সম্ভাবনা বোঝাতে May ও Might ব্যবহার হয়।',
    formula: 'Subject + may/might + Base Verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.cloud_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'May',
      'Might',
      'Permission',
      'Possibility',
    ],
    examples: <RuleExample>[
      _example('আমি কি ভিতরে আসতে পারি?', 'May I come in?', 'come_in'),
      _example('আমি কি আপনার কলমটি নিতে পারি?', 'May I take your pen?', 'pen'),
      _example('আপনি কি এখন যেতে পারেন?', 'May you go now?', 'go'),
      _example('আজ বৃষ্টি হতে পারে।', 'It may rain today.', 'rain'),
      _example('সে আজ আসতে পারে।', 'He may come today.', 'come'),
      _example('আমরা পরে দেখা করতে পারি।', 'We may meet later.', 'meet'),
      _example('তারা হয়তো দেরি করতে পারে।', 'They might be late.', 'late'),
      _example('সে হয়তো ব্যস্ত হতে পারে।', 'She might be busy.', 'busy'),
      _example('আগামীকাল বৃষ্টি হতে পারে।', 'It might rain tomorrow.', 'rain_tomorrow'),
      _example('আমি হয়তো পরে ফোন করব।', 'I might call later.', 'call'),
      _example('তুমি হয়তো সঠিক হতে পারো।', 'You might be right.', 'right'),
      _example('সে হয়তো পরীক্ষায় পাস করবে।', 'He might pass the exam.', 'exam'),
      _example('আমি কি একটি প্রশ্ন করতে পারি?', 'May I ask a question?', 'question'),
      _example('আমরা কি এখানে বসতে পারি?', 'May we sit here?', 'sit'),
      _example('সে হয়তো আজ কাজ করবে না।', 'She might not work today.', 'not_work'),
    ],
    tests: <RuleTest>[
      _test(
        'may_might_test_01',
        '___ I come in?',
        <String>['May', 'Mays', 'Am'],
        'May',
        'ভদ্রভাবে permission চাইতে May I...? ব্যবহার হয়।',
      ),
      _test(
        'may_might_test_02',
        'It ___ rain today.',
        <String>['may', 'mays', 'is may'],
        'may',
        'সম্ভাবনা বোঝাতে may ব্যবহার হয়।',
      ),
      _test(
        'may_might_test_03',
        'He ___ come today.',
        <String>['may', 'mays', 'is'],
        'may',
        'May-এর পরে base verb come হয়।',
      ),
      _test(
        'may_might_test_04',
        'They ___ be late.',
        <String>['might', 'mights', 'are might'],
        'might',
        'কম সম্ভাবনা বোঝাতে might ব্যবহার করা যায়।',
      ),
      _test(
        'may_might_test_05',
        'She ___ be busy.',
        <String>['might', 'mights', 'is might'],
        'might',
        'Might-এর পরে base verb be হয়।',
      ),
      _test(
        'may_might_test_06',
        'May/Might-এর পরে কোন verb form হয়?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Base Verb',
        'May/Might-এর পরে base verb বসে।',
      ),
      _test(
        'may_might_test_07',
        'আমি কি ভিতরে আসতে পারি?',
        <String>[
          'May I come in?',
          'May I comes in?',
          'Do I may come in?',
        ],
        'May I come in?',
        'Permission question-এ May I...? হয়।',
      ),
      _test(
        'may_might_test_08',
        'আজ বৃষ্টি হতে পারে।',
        <String>[
          'It may rain today.',
          'It may rains today.',
          'It is may rain today.',
        ],
        'It may rain today.',
        'May-এর পরে rain-এর base form হয়।',
      ),
      _test(
        'may_might_test_09',
        'আগামীকাল বৃষ্টি হতে পারে।',
        <String>[
          'It might rain tomorrow.',
          'It might rains tomorrow.',
          'It is might rain tomorrow.',
        ],
        'It might rain tomorrow.',
        'Might-এর পরে rain-এর base form হয়।',
      ),
      _test(
        'may_might_test_10',
        'আমি কি একটি প্রশ্ন করতে পারি?',
        <String>[
          'May I ask a question?',
          'May I asked a question?',
          'Do I may ask a question?',
        ],
        'May I ask a question?',
        'ভদ্র permission চাইতে May I ask...? ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'may_might_speaking_01',
        'ভদ্রভাবে বলুন: আমি কি ভিতরে আসতে পারি?',
        'May I come in?',
        Icons.login_rounded,
        AppColors.primary,
      ),
      _speaking(
        'may_might_speaking_02',
        'বলুন: আজ বৃষ্টি হতে পারে।',
        'It may rain today.',
        Icons.umbrella_rounded,
        Colors.blue,
      ),
      _speaking(
        'may_might_speaking_03',
        'বলুন: সে আজ আসতে পারে।',
        'He may come today.',
        Icons.event_available_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'may_might_speaking_04',
        'বলুন: তারা হয়তো দেরি করতে পারে।',
        'They might be late.',
        Icons.schedule_rounded,
        Colors.orange,
      ),
      _speaking(
        'may_might_speaking_05',
        'ভদ্রভাবে বলুন: আমরা কি এখানে বসতে পারি?',
        'May we sit here?',
        Icons.event_seat_rounded,
        Colors.green,
      ),
    ],
  );
}