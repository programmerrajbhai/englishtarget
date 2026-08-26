import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch07Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _haveHas,
    _had,
    _subjectVerbObject,
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

  static final RuleContent _haveHas = RuleContent(
    id: 'have_has',
    order: 19,
    title: 'Have & Has',
    shortMeaning: 'কোনো কিছু থাকা বা মালিকানা বোঝাতে',
    usage:
    'I, You, We, They-এর সঙ্গে Have এবং He, She, It-এর সঙ্গে Has ব্যবহার হয়।',
    formula: 'I/You/We/They + have | He/She/It + has',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.inventory_2_rounded,
    color: AppColors.primary,
    keywords: <String>['Have', 'Has', 'Possession', 'Ownership'],
    examples: <RuleExample>[
      _example('আমার একটি বই আছে।', 'I have a book.', 'have_book'),
      _example('তোমার একটি কলম আছে।', 'You have a pen.', 'have_pen'),
      _example('তার একটি গাড়ি আছে।', 'He has a car.', 'has_car'),
      _example('তার একটি ব্যাগ আছে।', 'She has a bag.', 'has_bag'),
      _example('কুকুরটির একটি লেজ আছে।', 'It has a tail.', 'has_tail'),
      _example('আমাদের একটি বাড়ি আছে।', 'We have a house.', 'have_house'),
      _example('তাদের অনেক বন্ধু আছে।', 'They have many friends.', 'have_friends'),
      _example('আমার একটি ফোন আছে।', 'I have a phone.', 'have_phone'),
      _example('তার একটি নতুন কম্পিউটার আছে।', 'He has a new computer.', 'has_computer'),
      _example('তার একটি সুন্দর কণ্ঠ আছে।', 'She has a beautiful voice.', 'has_voice'),
      _example('আমাদের একটি project আছে।', 'We have a project.', 'have_project'),
      _example('তোমাদের একটি সুযোগ আছে।', 'You have an opportunity.', 'have_opportunity'),
      _example('তাদের একটি বড় সমস্যা আছে।', 'They have a big problem.', 'have_problem'),
      _example('বিড়ালটির চারটি পা আছে।', 'It has four legs.', 'cat_legs'),
      _example('আমার কোনো সময় নেই।', 'I do not have time.', 'no_time'),
    ],
    tests: <RuleTest>[
      _test('have_has_test_01', 'I ___ a book.', <String>['have', 'has', 'had'], 'have', 'I-এর সঙ্গে have বসে।'),
      _test('have_has_test_02', 'She ___ a bag.', <String>['have', 'has', 'had'], 'has', 'She-এর সঙ্গে has বসে।'),
      _test('have_has_test_03', 'He ___ a car.', <String>['have', 'has', 'having'], 'has', 'He-এর সঙ্গে has বসে।'),
      _test('have_has_test_04', 'We ___ a house.', <String>['have', 'has', 'had'], 'have', 'We-এর সঙ্গে have বসে।'),
      _test('have_has_test_05', 'They ___ many friends.', <String>['have', 'has', 'having'], 'have', 'They-এর সঙ্গে have বসে।'),
      _test('have_has_test_06', 'The cat ___ four legs.', <String>['have', 'has', 'having'], 'has', 'It বা singular noun-এর সঙ্গে has বসে।'),
      _test('have_has_test_07', 'আমার একটি ফোন আছে।', <String>['I have a phone.', 'I has a phone.', 'I had a phone.'], 'I have a phone.', 'I-এর সঙ্গে have ব্যবহার হয়।'),
      _test('have_has_test_08', 'তার একটি কম্পিউটার আছে।', <String>['He have a computer.', 'He has a computer.', 'He having a computer.'], 'He has a computer.', 'He-এর সঙ্গে has ব্যবহার হয়।'),
      _test('have_has_test_09', 'Choose the correct sentence:', <String>['She have a voice.', 'She has a voice.', 'She having a voice.'], 'She has a voice.', 'She-এর সঙ্গে has বসে।'),
      _test('have_has_test_10', 'আমার কোনো সময় নেই।', <String>['I do not have time.', 'I does not have time.', 'I has not time.'], 'I do not have time.', 'I-এর negative form: do not have।'),
    ],
    speakingTests: <SpeakingTest>[
      _speaking('have_has_speaking_01', 'বলুন: আমার একটি বই আছে।', 'I have a book.', Icons.menu_book_rounded, AppColors.primary),
      _speaking('have_has_speaking_02', 'বলুন: তার একটি গাড়ি আছে।', 'He has a car.', Icons.directions_car_rounded, Colors.blue),
      _speaking('have_has_speaking_03', 'বলুন: তার একটি ব্যাগ আছে।', 'She has a bag.', Icons.backpack_rounded, Colors.pink),
      _speaking('have_has_speaking_04', 'বলুন: আমাদের একটি বাড়ি আছে।', 'We have a house.', Icons.home_rounded, Colors.orange),
      _speaking('have_has_speaking_05', 'বলুন: তাদের অনেক বন্ধু আছে।', 'They have many friends.', Icons.groups_rounded, Colors.green),
    ],
  );

  static final RuleContent _had = RuleContent(
    id: 'had',
    order: 20,
    title: 'Had',
    shortMeaning: 'অতীতে কোনো কিছু ছিল বোঝাতে',
    usage:
    'অতীতে কারও কাছে কোনো কিছু ছিল বা কোনো অভিজ্ঞতা হয়েছিল বোঝাতে Had ব্যবহার হয়।',
    formula: 'Subject + had + object',
    category: 'Basics',
    level: RuleLevel.beginner,
    icon: Icons.history_rounded,
    color: AppColors.primary,
    keywords: <String>['Had', 'Past', 'Possession'],
    examples: <RuleExample>[
      _example('আমার একটি সাইকেল ছিল।', 'I had a bicycle.', 'bicycle'),
      _example('তার একটি পুরোনো ফোন ছিল।', 'He had an old phone.', 'old_phone'),
      _example('তার একটি সুন্দর পুতুল ছিল।', 'She had a beautiful doll.', 'doll'),
      _example('আমাদের একটি ছোট বাড়ি ছিল।', 'We had a small house.', 'small_house'),
      _example('তাদের একটি কুকুর ছিল।', 'They had a dog.', 'dog'),
      _example('তোমার অনেক কাজ ছিল।', 'You had a lot of work.', 'work'),
      _example('আমার গতকাল সময় ছিল।', 'I had time yesterday.', 'time'),
      _example('তার জ্বর ছিল।', 'He had a fever.', 'fever'),
      _example('তার একটি ভালো ধারণা ছিল।', 'She had a good idea.', 'idea'),
      _example('আমাদের একটি meeting ছিল।', 'We had a meeting.', 'meeting'),
      _example('তাদের একটি সমস্যা ছিল।', 'They had a problem.', 'problem'),
      _example('আমার একটি সুযোগ ছিল।', 'I had an opportunity.', 'opportunity'),
      _example('তার একটি সুন্দর অভিজ্ঞতা হয়েছিল।', 'He had a good experience.', 'experience'),
      _example('তোমার কোনো ভয় ছিল না।', 'You had no fear.', 'fear'),
      _example('আমাদের গতকাল class ছিল।', 'We had a class yesterday.', 'class'),
    ],
    tests: <RuleTest>[
      _test('had_test_01', 'I ___ a bicycle.', <String>['have', 'has', 'had'], 'had', 'অতীতের possession-এর জন্য had হবে।'),
      _test('had_test_02', 'She ___ a doll.', <String>['have', 'has', 'had'], 'had', 'সব subject-এর সঙ্গে past-এ had বসে।'),
      _test('had_test_03', 'They ___ a dog.', <String>['have', 'has', 'had'], 'had', 'অতীতে ছিল বোঝাতে had ব্যবহার হয়।'),
      _test('had_test_04', 'We ___ a meeting yesterday.', <String>['have', 'has', 'had'], 'had', 'Yesterday থাকলে past form had হবে।'),
      _test('had_test_05', 'He ___ a fever.', <String>['have', 'has', 'had'], 'had', 'অতীতের শারীরিক অবস্থা বোঝাতে had হবে।'),
      _test('had_test_06', 'আমার একটি সাইকেল ছিল।', <String>['I have a bicycle.', 'I had a bicycle.', 'I has a bicycle.'], 'I had a bicycle.', 'ছিল বোঝাতে had ব্যবহার হয়।'),
      _test('had_test_07', 'তার একটি ধারণা ছিল।', <String>['She had an idea.', 'She has an idea.', 'She have an idea.'], 'She had an idea.', 'Past possession-এর জন্য had হবে।'),
      _test('had_test_08', 'Choose the correct sentence:', <String>['We had a class.', 'We has a class.', 'We have a class yesterday.'], 'We had a class.', 'Past sentence-এ had সঠিক।'),
      _test('had_test_09', 'তাদের একটি সমস্যা ছিল।', <String>['They had a problem.', 'They has a problem.', 'They having a problem.'], 'They had a problem.', 'They-এর past form-এ had হয়।'),
      _test('had_test_10', 'তোমার কোনো ভয় ছিল না।', <String>['You had no fear.', 'You has no fear.', 'You have no fear yesterday.'], 'You had no fear.', 'অতীতের negative meaning-এ had no ব্যবহার হয়।'),
    ],
    speakingTests: <SpeakingTest>[
      _speaking('had_speaking_01', 'বলুন: আমার একটি সাইকেল ছিল।', 'I had a bicycle.', Icons.pedal_bike_rounded, AppColors.primary),
      _speaking('had_speaking_02', 'বলুন: তার একটি ফোন ছিল।', 'He had an old phone.', Icons.phone_android_rounded, Colors.blue),
      _speaking('had_speaking_03', 'বলুন: আমাদের একটি meeting ছিল।', 'We had a meeting.', Icons.meeting_room_rounded, Colors.orange),
      _speaking('had_speaking_04', 'বলুন: তাদের একটি কুকুর ছিল।', 'They had a dog.', Icons.pets_rounded, Colors.green),
      _speaking('had_speaking_05', 'বলুন: তার জ্বর ছিল।', 'He had a fever.', Icons.sick_rounded, Colors.red),
    ],
  );

  static final RuleContent _subjectVerbObject = RuleContent(
    id: 'subject_verb_object',
    order: 21,
    title: 'Subject + Verb + Object',
    shortMeaning: 'সাধারণ English sentence-এর সঠিক order',
    usage:
    'সাধারণ affirmative sentence তৈরি করতে Subject, Verb এবং Object সঠিক order-এ বসে।',
    formula: 'Subject + Verb + Object',
    category: 'Daily',
    level: RuleLevel.beginner,
    icon: Icons.account_tree_rounded,
    color: AppColors.purple,
    keywords: <String>['Subject', 'Verb', 'Object', 'Sentence Order'],
    examples: <RuleExample>[
      _example('আমি ভাত খাই।', 'I eat rice.', 'eat_rice'),
      _example('সে English শেখে।', 'She learns English.', 'learn_english'),
      _example('তুমি বই পড়ো।', 'You read a book.', 'read_book'),
      _example('সে ফুটবল খেলে।', 'He plays football.', 'play_football'),
      _example('আমরা গান শুনি।', 'We listen to music.', 'listen_music'),
      _example('তারা একটি বাড়ি বানায়।', 'They build a house.', 'build_house'),
      _example('আমি পানি পান করি।', 'I drink water.', 'drink_water'),
      _example('সে দরজা খোলে।', 'She opens the door.', 'open_door'),
      _example('তুমি English বলো।', 'You speak English.', 'speak_english'),
      _example('সে একটি ছবি আঁকে।', 'He draws a picture.', 'draw_picture'),
      _example('আমরা একটি movie দেখি।', 'We watch a movie.', 'watch_movie'),
      _example('তারা চিঠি লেখে।', 'They write a letter.', 'write_letter'),
      _example('আমি আমার কাজ করি।', 'I do my work.', 'do_work'),
      _example('সে কফি বানায়।', 'She makes coffee.', 'make_coffee'),
      _example('তুমি দরজাটি বন্ধ করো।', 'You close the door.', 'close_door'),
    ],
    tests: <RuleTest>[
      _test('subject_verb_object_test_01', 'সঠিক order কোনটি?', <String>['I eat rice.', 'Eat I rice.', 'Rice I eat.'], 'I eat rice.', 'সঠিক order: Subject + Verb + Object।'),
      _test('subject_verb_object_test_02', 'Choose the correct sentence:', <String>['She English learns.', 'She learns English.', 'Learns she English.'], 'She learns English.', 'She = Subject, learns = Verb, English = Object।'),
      _test('subject_verb_object_test_03', 'আমি পানি পান করি।', <String>['I water drink.', 'Water I drink.', 'I drink water.'], 'I drink water.', 'I + drink + water সঠিক order।'),
      _test('subject_verb_object_test_04', 'সে ফুটবল খেলে।', <String>['He football plays.', 'He plays football.', 'Football plays he.'], 'He plays football.', 'He + plays + football সঠিক।'),
      _test('subject_verb_object_test_05', 'তুমি বই পড়ো।', <String>['You read a book.', 'Read you a book.', 'A book you read.'], 'You read a book.', 'Subject প্রথমে বসে।'),
      _test('subject_verb_object_test_06', 'আমরা গান শুনি।', <String>['We music listen.', 'We listen to music.', 'Music we listen.'], 'We listen to music.', 'সঠিক sentence order হলো We + listen + music।'),
      _test('subject_verb_object_test_07', 'Choose the correct sentence:', <String>['They build a house.', 'They a house build.', 'Build they a house.'], 'They build a house.', 'Subject + Verb + Object।'),
      _test('subject_verb_object_test_08', 'সে দরজা খোলে।', <String>['She opens the door.', 'She the door opens.', 'Opens she the door.'], 'She opens the door.', 'She + opens + the door সঠিক।'),
      _test('subject_verb_object_test_09', 'আমি আমার কাজ করি।', <String>['I my work do.', 'I do my work.', 'Do I my work.'], 'I do my work.', 'সঠিক order: I + do + my work।'),
      _test('subject_verb_object_test_10', 'তুমি দরজা বন্ধ করো।', <String>['You close the door.', 'You the door close.', 'Close you the door.'], 'You close the door.', 'Subject প্রথমে এবং verb দ্বিতীয় অংশে বসে।'),
    ],
    speakingTests: <SpeakingTest>[
      _speaking('subject_verb_object_speaking_01', 'বলুন: আমি ভাত খাই।', 'I eat rice.', Icons.restaurant_rounded, AppColors.primary),
      _speaking('subject_verb_object_speaking_02', 'বলুন: সে English শেখে।', 'She learns English.', Icons.school_rounded, Colors.blue),
      _speaking('subject_verb_object_speaking_03', 'বলুন: তুমি বই পড়ো।', 'You read a book.', Icons.menu_book_rounded, Colors.deepPurple),
      _speaking('subject_verb_object_speaking_04', 'বলুন: সে ফুটবল খেলে।', 'He plays football.', Icons.sports_soccer_rounded, Colors.orange),
      _speaking('subject_verb_object_speaking_05', 'বলুন: তারা একটি বাড়ি বানায়।', 'They build a house.', Icons.home_work_rounded, Colors.green),
    ],
  );
}