import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch02Rules {
  static final List<RuleContent> rules = <RuleContent>[
    _theseThose,
    _hereThere,
    _thereIsAre,
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

  static final RuleContent _theseThose = RuleContent(
    id: 'these_those',
    order: 4,
    title: 'These & Those',
    shortMeaning: 'কাছের ও দূরের একাধিক বস্তু বোঝাতে',
    usage:
    'কাছের একাধিক ব্যক্তি বা বস্তু বোঝাতে These এবং দূরের একাধিক ব্যক্তি বা বস্তু বোঝাতে Those ব্যবহার হয়।',
    formula: 'These/Those + are + plural noun',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.groups_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'These',
      'Those',
      'Near',
      'Far',
      'Plural',
    ],
    examples: <RuleExample>[
      _example('এগুলো আমার বই।', 'These are my books.', 'books_near'),
      _example('এগুলো আপেল।', 'These are apples.', 'apples_near'),
      _example('এগুলো আমার জুতা।', 'These are my shoes.', 'shoes_near'),
      _example('এগুলো নতুন কলম।', 'These are new pens.', 'pens_near'),
      _example('এরা আমার বন্ধু।', 'These are my friends.', 'friends_near'),
      _example(
        'এগুলো সুন্দর ফুল।',
        'These are beautiful flowers.',
        'flowers_near',
      ),
      _example('ওগুলো তোমার ব্যাগ।', 'Those are your bags.', 'bags_far'),
      _example('ওগুলো বড় বাড়ি।', 'Those are big houses.', 'houses_far'),
      _example('ওগুলো পাখি।', 'Those are birds.', 'birds_far'),
      _example('ওরা আমার শিক্ষক।', 'Those are my teachers.', 'teachers_far'),
      _example(
        'এগুলো আমার চাবি নয়।',
        'These are not my keys.',
        'keys_near',
        type: RuleExampleType.negative,
      ),
      _example(
        'ওগুলো গাড়ি নয়।',
        'Those are not cars.',
        'cars_far',
        type: RuleExampleType.negative,
      ),
      _example('এগুলো লাল বল।', 'These are red balls.', 'balls_near'),
      _example('ওগুলো পুরোনো গাছ।', 'Those are old trees.', 'trees_far'),
      _example('এগুলো আমাদের চেয়ার।', 'These are our chairs.', 'chairs_near'),
    ],
    tests: <RuleTest>[
      _test(
        'these_those_test_01',
        '___ are my books. (near)',
        <String>['These', 'Those', 'This'],
        'These',
        'কাছের একাধিক জিনিসের জন্য These ব্যবহার হয়।',
      ),
      _test(
        'these_those_test_02',
        '___ are your bags. (far)',
        <String>['These', 'Those', 'That'],
        'Those',
        'দূরের একাধিক জিনিসের জন্য Those ব্যবহার হয়।',
      ),
      _test(
        'these_those_test_03',
        'Choose the correct sentence:',
        <String>[
          'These is my books.',
          'These are my books.',
          'These am my books.',
        ],
        'These are my books.',
        'These-এর সঙ্গে are বসে।',
      ),
      _test(
        'these_those_test_04',
        'Choose the correct sentence:',
        <String>[
          'Those are big houses.',
          'Those is big houses.',
          'Those am big houses.',
        ],
        'Those are big houses.',
        'Those-এর সঙ্গে are বসে।',
      ),
      _test(
        'these_those_test_05',
        'এগুলো নতুন কলম।',
        <String>[
          'These are new pens.',
          'Those is new pens.',
          'This are new pens.',
        ],
        'These are new pens.',
        'কাছের একাধিক কলমের জন্য These হবে।',
      ),
      _test(
        'these_those_test_06',
        'ওগুলো পাখি।',
        <String>[
          'These are birds.',
          'Those are birds.',
          'That is birds.',
        ],
        'Those are birds.',
        'দূরের একাধিক পাখির জন্য Those হবে।',
      ),
      _test(
        'these_those_test_07',
        '___ are my shoes. (near)',
        <String>['These', 'Those', 'That'],
        'These',
        'কাছের একাধিক জুতার জন্য These হবে।',
      ),
      _test(
        'these_those_test_08',
        '___ are old trees. (far)',
        <String>['These', 'Those', 'This'],
        'Those',
        'দূরের একাধিক গাছের জন্য Those হবে।',
      ),
      _test(
        'these_those_test_09',
        'Choose the correct sentence:',
        <String>[
          'Those are not cars.',
          'Those is not cars.',
          'Those am not cars.',
        ],
        'Those are not cars.',
        'Negative sentence-এ Those-এর সঙ্গে are not বসে।',
      ),
      _test(
        'these_those_test_10',
        'এগুলো আমার বন্ধু।',
        <String>[
          'These are my friends.',
          'This is my friends.',
          'Those is my friends.',
        ],
        'These are my friends.',
        'কাছের একাধিক বন্ধুর জন্য These are ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'these_those_speaking_01',
        'কাছের কয়েকটি বই দেখে বলুন।',
        'These are my books.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'these_those_speaking_02',
        'দূরের কয়েকটি গাড়ি দেখে বলুন।',
        'Those are cars.',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'these_those_speaking_03',
        'কাছের কয়েকটি ফুল দেখে বলুন।',
        'These are beautiful flowers.',
        Icons.local_florist_rounded,
        Colors.pink,
      ),
      _speaking(
        'these_those_speaking_04',
        'দূরের কয়েকটি বাড়ি দেখে বলুন।',
        'Those are big houses.',
        Icons.home_rounded,
        Colors.orange,
      ),
      _speaking(
        'these_those_speaking_05',
        'কাছের কয়েকজন বন্ধুকে দেখিয়ে বলুন।',
        'These are my friends.',
        Icons.groups_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _hereThere = RuleContent(
    id: 'here_there',
    order: 5,
    title: 'Here & There',
    shortMeaning: 'এখানে ও সেখানে অবস্থান বোঝাতে',
    usage:
    'বক্তার কাছের স্থান বোঝাতে Here এবং দূরের স্থান বোঝাতে There ব্যবহার হয়।',
    formula: 'Subject + Verb + Here/There',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.place_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'Here',
      'There',
      'Near',
      'Far',
      'Place',
    ],
    examples: <RuleExample>[
      _example('আমি এখানে আছি।', 'I am here.', 'person_here'),
      _example('এখানে এসো।', 'Come here.', 'come_here'),
      _example('বইটি এখানে আছে।', 'The book is here.', 'book_here'),
      _example('সে এখানে থাকে।', 'She lives here.', 'home_here'),
      _example('তোমার ফোন এখানে আছে।', 'Your phone is here.', 'phone_here'),
      _example('এখানে থাকো।', 'Stay here.', 'stay_here'),
      _example('সে সেখানে আছে।', 'He is there.', 'person_there'),
      _example('স্কুলটি সেখানে আছে।', 'The school is there.', 'school_there'),
      _example('ব্যাগটি সেখানে রাখো।', 'Put the bag there.', 'bag_there'),
      _example('তারা সেখানে কাজ করে।', 'They work there.', 'work_there'),
      _example('আমার বন্ধু সেখানে আছে।', 'My friend is there.', 'friend_there'),
      _example('বাসটি সেখানে আছে।', 'The bus is there.', 'bus_there'),
      _example(
        'আমি সেখানে নেই।',
        'I am not there.',
        'not_there',
        type: RuleExampleType.negative,
      ),
      _example('দয়া করে এখানে এসো।', 'Please come here.', 'please_here'),
      _example('ওদিকে তাকাও।', 'Look there.', 'look_there'),
    ],
    tests: <RuleTest>[
      _test(
        'here_there_test_01',
        'I am ___. (near)',
        <String>['here', 'there', 'those'],
        'here',
        'কাছের স্থান বোঝাতে here ব্যবহার হয়।',
      ),
      _test(
        'here_there_test_02',
        'He is ___. (far)',
        <String>['here', 'there', 'these'],
        'there',
        'দূরের স্থান বোঝাতে there ব্যবহার হয়।',
      ),
      _test(
        'here_there_test_03',
        '___ here, please.',
        <String>['Come', 'Go', 'Put'],
        'Come',
        'কাছের স্থানে আসতে Come here বলা হয়।',
      ),
      _test(
        'here_there_test_04',
        'Put the bag ___.',
        <String>['here', 'there', 'these'],
        'there',
        'দূরের জায়গা বোঝালে there ব্যবহার হয়।',
      ),
      _test(
        'here_there_test_05',
        'The book is ___. (near)',
        <String>['here', 'there', 'those'],
        'here',
        'বইটি কাছের জায়গায় থাকলে here হবে।',
      ),
      _test(
        'here_there_test_06',
        'The school is ___. (far)',
        <String>['here', 'there', 'this'],
        'there',
        'স্কুলটি দূরে থাকলে there হবে।',
      ),
      _test(
        'here_there_test_07',
        'Choose the correct sentence:',
        <String>[
          'I am here.',
          'I is here.',
          'I are here.',
        ],
        'I am here.',
        'I-এর সঙ্গে am বসে।',
      ),
      _test(
        'here_there_test_08',
        'Choose the correct sentence:',
        <String>[
          'They work there.',
          'They works there.',
          'They working there.',
        ],
        'They work there.',
        'They-এর সঙ্গে base verb work ব্যবহার হয়।',
      ),
      _test(
        'here_there_test_09',
        'আমি সেখানে নেই।',
        <String>[
          'I am not here.',
          'I am not there.',
          'I is not there.',
        ],
        'I am not there.',
        'দূরের স্থান বোঝাতে there ব্যবহার হয়।',
      ),
      _test(
        'here_there_test_10',
        'তোমার ফোন এখানে আছে।',
        <String>[
          'Your phone is here.',
          'Your phone are here.',
          'Your phone is there.',
        ],
        'Your phone is here.',
        'কাছের স্থান বোঝাতে here ব্যবহার হয়।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'here_there_speaking_01',
        'বলুন: আমি এখানে আছি।',
        'I am here.',
        Icons.person_pin_rounded,
        AppColors.primary,
      ),
      _speaking(
        'here_there_speaking_02',
        'বলুন: এখানে এসো।',
        'Come here.',
        Icons.login_rounded,
        Colors.blue,
      ),
      _speaking(
        'here_there_speaking_03',
        'বলুন: সে সেখানে আছে।',
        'He is there.',
        Icons.person_rounded,
        Colors.deepPurple,
      ),
      _speaking(
        'here_there_speaking_04',
        'বলুন: ব্যাগটি সেখানে রাখো।',
        'Put the bag there.',
        Icons.work_rounded,
        Colors.orange,
      ),
      _speaking(
        'here_there_speaking_05',
        'বলুন: তোমার ফোন এখানে আছে।',
        'Your phone is here.',
        Icons.phone_android_rounded,
        Colors.green,
      ),
    ],
  );

  static final RuleContent _thereIsAre = RuleContent(
    id: 'there_is_are',
    order: 6,
    title: 'There is & There are',
    shortMeaning: 'কোনো কিছু আছে বোঝাতে',
    usage:
    'একটি বস্তু আছে বোঝাতে There is এবং একাধিক বস্তু আছে বোঝাতে There are ব্যবহার হয়।',
    formula: 'There is + singular noun | There are + plural noun',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.add_home_rounded,
    color: AppColors.primary,
    keywords: <String>[
      'There is',
      'There are',
      'Singular',
      'Plural',
      'Existence',
    ],
    examples: <RuleExample>[
      _example('টেবিলের উপর একটি বই আছে।', 'There is a book on the table.', 'book_table'),
      _example('ঘরে একটি চেয়ার আছে।', 'There is a chair in the room.', 'chair_room'),
      _example('বাগানে একটি গাছ আছে।', 'There is a tree in the garden.', 'tree_garden'),
      _example('রাস্তায় একটি গাড়ি আছে।', 'There is a car on the road.', 'car_road'),
      _example('ব্যাগে একটি কলম আছে।', 'There is a pen in the bag.', 'pen_bag'),
      _example('ক্লাসে তিনজন ছাত্র আছে.', 'There are three students in the class.', 'students_class'),
      _example('বাগানে অনেক ফুল আছে।', 'There are many flowers in the garden.', 'flowers_garden'),
      _example('রাস্তায় দুটি বাস আছে।', 'There are two buses on the road.', 'buses_road'),
      _example('টেবিলে কিছু বই আছে।', 'There are some books on the table.', 'books_table'),
      _example('ঘরে চারটি জানালা আছে।', 'There are four windows in the room.', 'windows_room'),
      _example('বক্সে একটি ফোন নেই।', 'There is not a phone in the box.', 'phone_box'),
      _example('এখানে কোনো চেয়ার নেই।', 'There are no chairs here.', 'chairs_none'),
      _example('দেয়ালে একটি ছবি আছে।', 'There is a picture on the wall.', 'picture_wall'),
      _example('রান্নাঘরে দুটি কাপ আছে।', 'There are two cups in the kitchen.', 'cups_kitchen'),
      _example('এই এলাকায় একটি পার্ক আছে।', 'There is a park in this area.', 'park_area'),
    ],
    tests: <RuleTest>[
      _test(
        'there_is_are_test_01',
        'There ___ a book on the table.',
        <String>['is', 'are', 'am'],
        'is',
        'একটি book singular, তাই There is হবে।',
      ),
      _test(
        'there_is_are_test_02',
        'There ___ two cars on the road.',
        <String>['is', 'are', 'am'],
        'are',
        'দুটি car plural, তাই There are হবে।',
      ),
      _test(
        'there_is_are_test_03',
        'There ___ a chair in the room.',
        <String>['is', 'are', 'be'],
        'is',
        'একটি chair-এর সঙ্গে There is হবে।',
      ),
      _test(
        'there_is_are_test_04',
        'There ___ many flowers in the garden.',
        <String>['is', 'are', 'am'],
        'are',
        'Many flowers plural, তাই There are হবে।',
      ),
      _test(
        'there_is_are_test_05',
        'টেবিলে একটি কলম আছে।',
        <String>[
          'There is a pen on the table.',
          'There are a pen on the table.',
          'There am a pen on the table.',
        ],
        'There is a pen on the table.',
        'একটি pen-এর জন্য There is হবে।',
      ),
      _test(
        'there_is_are_test_06',
        'ক্লাসে তিনজন ছাত্র আছে।',
        <String>[
          'There is three students in the class.',
          'There are three students in the class.',
          'There am three students in the class.',
        ],
        'There are three students in the class.',
        'তিনজন students plural, তাই There are হবে।',
      ),
      _test(
        'there_is_are_test_07',
        'Choose the correct sentence:',
        <String>[
          'There is a tree in the garden.',
          'There are a tree in the garden.',
          'There am a tree in the garden.',
        ],
        'There is a tree in the garden.',
        'একটি tree singular।',
      ),
      _test(
        'there_is_are_test_08',
        'Choose the correct sentence:',
        <String>[
          'There is two cups in the kitchen.',
          'There are two cups in the kitchen.',
          'There am two cups in the kitchen.',
        ],
        'There are two cups in the kitchen.',
        'দুটি cups plural।',
      ),
      _test(
        'there_is_are_test_09',
        'বক্সে একটি ফোন নেই।',
        <String>[
          'There are not a phone in the box.',
          'There is not a phone in the box.',
          'There am not a phone in the box.',
        ],
        'There is not a phone in the box.',
        'একটি phone-এর negative form হলো There is not।',
      ),
      _test(
        'there_is_are_test_10',
        'এখানে কোনো চেয়ার নেই।',
        <String>[
          'There is no chairs here.',
          'There are no chairs here.',
          'There am no chairs here.',
        ],
        'There are no chairs here.',
        'Chairs plural, তাই There are হবে।',
      ),
    ],
    speakingTests: <SpeakingTest>[
      _speaking(
        'there_is_are_speaking_01',
        'বলুন: টেবিলে একটি বই আছে।',
        'There is a book on the table.',
        Icons.menu_book_rounded,
        AppColors.primary,
      ),
      _speaking(
        'there_is_are_speaking_02',
        'বলুন: বাগানে অনেক ফুল আছে।',
        'There are many flowers in the garden.',
        Icons.local_florist_rounded,
        Colors.pink,
      ),
      _speaking(
        'there_is_are_speaking_03',
        'বলুন: রাস্তায় একটি গাড়ি আছে।',
        'There is a car on the road.',
        Icons.directions_car_rounded,
        Colors.blue,
      ),
      _speaking(
        'there_is_are_speaking_04',
        'বলুন: রান্নাঘরে দুটি কাপ আছে।',
        'There are two cups in the kitchen.',
        Icons.local_cafe_rounded,
        Colors.orange,
      ),
      _speaking(
        'there_is_are_speaking_05',
        'বলুন: এই এলাকায় একটি পার্ক আছে।',
        'There is a park in this area.',
        Icons.park_rounded,
        Colors.green,
      ),
    ],
  );
}