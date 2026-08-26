import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch13Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _didNot,
    _pastContinuous,
    _will,
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

  static final RuleContent _didNot = RuleContent(
    id: 'did_not',
    order: 37,
    title: 'Did not',
    shortMeaning: 'অতীতে কোনো কাজ হয়নি বোঝাতে',
    usage:
    'অতীতে কোনো কাজ হয়নি বোঝাতে Did not ব্যবহার হয়। Did not-এর পরে সবসময় base verb বসে।',
    formula: 'Subject + did not + Base Verb',
    category: 'Past & Future',
    level: RuleLevel.beginner,
    icon: Icons.cancel_rounded,
    color: AppColors.amber,
    keywords: <String>[
      'Did not',
      "Didn't",
      'Past Negative',
      'Base Verb',
    ],
    examples: <RuleExample>[
      _example('আমি গতকাল স্কুলে যাইনি।', 'I did not go to school yesterday.', 'not_school'),
      _example('সে ভাত খায়নি।', 'She did not eat rice.', 'not_eat'),
      _example('সে আমাকে ফোন করেনি।', 'He did not call me.', 'not_call'),
      _example('তুমি বইটি পড়োনি।', 'You did not read the book.', 'not_read'),
      _example('আমরা সিনেমাটি দেখিনি।', 'We did not watch the movie.', 'not_movie'),
      _example('তারা ফুটবল খেলেনি।', 'They did not play football.', 'not_play'),
      _example('আমি তাকে দেখিনি।', 'I did not see him.', 'not_see'),
      _example('সে চিঠি লেখেনি।', 'She did not write a letter.', 'not_write'),
      _example('সে গাড়ি কেনেনি।', 'He did not buy a car.', 'not_buy'),
      _example('আমরা পানি পান করিনি।', 'We did not drink water.', 'not_drink'),
      _example('তারা আমাকে সাহায্য করেনি।', 'They did not help me.', 'not_help'),
      _example('আমি সেখানে যাইনি।', 'I did not go there.', 'not_there'),
      _example('সে সত্যটি জানত না।', 'She did not know the truth.', 'not_know'),
      _example('তুমি দরজা খোলোনি।', 'You did not open the door.', 'not_open'),
      _example('আমরা দেরি করিনি।', 'We did not get late.', 'not_late'),
    ],
    tests: <RuleTest>[
      _test(
        'did_not_test_01',
        'I ___ go to school yesterday.',
        <String>['did not', 'does not', 'was not'],
        'did not',
        'Past negative sentence-এ did not ব্যবহার হয়।',
      ),
      _test(
        'did_not_test_02',
        'She ___ eat rice.',
        <String>['did not', 'does not', 'is not'],
        'did not',
        'She-এর past negative form হলো did not।',
      ),
      _test(
        'did_not_test_03',
        'He ___ call me.',
        <String>['did not', 'does not', 'was not'],
        'did not',
        'অতীতে কাজ হয়নি বোঝাতে did not হয়।',
      ),
      _test(
        'did_not_test_04',
        'They ___ play football.',
        <String>['did not', 'does not', 'were not'],
        'did not',
        'They-এর past negative-এ did not ব্যবহার হয়।',
      ),
      _test(
        'did_not_test_05',
        'Did not-এর পরে কোন form হবে?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Base Verb',
        'Did not-এর পরে সবসময় base verb বসে।',
      ),
      _test(
        'did_not_test_06',
        'Choose the correct sentence:',
        <String>[
          'I did not went.',
          'I did not go.',
          'I did not going.',
        ],
        'I did not go.',
        'Did not-এর পরে go হবে, went নয়।',
      ),
      _test(
        'did_not_test_07',
        'সে ভাত খায়নি।',
        <String>[
          'She did not eat rice.',
          'She did not ate rice.',
          'She does not ate rice.',
        ],
        'She did not eat rice.',
        'Did not-এর পরে eat-এর base form হয়।',
      ),
      _test(
        'did_not_test_08',
        'সে গাড়ি কেনেনি।',
        <String>[
          'He did not buy a car.',
          'He did not bought a car.',
          'He does not bought a car.',
        ],
        'He did not buy a car.',
        'Did not-এর পরে buy হবে, bought নয়।',
      ),
      _test(
        'did_not_test_09',
        'তুমি দরজা খোলোনি।',
        <String>[
          'You did not open the door.',
          'You did not opened the door.',
          'You does not open the door.',
        ],
        'You did not open the door.',
        'Did not-এর পরে open-এর base form হয়।',
      ),
      _test(
        'did_not_test_10',
        'আমরা সিনেমাটি দেখিনি।',
        <String>[
          'We did not watch the movie.',
          'We did not watched the movie.',
          'We does not watch the movie.',
        ],
        'We did not watch the movie.',
        'Past negative-এ did not + watch হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'did_not_speaking_01',
        'বলুন: আমি গতকাল স্কুলে যাইনি।',
        'I did not go to school yesterday.',
        Icons.school_rounded,
        AppColors.amber,
      ),
      _speaking(
        'did_not_speaking_02',
        'বলুন: সে ভাত খায়নি।',
        'She did not eat rice.',
        Icons.restaurant_rounded,
        Colors.blue,
      ),
      _speaking(
        'did_not_speaking_03',
        'বলুন: সে আমাকে ফোন করেনি।',
        'He did not call me.',
        Icons.call_end_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'did_not_speaking_04',
        'বলুন: আমরা সিনেমাটি দেখিনি।',
        'We did not watch the movie.',
        Icons.movie_rounded,
        Colors.orange,
      ),
      _speaking(
        'did_not_speaking_05',
        'বলুন: তারা ফুটবল খেলেনি।',
        'They did not play football.',
        Icons.sports_soccer_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _pastContinuous = RuleContent(
    id: 'past_continuous',
    order: 38,
    title: 'Past Continuous',
    shortMeaning: 'অতীতে কোনো কাজ চলছিল বোঝাতে',
    usage:
    'অতীতের কোনো নির্দিষ্ট সময়ে কোনো কাজ চলমান ছিল বোঝাতে Past Continuous ব্যবহার হয়।',
    formula: 'Subject + was/were + Verb-ing',
    category: 'Past & Future',
    level: RuleLevel.beginner,
    icon: Icons.timelapse_rounded,
    color: AppColors.amber,
    keywords: <String>[
      'Past Continuous',
      'Was',
      'Were',
      'Verb-ing',
    ],
    examples: <RuleExample>[
      _example('আমি পড়ছিলাম।', 'I was studying.', 'studying'),
      _example('তুমি কাজ করছিলে।', 'You were working.', 'working'),
      _example('সে বই পড়ছিল।', 'He was reading a book.', 'reading'),
      _example('সে রান্না করছিল।', 'She was cooking.', 'cooking'),
      _example('আমরা ফুটবল খেলছিলাম।', 'We were playing football.', 'playing'),
      _example('তারা গান শুনছিল।', 'They were listening to music.', 'listening'),
      _example('বৃষ্টি হচ্ছিল।', 'It was raining.', 'raining'),
      _example('আমি চিঠি লিখছিলাম।', 'I was writing a letter.', 'writing'),
      _example('সে গাড়ি চালাচ্ছিল।', 'He was driving a car.', 'driving'),
      _example('সে ফোনে কথা বলছিল।', 'She was talking on the phone.', 'talking'),
      _example('আমরা TV দেখছিলাম।', 'We were watching TV.', 'watching'),
      _example('তারা রাস্তায় হাঁটছিল।', 'They were walking on the road.', 'walking'),
      _example('শিশুটি ঘুমাচ্ছিল।', 'The baby was sleeping.', 'sleeping'),
      _example('তুমি English practice করছিলে।', 'You were practicing English.', 'practice'),
      _example('আমি তখন রান্না করছিলাম।', 'I was cooking then.', 'cooking_then'),
    ],
    tests: <RuleTest>[
      _test(
        'past_continuous_test_01',
        'I ___ studying.',
        <String>['was', 'were', 'am'],
        'was',
        'I-এর সঙ্গে was বসে।',
      ),
      _test(
        'past_continuous_test_02',
        'You ___ working.',
        <String>['was', 'were', 'are'],
        'were',
        'You-এর সঙ্গে were বসে।',
      ),
      _test(
        'past_continuous_test_03',
        'He ___ reading a book.',
        <String>['was', 'were', 'is'],
        'was',
        'He-এর সঙ্গে was বসে।',
      ),
      _test(
        'past_continuous_test_04',
        'She ___ cooking.',
        <String>['was', 'were', 'is'],
        'was',
        'She-এর সঙ্গে was বসে।',
      ),
      _test(
        'past_continuous_test_05',
        'We ___ playing football.',
        <String>['was', 'were', 'are'],
        'were',
        'We-এর সঙ্গে were বসে।',
      ),
      _test(
        'past_continuous_test_06',
        'They ___ listening to music.',
        <String>['was', 'were', 'are'],
        'were',
        'They-এর সঙ্গে were বসে।',
      ),
      _test(
        'past_continuous_test_07',
        'Past Continuous-এ verb-এর কোন form হয়?',
        <String>['Base Verb', 'Past Verb', 'Verb-ing'],
        'Verb-ing',
        'Was/were-এর পরে verb-ing হয়।',
      ),
      _test(
        'past_continuous_test_08',
        'বৃষ্টি হচ্ছিল।',
        <String>[
          'It was raining.',
          'It were raining.',
          'It is raining yesterday.',
        ],
        'It was raining.',
        'It-এর সঙ্গে was + raining হয়।',
      ),
      _test(
        'past_continuous_test_09',
        'আমরা TV দেখছিলাম।',
        <String>[
          'We was watching TV.',
          'We were watching TV.',
          'We are watching TV yesterday.',
        ],
        'We were watching TV.',
        'We-এর সঙ্গে were + watching হয়।',
      ),
      _test(
        'past_continuous_test_10',
        'শিশুটি ঘুমাচ্ছিল।',
        <String>[
          'The baby was sleeping.',
          'The baby were sleeping.',
          'The baby slept now.',
        ],
        'The baby was sleeping.',
        'Singular subject-এর সঙ্গে was হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'past_continuous_speaking_01',
        'বলুন: আমি পড়ছিলাম।',
        'I was studying.',
        Icons.menu_book_rounded,
        AppColors.amber,
      ),
      _speaking(
        'past_continuous_speaking_02',
        'বলুন: সে রান্না করছিল।',
        'She was cooking.',
        Icons.restaurant_rounded,
        Colors.blue,
      ),
      _speaking(
        'past_continuous_speaking_03',
        'বলুন: আমরা ফুটবল খেলছিলাম।',
        'We were playing football.',
        Icons.sports_soccer_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'past_continuous_speaking_04',
        'বলুন: তারা গান শুনছিল।',
        'They were listening to music.',
        Icons.music_note_rounded,
        Colors.orange,
      ),
      _speaking(
        'past_continuous_speaking_05',
        'বলুন: বৃষ্টি হচ্ছিল।',
        'It was raining.',
        Icons.umbrella_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _will = RuleContent(
    id: 'will',
    order: 39,
    title: 'Will',
    shortMeaning: 'ভবিষ্যতের কাজ বা সিদ্ধান্ত বোঝাতে',
    usage:
    'ভবিষ্যতে কোনো কাজ হবে, করার ইচ্ছা বা তাৎক্ষণিক সিদ্ধান্ত বোঝাতে Will ব্যবহার হয়।',
    formula: 'Subject + will + Base Verb',
    category: 'Past & Future',
    level: RuleLevel.beginner,
    icon: Icons.arrow_forward_rounded,
    color: AppColors.amber,
    keywords: <String>[
      'Will',
      'Future',
      'Promise',
      'Decision',
    ],
    examples: <RuleExample>[
      _example('আমি কাল কাজ করব।', 'I will work tomorrow.', 'work_tomorrow'),
      _example('আমি তোমাকে সাহায্য করব।', 'I will help you.', 'help'),
      _example('সে আগামীকাল আসবে।', 'He will come tomorrow.', 'come_tomorrow'),
      _example('সে English শিখবে।', 'She will learn English.', 'learn'),
      _example('আমরা পরে কথা বলব।', 'We will talk later.', 'talk_later'),
      _example('তারা আগামীকাল যাবে।', 'They will go tomorrow.', 'go_tomorrow'),
      _example('বৃষ্টি হবে।', 'It will rain.', 'rain_future'),
      _example('আমি তোমাকে ফোন করব।', 'I will call you.', 'call'),
      _example('সে রাতের খাবার রান্না করবে।', 'She will cook dinner.', 'cook'),
      _example('সে নতুন গাড়ি কিনবে।', 'He will buy a new car.', 'buy_car'),
      _example('আমরা English practice করব।', 'We will practice English.', 'practice'),
      _example('তুমি সফল হবে।', 'You will succeed.', 'success'),
      _example('তারা আমাদের সাহায্য করবে।', 'They will help us.', 'help_us'),
      _example('আমি দরজাটি খুলব।', 'I will open the door.', 'open_door'),
      _example('চিন্তা করো না, আমি আসব।', 'Do not worry, I will come.', 'promise'),
    ],
    tests: <RuleTest>[
      _test(
        'will_test_01',
        'I ___ work tomorrow.',
        <String>['will', 'was', 'am'],
        'will',
        'Future sentence-এ will ব্যবহার হয়।',
      ),
      _test(
        'will_test_02',
        'She ___ learn English.',
        <String>['will', 'wills', 'is'],
        'will',
        'Will সব subject-এর সঙ্গে একই থাকে।',
      ),
      _test(
        'will_test_03',
        'He will ___ tomorrow.',
        <String>['come', 'comes', 'came'],
        'come',
        'Will-এর পরে base verb হয়।',
      ),
      _test(
        'will_test_04',
        'We will ___ later.',
        <String>['talk', 'talks', 'talked'],
        'talk',
        'Will-এর পরে talk-এর base form হবে।',
      ),
      _test(
        'will_test_05',
        'They ___ go tomorrow.',
        <String>['will', 'wills', 'are'],
        'will',
        'Future action বোঝাতে will হয়।',
      ),
      _test(
        'will_test_06',
        'It ___ rain.',
        <String>['will', 'was', 'is'],
        'will',
        'ভবিষ্যতের আবহাওয়া বোঝাতে will ব্যবহার হয়।',
      ),
      _test(
        'will_test_07',
        'আমি তোমাকে সাহায্য করব।',
        <String>[
          'I will help you.',
          'I will helps you.',
          'I am help you.',
        ],
        'I will help you.',
        'Will-এর পরে help-এর base form হয়।',
      ),
      _test(
        'will_test_08',
        'সে নতুন গাড়ি কিনবে।',
        <String>[
          'He will buy a new car.',
          'He will bought a new car.',
          'He wills buy a new car.',
        ],
        'He will buy a new car.',
        'Will-এর পরে buy হবে, bought নয়।',
      ),
      _test(
        'will_test_09',
        'আমরা English practice করব।',
        <String>[
          'We will practice English.',
          'We will practices English.',
          'We are practice English.',
        ],
        'We will practice English.',
        'Will-এর পরে base verb practice হয়।',
      ),
      _test(
        'will_test_10',
        'চিন্তা করো না, আমি আসব।',
        <String>[
          'Do not worry, I will come.',
          'Do not worry, I will comes.',
          'Do not worry, I am come.',
        ],
        'Do not worry, I will come.',
        'Future promise-এর জন্য will ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'will_speaking_01',
        'বলুন: আমি কাল কাজ করব।',
        'I will work tomorrow.',
        Icons.work_rounded,
        AppColors.amber,
      ),
      _speaking(
        'will_speaking_02',
        'বলুন: আমি তোমাকে সাহায্য করব।',
        'I will help you.',
        Icons.volunteer_activism_rounded,
        Colors.blue,
      ),
      _speaking(
        'will_speaking_03',
        'বলুন: সে আগামীকাল আসবে।',
        'He will come tomorrow.',
        Icons.event_available_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'will_speaking_04',
        'বলুন: আমরা পরে কথা বলব।',
        'We will talk later.',
        Icons.chat_rounded,
        Colors.orange,
      ),
      _speaking(
        'will_speaking_05',
        'বলুন: তারা আগামীকাল যাবে।',
        'They will go tomorrow.',
        Icons.directions_walk_rounded,
        Colors.green,
      ),
    ],
  );
}