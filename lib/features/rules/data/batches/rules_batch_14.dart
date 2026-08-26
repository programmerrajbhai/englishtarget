import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch14Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _goingTo,
    _canCannot,
    _could,
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

  static final RuleContent _goingTo = RuleContent(
    id: 'going_to',
    order: 40,
    title: 'Going to',
    shortMeaning: 'পরিকল্পিত ভবিষ্যৎ কাজ বোঝাতে',
    usage:
    'আগে থেকে করা পরিকল্পনা বা ভবিষ্যতে কিছু ঘটতে যাচ্ছে বোঝাতে Going to ব্যবহার হয়।',
    formula: 'Subject + am/is/are + going to + Base Verb',
    category: 'Past & Future',
    level: RuleLevel.beginner,
    icon: Icons.event_available_rounded,
    color: AppColors.amber,
    keywords: <String>['Going to', 'Future', 'Plan', 'Intention'],
    examples: <RuleExample>[
      _example('আমি আগামীকাল পড়তে যাচ্ছি।', 'I am going to study tomorrow.', 'study'),
      _example('আমি নতুন ফোন কিনতে যাচ্ছি।', 'I am going to buy a new phone.', 'phone'),
      _example('তুমি কি বাইরে যেতে যাচ্ছো?', 'Are you going to go outside?', 'outside'),
      _example('সে ডাক্তার হতে যাচ্ছে।', 'He is going to become a doctor.', 'doctor'),
      _example('সে রাতের খাবার রান্না করতে যাচ্ছে।', 'She is going to cook dinner.', 'cook'),
      _example('আমরা ঢাকা যেতে যাচ্ছি।', 'We are going to visit Dhaka.', 'dhaka'),
      _example('তারা একটি নতুন বাড়ি বানাতে যাচ্ছে।', 'They are going to build a new house.', 'house'),
      _example('বৃষ্টি হতে যাচ্ছে।', 'It is going to rain.', 'rain'),
      _example('আমি আজ রাতে কাজ করতে যাচ্ছি।', 'I am going to work tonight.', 'work'),
      _example('সে English practice করতে যাচ্ছে।', 'He is going to practice English.', 'practice'),
      _example('আমরা একটি movie দেখতে যাচ্ছি।', 'We are going to watch a movie.', 'movie'),
      _example('তারা আগামী সপ্তাহে ভ্রমণ করতে যাচ্ছে।', 'They are going to travel next week.', 'travel'),
      _example('সে আমাকে সাহায্য করতে যাচ্ছে।', 'She is going to help me.', 'help'),
      _example('আমি নতুন একটি course শুরু করতে যাচ্ছি।', 'I am going to start a new course.', 'course'),
      _example('তুমি আজ কী করতে যাচ্ছো?', 'What are you going to do today?', 'question'),
    ],
    tests: <RuleTest>[
      _test(
        'going_to_test_01',
        'I ___ going to study.',
        <String>['am', 'is', 'are'],
        'am',
        'I-এর সঙ্গে am going to হয়।',
      ),
      _test(
        'going_to_test_02',
        'She ___ going to cook.',
        <String>['am', 'is', 'are'],
        'is',
        'She-এর সঙ্গে is going to হয়।',
      ),
      _test(
        'going_to_test_03',
        'We ___ going to travel.',
        <String>['am', 'is', 'are'],
        'are',
        'We-এর সঙ্গে are going to হয়।',
      ),
      _test(
        'going_to_test_04',
        'They are going to ___ a house.',
        <String>['build', 'built', 'building'],
        'build',
        'Going to-এর পরে base verb হয়।',
      ),
      _test(
        'going_to_test_05',
        'It is going to ___.',
        <String>['rain', 'rains', 'raining'],
        'rain',
        'Going to-এর পরে rain-এর base form হবে।',
      ),
      _test(
        'going_to_test_06',
        'He is going to ___ a doctor.',
        <String>['become', 'became', 'becoming'],
        'become',
        'Going to-এর পরে base verb become হবে।',
      ),
      _test(
        'going_to_test_07',
        'আমি নতুন ফোন কিনতে যাচ্ছি।',
        <String>[
          'I am going to buy a new phone.',
          'I is going to buy a new phone.',
          'I am going buy a new phone.',
        ],
        'I am going to buy a new phone.',
        'I + am + going to + base verb।',
      ),
      _test(
        'going_to_test_08',
        'সে রান্না করতে যাচ্ছে।',
        <String>[
          'She is going to cook dinner.',
          'She are going to cook dinner.',
          'She is going to cooked dinner.',
        ],
        'She is going to cook dinner.',
        'She-এর সঙ্গে is এবং base verb cook হবে।',
      ),
      _test(
        'going_to_test_09',
        'আমরা ঢাকা যেতে যাচ্ছি।',
        <String>[
          'We are going to visit Dhaka.',
          'We is going to visit Dhaka.',
          'We are going visit Dhaka.',
        ],
        'We are going to visit Dhaka.',
        'We-এর সঙ্গে are going to হয়।',
      ),
      _test(
        'going_to_test_10',
        'তুমি আজ কী করতে যাচ্ছো?',
        <String>[
          'What are you going to do today?',
          'What is you going to do today?',
          'What are you going do today?',
        ],
        'What are you going to do today?',
        'Question-এ Are + subject + going to হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'going_to_speaking_01',
        'বলুন: আমি আগামীকাল পড়তে যাচ্ছি।',
        'I am going to study tomorrow.',
        Icons.menu_book_rounded,
        AppColors.amber,
      ),
      _speaking(
        'going_to_speaking_02',
        'বলুন: সে রাতের খাবার রান্না করতে যাচ্ছে।',
        'She is going to cook dinner.',
        Icons.restaurant_rounded,
        Colors.blue,
      ),
      _speaking(
        'going_to_speaking_03',
        'বলুন: আমরা ঢাকা যেতে যাচ্ছি।',
        'We are going to visit Dhaka.',
        Icons.location_city_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'going_to_speaking_04',
        'বলুন: বৃষ্টি হতে যাচ্ছে।',
        'It is going to rain.',
        Icons.umbrella_rounded,
        Colors.orange,
      ),
      _speaking(
        'going_to_speaking_05',
        'বলুন: তারা একটি নতুন বাড়ি বানাতে যাচ্ছে।',
        'They are going to build a new house.',
        Icons.home_work_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _canCannot = RuleContent(
    id: 'can_cannot',
    order: 41,
    title: 'Can & Cannot',
    shortMeaning: 'ক্ষমতা, অনুমতি ও অসমর্থতা বোঝাতে',
    usage:
    'কেউ কোনো কাজ করতে পারে, অনুমতি আছে বা পারে না—এগুলো বোঝাতে Can এবং Cannot ব্যবহার হয়।',
    formula: 'Subject + can/cannot + Base Verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.bolt_rounded,
    color: AppColors.primary,
    keywords: <String>['Can', 'Cannot', 'Ability', 'Permission'],
    examples: <RuleExample>[
      _example('আমি সাঁতার কাটতে পারি।', 'I can swim.', 'swim'),
      _example('তুমি English বলতে পারো।', 'You can speak English.', 'speak'),
      _example('সে গাড়ি চালাতে পারে।', 'He can drive a car.', 'drive'),
      _example('সে ভালো গান গাইতে পারে।', 'She can sing well.', 'sing'),
      _example('আমরা তোমাকে সাহায্য করতে পারি।', 'We can help you.', 'help'),
      _example('তারা দ্রুত দৌড়াতে পারে।', 'They can run fast.', 'run'),
      _example('আমি আজ আসতে পারব না।', 'I cannot come today.', 'not_come'),
      _example('সে সাঁতার কাটতে পারে না।', 'He cannot swim.', 'not_swim'),
      _example('তুমি এখানে বসতে পারো।', 'You can sit here.', 'sit'),
      _example('সে কি আমাকে সাহায্য করতে পারে?', 'Can she help me?', 'help_question'),
      _example('আমরা কি এখন যেতে পারি?', 'Can we go now?', 'go_question'),
      _example('তারা এটি করতে পারে না।', 'They cannot do it.', 'not_do'),
      _example('আমি কম্পিউটার ব্যবহার করতে পারি।', 'I can use a computer.', 'computer'),
      _example('সে তিনটি ভাষা বলতে পারে।', 'She can speak three languages.', 'languages'),
      _example('তুমি কি আমার কলমটি নিতে পারো?', 'Can you take my pen?', 'pen'),
    ],
    tests: <RuleTest>[
      _test(
        'can_cannot_test_01',
        'I ___ swim.',
        <String>['can', 'cans', 'am can'],
        'can',
        'Can-এর পরে base verb swim হয়।',
      ),
      _test(
        'can_cannot_test_02',
        'She ___ sing well.',
        <String>['can', 'cans', 'is can'],
        'can',
        'Can সব subject-এর সঙ্গে একই থাকে।',
      ),
      _test(
        'can_cannot_test_03',
        'He ___ drive a car.',
        <String>['can', 'cans', 'is'],
        'can',
        'Can-এর পরে drive-এর base form হয়।',
      ),
      _test(
        'can_cannot_test_04',
        'I ___ come today.',
        <String>['cannot', 'can nots', 'am not can'],
        'cannot',
        'পারে না বোঝাতে cannot ব্যবহার হয়।',
      ),
      _test(
        'can_cannot_test_05',
        'Can-এর পরে কোন verb form হয়?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Base Verb',
        'Can-এর পরে base verb বসে।',
      ),
      _test(
        'can_cannot_test_06',
        'সে English বলতে পারে।',
        <String>[
          'She can speak English.',
          'She can speaks English.',
          'She cans speak English.',
        ],
        'She can speak English.',
        'Can-এর পরে speak হবে, speaks নয়।',
      ),
      _test(
        'can_cannot_test_07',
        'সে সাঁতার কাটতে পারে না।',
        <String>[
          'He cannot swim.',
          'He cannot swims.',
          'He does not can swim.',
        ],
        'He cannot swim.',
        'Cannot-এর পরে base verb swim হয়।',
      ),
      _test(
        'can_cannot_test_08',
        'আমরা কি এখন যেতে পারি?',
        <String>[
          'Can we go now?',
          'Can we goes now?',
          'Do we can go now?',
        ],
        'Can we go now?',
        'Question-এ Can প্রথমে বসে।',
      ),
      _test(
        'can_cannot_test_09',
        'সে কি আমাকে সাহায্য করতে পারে?',
        <String>[
          'Can she help me?',
          'Can she helps me?',
          'Does she can help me?',
        ],
        'Can she help me?',
        'Can-এর পরে help-এর base form হয়।',
      ),
      _test(
        'can_cannot_test_10',
        'তারা এটি করতে পারে না।',
        <String>[
          'They cannot do it.',
          'They cannot does it.',
          'They do not can it.',
        ],
        'They cannot do it.',
        'Cannot-এর পরে do-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'can_cannot_speaking_01',
        'বলুন: আমি সাঁতার কাটতে পারি।',
        'I can swim.',
        Icons.pool_rounded,
        AppColors.primary,
      ),
      _speaking(
        'can_cannot_speaking_02',
        'বলুন: সে গাড়ি চালাতে পারে।',
        'He can drive a car.',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'can_cannot_speaking_03',
        'বলুন: সে গান গাইতে পারে।',
        'She can sing well.',
        Icons.music_note_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'can_cannot_speaking_04',
        'বলুন: আমি আজ আসতে পারব না।',
        'I cannot come today.',
        Icons.block_rounded,
        Colors.orange,
      ),
      _speaking(
        'can_cannot_speaking_05',
        'প্রশ্ন করুন: আমরা কি এখন যেতে পারি?',
        'Can we go now?',
        Icons.arrow_forward_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _could = RuleContent(
    id: 'could',
    order: 42,
    title: 'Could',
    shortMeaning: 'অতীতের ক্ষমতা ও ভদ্র request বোঝাতে',
    usage:
    'অতীতে কোনো কাজ করতে পারা এবং ভদ্রভাবে request করতে Could ব্যবহার হয়।',
    formula: 'Subject + could + Base Verb',
    category: 'Modals',
    level: RuleLevel.beginner,
    icon: Icons.volunteer_activism_rounded,
    color: AppColors.primary,
    keywords: <String>['Could', 'Past Ability', 'Polite Request'],
    examples: <RuleExample>[
      _example('আমি ছোটবেলায় দৌড়াতে পারতাম।', 'I could run when I was young.', 'run'),
      _example('সে ছোটবেলায় সাঁতার কাটতে পারত।', 'He could swim when he was young.', 'swim'),
      _example('সে সুন্দর গান গাইতে পারত।', 'She could sing beautifully.', 'sing'),
      _example('আমরা তখন English বলতে পারতাম না।', 'We could not speak English then.', 'not_speak'),
      _example('তারা অনেক দূর হাঁটতে পারত।', 'They could walk very far.', 'walk'),
      _example('আমি কি আপনাকে সাহায্য করতে পারি?', 'Could I help you?', 'help'),
      _example('আপনি কি দরজাটি খুলতে পারবেন?', 'Could you open the door?', 'open_door'),
      _example('আপনি কি একটু অপেক্ষা করতে পারবেন?', 'Could you wait a moment?', 'wait'),
      _example('আমি কি আপনার কলমটি নিতে পারি?', 'Could I take your pen?', 'pen'),
      _example('সে কি সমস্যাটি সমাধান করতে পারত?', 'Could he solve the problem?', 'solve'),
      _example('আমরা কি ভিতরে আসতে পারি?', 'Could we come inside?', 'inside'),
      _example('সে আগে দ্রুত দৌড়াতে পারত।', 'She could run fast before.', 'run_fast'),
      _example('আমি তখন গাড়ি চালাতে পারতাম না।', 'I could not drive then.', 'not_drive'),
      _example('তারা কি সত্যটি জানতে পারত?', 'Could they know the truth?', 'truth'),
      _example('আপনি কি আমাকে বুঝিয়ে বলতে পারবেন?', 'Could you explain it to me?', 'explain'),
    ],
    tests: <RuleTest>[
      _test(
        'could_test_01',
        'I ___ run when I was young.',
        <String>['could', 'can', 'coulds'],
        'could',
        'অতীতের ক্ষমতার জন্য could ব্যবহার হয়।',
      ),
      _test(
        'could_test_02',
        'He ___ swim when he was young.',
        <String>['could', 'can', 'coulds'],
        'could',
        'Past ability বোঝাতে could হয়।',
      ),
      _test(
        'could_test_03',
        'She ___ sing beautifully.',
        <String>['could', 'can', 'coulds'],
        'could',
        'অতীতে পারত বোঝাতে could ব্যবহার হয়।',
      ),
      _test(
        'could_test_04',
        'We ___ speak English then.',
        <String>['could not', 'coulds not', 'can not'],
        'could not',
        'অতীতের negative ability-তে could not হয়।',
      ),
      _test(
        'could_test_05',
        'Could-এর পরে কোন verb form হয়?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Base Verb',
        'Could-এর পরে base verb বসে।',
      ),
      _test(
        'could_test_06',
        'আপনি কি দরজাটি খুলতে পারবেন?',
        <String>[
          'Could you open the door?',
          'Could you opened the door?',
          'Can you opened the door?',
        ],
        'Could you open the door?',
        'ভদ্র request-এ Could + subject + base verb হয়।',
      ),
      _test(
        'could_test_07',
        'আমি কি আপনার কলমটি নিতে পারি?',
        <String>[
          'Could I take your pen?',
          'Could I took your pen?',
          'Could I taking your pen?',
        ],
        'Could I take your pen?',
        'Could-এর পরে take-এর base form হবে।',
      ),
      _test(
        'could_test_08',
        'সে আগে গাড়ি চালাতে পারত না।',
        <String>[
          'He could not drive before.',
          'He could not drove before.',
          'He can not drive before.',
        ],
        'He could not drive before.',
        'Past negative-এ could not + drive হয়।',
      ),
      _test(
        'could_test_09',
        'আমরা কি ভিতরে আসতে পারি?',
        <String>[
          'Could we come inside?',
          'Could we came inside?',
          'Can we came inside?',
        ],
        'Could we come inside?',
        'Polite permission-এর জন্য Could ব্যবহার হয়।',
      ),
      _test(
        'could_test_10',
        'আপনি কি আমাকে বুঝিয়ে বলতে পারবেন?',
        <String>[
          'Could you explain it to me?',
          'Could you explained it to me?',
          'Could you explaining it to me?',
        ],
        'Could you explain it to me?',
        'Could-এর পরে explain-এর base form হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'could_speaking_01',
        'বলুন: আমি ছোটবেলায় দৌড়াতে পারতাম।',
        'I could run when I was young.',
        Icons.directions_run_rounded,
        AppColors.primary,
      ),
      _speaking(
        'could_speaking_02',
        'বলুন: সে ছোটবেলায় সাঁতার কাটতে পারত।',
        'He could swim when he was young.',
        Icons.pool_rounded,
        Colors.blue,
      ),
      _speaking(
        'could_speaking_03',
        'অনুরোধ করুন: আপনি কি দরজাটি খুলতে পারবেন?',
        'Could you open the door?',
        Icons.door_front_door_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'could_speaking_04',
        'প্রশ্ন করুন: আমি কি আপনার কলমটি নিতে পারি?',
        'Could I take your pen?',
        Icons.edit_rounded,
        Colors.orange,
      ),
      _speaking(
        'could_speaking_05',
        'অনুরোধ করুন: আপনি কি একটু অপেক্ষা করতে পারবেন?',
        'Could you wait a moment?',
        Icons.hourglass_empty_rounded,
        Colors.green,
      ),
    ],
  );
}