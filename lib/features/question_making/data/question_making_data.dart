import 'package:flutter/material.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';

abstract final class QuestionMakingData {
  static final List<QuestionMakingTopic> topics = _buildAndValidate();

  static List<QuestionMakingTopic> _buildAndValidate() {
    final List<QuestionMakingTopic> result = _topicSpecs
        .map(_createTopic)
        .toList(growable: false);

    if (result.length != 30) {
      throw StateError(
        'Question Making must contain exactly 30 topics. '
            'Found: ${result.length}',
      );
    }

    final Set<String> topicIds = <String>{};

    for (final QuestionMakingTopic topic in result) {
      if (!topicIds.add(topic.id)) {
        throw StateError('Duplicate topic ID: ${topic.id}');
      }

      if (topic.questions.length != 25) {
        throw StateError(
          '${topic.id} must contain exactly 25 questions. '
              'Found: ${topic.questions.length}',
        );
      }

      final Set<String> questionIds = <String>{};
      final Set<String> englishQuestions = <String>{};

      for (final QuestionMakingItem question in topic.questions) {
        if (!questionIds.add(question.id)) {
          throw StateError(
            'Duplicate question ID: ${question.id}',
          );
        }

        if (!englishQuestions.add(question.english.toLowerCase())) {
          throw StateError(
            'Duplicate English question in ${topic.id}: '
                '${question.english}',
          );
        }

        if (!question.english.trim().endsWith('?')) {
          throw StateError(
            'Question mark missing: ${question.english}',
          );
        }
      }
    }

    return List<QuestionMakingTopic>.unmodifiable(result);
  }

  static QuestionMakingTopic _createTopic(_TopicSpec spec) {
    return QuestionMakingTopic(
      id: spec.id,
      title: spec.title,
      subtitle: spec.subtitle,
      icon: spec.icon,
      color: spec.color,
      questions: _createQuestions(spec),
    );
  }

  static List<QuestionMakingItem> _createQuestions(
      _TopicSpec spec,
      ) {
    final List<_QuestionPair> pairs = <_QuestionPair>[
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} চাও?',
        'Do you want to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} পছন্দ করো?',
        'Do you like to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তোমার কি ${spec.focusBangla} প্রয়োজন?',
        'Do you need to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তোমার কি ${spec.banglaTo} সময় আছে?',
        'Do you have time to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} পারো?',
        'Can you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি এখন ${spec.banglaTo} পারো?',
        'Can you ${spec.verbBase} now?',
      ),
      _QuestionPair(
        'তুমি কি আজ ${spec.banglaTo} পারবে?',
        'Could you ${spec.verbBase} today?',
      ),
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} আগ্রহী?',
        'Are you interested in ${spec.verbIng}?',
      ),
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} প্রস্তুত?',
        'Are you ready to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} পরিকল্পনা করছো?',
        'Are you planning to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি ${spec.banglaTo} ইচ্ছুক?',
        'Would you like to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কখন ${spec.banglaTo} চাও?',
        'When do you want to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কোথায় ${spec.banglaTo} চাও?',
        'Where do you want to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কেন ${spec.banglaTo} চাও?',
        'Why do you want to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কীভাবে ${spec.banglaTo} চাও?',
        'How do you want to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'কে তোমার সঙ্গে ${spec.banglaTo} চায়?',
        'Who wants to ${spec.verbBase} with you?',
      ),
      _QuestionPair(
        'তুমি কত ঘনঘন ${spec.banglaTo} পছন্দ করো?',
        'How often do you like to ${spec.verbBase}?',
      ),
      _QuestionPair(
        '${spec.banglaTo} তোমার কত সময় প্রয়োজন?',
        'How much time do you need to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'কে তোমাকে ${spec.banglaTo} সাহায্য করতে পারে?',
        'Who can help you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি জানো কীভাবে ${spec.banglaTo} হয়?',
        'Do you know how to ${spec.verbBase}?',
      ),
      _QuestionPair(
        '${spec.focusBangla} কি সহজ?',
        'Is ${spec.verbIng} easy?',
      ),
      _QuestionPair(
        '${spec.focusBangla} কি কঠিন?',
        'Is ${spec.verbIng} difficult?',
      ),
      _QuestionPair(
        '${spec.focusBangla} কি গুরুত্বপূর্ণ?',
        'Is ${spec.verbIng} important?',
      ),
      _QuestionPair(
        '${spec.focusBangla} কি সম্ভব?',
        'Is it possible to ${spec.verbBase}?',
      ),
      _QuestionPair(
        '${spec.banglaTo} তোমার কী প্রয়োজন?',
        'What do you need to ${spec.verbBase}?',
      ),
    ];

    return List<QuestionMakingItem>.generate(
      pairs.length,
          (int index) {
        final _QuestionPair pair = pairs[index];

        return QuestionMakingItem(
          id: '${spec.id}_${index + 1}',
          bengali: pair.bengali,
          english: pair.english,
          explanation: _explanationFor(pair.english),
          visualKey: spec.id,
          icon: spec.icon,
          color: spec.color,
        );
      },
      growable: false,
    );
  }

  static String _explanationFor(String question) {
    if (question.startsWith('Do ')) {
      return 'Do + subject + base verb ব্যবহার করে প্রশ্ন তৈরি হয়।';
    }

    if (question.startsWith('Can ')) {
      return 'Can + subject + base verb দিয়ে ক্ষমতা সম্পর্কে প্রশ্ন করা হয়।';
    }

    if (question.startsWith('Could ')) {
      return 'Could + subject + base verb দিয়ে ভদ্রভাবে প্রশ্ন করা হয়।';
    }

    if (question.startsWith('Would ')) {
      return 'Would + subject + like to + base verb দিয়ে ইচ্ছা জানতে চাওয়া হয়।';
    }

    if (question.startsWith('Are ')) {
      return 'Are + subject + complement ব্যবহার করে প্রশ্ন তৈরি হয়।';
    }

    if (question.startsWith('Is ')) {
      return 'Is দিয়ে কোনো কাজের অবস্থা বা বৈশিষ্ট্য জানতে চাওয়া হয়।';
    }

    if (question.startsWith('When ')) {
      return 'When দিয়ে কোনো কাজের সময় জানতে চাওয়া হয়।';
    }

    if (question.startsWith('Where ')) {
      return 'Where দিয়ে কোনো কাজের স্থান জানতে চাওয়া হয়।';
    }

    if (question.startsWith('Why ')) {
      return 'Why দিয়ে কোনো কাজের কারণ জানতে চাওয়া হয়।';
    }

    if (question.startsWith('How often ')) {
      return 'How often দিয়ে কোনো কাজ কত ঘনঘন হয় তা জানতে চাওয়া হয়।';
    }

    if (question.startsWith('How much time ')) {
      return 'How much time দিয়ে প্রয়োজনীয় সময় জানতে চাওয়া হয়।';
    }

    if (question.startsWith('How ')) {
      return 'How দিয়ে কোনো কাজের পদ্ধতি জানতে চাওয়া হয়।';
    }

    if (question.startsWith('Who ')) {
      return 'Who দিয়ে ব্যক্তি সম্পর্কে প্রশ্ন করা হয়।';
    }

    if (question.startsWith('What ')) {
      return 'What দিয়ে প্রয়োজনীয় বিষয় সম্পর্কে প্রশ্ন করা হয়।';
    }

    return 'Question word, helping verb, subject এবং main verb-এর সঠিক order অনুসরণ করুন।';
  }

  static const List<_TopicSpec> _topicSpecs = <_TopicSpec>[
    _TopicSpec(
      id: 'wh_questions',
      title: 'WH Questions',
      subtitle: 'What, Why, Where, When',
      focusBangla: 'প্রশ্ন করা',
      banglaTo: 'প্রশ্ন করতে',
      verbBase: 'ask questions',
      verbIng: 'asking questions',
      icon: Icons.help_rounded,
      color: Colors.green,
    ),
    _TopicSpec(
      id: 'do_does_questions',
      title: 'Do / Does Questions',
      subtitle: 'দৈনন্দিন প্রশ্ন',
      focusBangla: 'ইংরেজি অনুশীলন করা',
      banglaTo: 'ইংরেজি অনুশীলন করতে',
      verbBase: 'practice English',
      verbIng: 'practicing English',
      icon: Icons.question_answer_rounded,
      color: Colors.blue,
    ),
    _TopicSpec(
      id: 'is_am_are_questions',
      title: 'Is / Am / Are Questions',
      subtitle: 'অবস্থা ও পরিচয়',
      focusBangla: 'ইংরেজি পড়া',
      banglaTo: 'ইংরেজি পড়তে',
      verbBase: 'study English',
      verbIng: 'studying English',
      icon: Icons.person_search_rounded,
      color: Colors.deepPurple,
    ),
    _TopicSpec(
      id: 'can_could_questions',
      title: 'Can / Could Questions',
      subtitle: 'ক্ষমতা ও অনুরোধ',
      focusBangla: 'বন্ধুকে সাহায্য করা',
      banglaTo: 'বন্ধুকে সাহায্য করতে',
      verbBase: 'help your friend',
      verbIng: 'helping your friend',
      icon: Icons.volunteer_activism_rounded,
      color: Colors.orange,
    ),
    _TopicSpec(
      id: 'will_would_questions',
      title: 'Will / Would Questions',
      subtitle: 'ভবিষ্যৎ ও ইচ্ছা',
      focusBangla: 'পরিবারের সঙ্গে দেখা করা',
      banglaTo: 'পরিবারের সঙ্গে দেখা করতে',
      verbBase: 'visit your family',
      verbIng: 'visiting your family',
      icon: Icons.event_available_rounded,
      color: Colors.teal,
    ),
    _TopicSpec(
      id: 'did_questions',
      title: 'Did Questions',
      subtitle: 'অতীতের প্রশ্ন',
      focusBangla: 'একটি সিনেমা দেখা',
      banglaTo: 'একটি সিনেমা দেখতে',
      verbBase: 'watch a movie',
      verbIng: 'watching a movie',
      icon: Icons.movie_rounded,
      color: Colors.red,
    ),
    _TopicSpec(
      id: 'have_has_questions',
      title: 'Have / Has Questions',
      subtitle: 'অভিজ্ঞতা ও মালিকানা',
      focusBangla: 'সকালের নাশতা করা',
      banglaTo: 'সকালের নাশতা করতে',
      verbBase: 'have breakfast',
      verbIng: 'having breakfast',
      icon: Icons.free_breakfast_rounded,
      color: Colors.amber,
    ),
    _TopicSpec(
      id: 'where_questions',
      title: 'Where Questions',
      subtitle: 'স্থান সম্পর্কে প্রশ্ন',
      focusBangla: 'বাজারে যাওয়া',
      banglaTo: 'বাজারে যেতে',
      verbBase: 'go to the market',
      verbIng: 'going to the market',
      icon: Icons.location_on_rounded,
      color: Colors.green,
    ),
    _TopicSpec(
      id: 'what_questions',
      title: 'What Questions',
      subtitle: 'কী সম্পর্কে প্রশ্ন',
      focusBangla: 'দুপুরের খাবার খাওয়া',
      banglaTo: 'দুপুরের খাবার খেতে',
      verbBase: 'eat lunch',
      verbIng: 'eating lunch',
      icon: Icons.restaurant_rounded,
      color: Colors.orange,
    ),
    _TopicSpec(
      id: 'why_questions',
      title: 'Why Questions',
      subtitle: 'কারণ সম্পর্কে প্রশ্ন',
      focusBangla: 'ইংরেজি শেখা',
      banglaTo: 'ইংরেজি শিখতে',
      verbBase: 'learn English',
      verbIng: 'learning English',
      icon: Icons.lightbulb_rounded,
      color: Colors.amber,
    ),
    _TopicSpec(
      id: 'when_questions',
      title: 'When Questions',
      subtitle: 'সময় সম্পর্কে প্রশ্ন',
      focusBangla: 'বাড়িতে আসা',
      banglaTo: 'বাড়িতে আসতে',
      verbBase: 'come home',
      verbIng: 'coming home',
      icon: Icons.access_time_rounded,
      color: Colors.blue,
    ),
    _TopicSpec(
      id: 'who_questions',
      title: 'Who Questions',
      subtitle: 'ব্যক্তি সম্পর্কে প্রশ্ন',
      focusBangla: 'বন্ধুকে ফোন করা',
      banglaTo: 'বন্ধুকে ফোন করতে',
      verbBase: 'call your friend',
      verbIng: 'calling your friend',
      icon: Icons.people_rounded,
      color: Colors.purple,
    ),
    _TopicSpec(
      id: 'how_questions',
      title: 'How Questions',
      subtitle: 'পদ্ধতি সম্পর্কে প্রশ্ন',
      focusBangla: 'বাসে ভ্রমণ করা',
      banglaTo: 'বাসে ভ্রমণ করতে',
      verbBase: 'travel by bus',
      verbIng: 'traveling by bus',
      icon: Icons.directions_bus_rounded,
      color: Colors.teal,
    ),
    _TopicSpec(
      id: 'how_many_questions',
      title: 'How Many Questions',
      subtitle: 'গণনাযোগ্য বিষয়',
      focusBangla: 'বই পড়া',
      banglaTo: 'বই পড়তে',
      verbBase: 'read books',
      verbIng: 'reading books',
      icon: Icons.menu_book_rounded,
      color: Colors.indigo,
    ),
    _TopicSpec(
      id: 'how_much_questions',
      title: 'How Much Questions',
      subtitle: 'পরিমাণ ও টাকা',
      focusBangla: 'টাকা খরচ করা',
      banglaTo: 'টাকা খরচ করতে',
      verbBase: 'spend money',
      verbIng: 'spending money',
      icon: Icons.payments_rounded,
      color: Colors.green,
    ),
    _TopicSpec(
      id: 'daily_routine_questions',
      title: 'Daily Routine Questions',
      subtitle: 'প্রতিদিনের কাজ',
      focusBangla: 'সকালে তাড়াতাড়ি ওঠা',
      banglaTo: 'সকালে তাড়াতাড়ি উঠতে',
      verbBase: 'wake up early',
      verbIng: 'waking up early',
      icon: Icons.wb_sunny_rounded,
      color: Colors.orange,
    ),
    _TopicSpec(
      id: 'family_questions',
      title: 'Family Questions',
      subtitle: 'পরিবার নিয়ে প্রশ্ন',
      focusBangla: 'পরিবারের সঙ্গে কথা বলা',
      banglaTo: 'পরিবারের সঙ্গে কথা বলতে',
      verbBase: 'talk to your family',
      verbIng: 'talking to your family',
      icon: Icons.family_restroom_rounded,
      color: Colors.pink,
    ),
    _TopicSpec(
      id: 'school_questions',
      title: 'School Questions',
      subtitle: 'পড়াশোনা নিয়ে প্রশ্ন',
      focusBangla: 'ক্লাসে অংশ নেওয়া',
      banglaTo: 'ক্লাসে অংশ নিতে',
      verbBase: 'attend class',
      verbIng: 'attending class',
      icon: Icons.school_rounded,
      color: Colors.blue,
    ),
    _TopicSpec(
      id: 'work_questions',
      title: 'Work Questions',
      subtitle: 'কাজ নিয়ে প্রশ্ন',
      focusBangla: 'কাজ শেষ করা',
      banglaTo: 'কাজ শেষ করতে',
      verbBase: 'finish your work',
      verbIng: 'finishing your work',
      icon: Icons.work_rounded,
      color: Colors.teal,
    ),
    _TopicSpec(
      id: 'shopping_questions',
      title: 'Shopping Questions',
      subtitle: 'কেনাকাটা নিয়ে প্রশ্ন',
      focusBangla: 'কাপড় কেনা',
      banglaTo: 'কাপড় কিনতে',
      verbBase: 'buy clothes',
      verbIng: 'buying clothes',
      icon: Icons.shopping_bag_rounded,
      color: Colors.purple,
    ),
    _TopicSpec(
      id: 'travel_questions',
      title: 'Travel Questions',
      subtitle: 'ভ্রমণ নিয়ে প্রশ্ন',
      focusBangla: 'নতুন জায়গায় ভ্রমণ করা',
      banglaTo: 'নতুন জায়গায় ভ্রমণ করতে',
      verbBase: 'visit a new place',
      verbIng: 'visiting a new place',
      icon: Icons.travel_explore_rounded,
      color: Colors.green,
    ),
    _TopicSpec(
      id: 'restaurant_questions',
      title: 'Restaurant Questions',
      subtitle: 'রেস্টুরেন্টে প্রশ্ন',
      focusBangla: 'খাবার অর্ডার করা',
      banglaTo: 'খাবার অর্ডার করতে',
      verbBase: 'order food',
      verbIng: 'ordering food',
      icon: Icons.restaurant_menu_rounded,
      color: Colors.red,
    ),
    _TopicSpec(
      id: 'phone_questions',
      title: 'Phone Conversation',
      subtitle: 'ফোনে কথা বলা',
      focusBangla: 'বন্ধুকে ফোন করা',
      banglaTo: 'বন্ধুকে ফোন করতে',
      verbBase: 'call your friend',
      verbIng: 'calling your friend',
      icon: Icons.phone_rounded,
      color: Colors.deepPurple,
    ),
    _TopicSpec(
      id: 'health_questions',
      title: 'Health Questions',
      subtitle: 'স্বাস্থ্য নিয়ে প্রশ্ন',
      focusBangla: 'ওষুধ খাওয়া',
      banglaTo: 'ওষুধ খেতে',
      verbBase: 'take medicine',
      verbIng: 'taking medicine',
      icon: Icons.health_and_safety_rounded,
      color: Colors.red,
    ),
    _TopicSpec(
      id: 'hobbies_questions',
      title: 'Hobbies Questions',
      subtitle: 'শখ নিয়ে প্রশ্ন',
      focusBangla: 'ফুটবল খেলা',
      banglaTo: 'ফুটবল খেলতে',
      verbBase: 'play football',
      verbIng: 'playing football',
      icon: Icons.sports_soccer_rounded,
      color: Colors.green,
    ),
    _TopicSpec(
      id: 'plans_questions',
      title: 'Plans Questions',
      subtitle: 'পরিকল্পনা নিয়ে প্রশ্ন',
      focusBangla: 'একটি পরিকল্পনা করা',
      banglaTo: 'একটি পরিকল্পনা করতে',
      verbBase: 'make a plan',
      verbIng: 'making a plan',
      icon: Icons.event_note_rounded,
      color: Colors.blue,
    ),
    _TopicSpec(
      id: 'permission_questions',
      title: 'Permission Questions',
      subtitle: 'অনুমতি চাওয়া',
      focusBangla: 'জানালা খোলা',
      banglaTo: 'জানালা খুলতে',
      verbBase: 'open the window',
      verbIng: 'opening the window',
      icon: Icons.lock_open_rounded,
      color: Colors.orange,
    ),
    _TopicSpec(
      id: 'request_questions',
      title: 'Request Questions',
      subtitle: 'অনুরোধ করা',
      focusBangla: 'আমাকে সাহায্য করা',
      banglaTo: 'আমাকে সাহায্য করতে',
      verbBase: 'help me',
      verbIng: 'helping me',
      icon: Icons.handshake_rounded,
      color: Colors.teal,
    ),
    _TopicSpec(
      id: 'opinion_questions',
      title: 'Opinion Questions',
      subtitle: 'মতামত জানতে প্রশ্ন',
      focusBangla: 'নিজের মতামত জানানো',
      banglaTo: 'নিজের মতামত জানাতে',
      verbBase: 'share your opinion',
      verbIng: 'sharing your opinion',
      icon: Icons.forum_rounded,
      color: Colors.purple,
    ),
    _TopicSpec(
      id: 'mixed_questions',
      title: 'Mixed Questions',
      subtitle: 'সব ধরনের প্রশ্ন',
      focusBangla: 'ইংরেজি অনুশীলন করা',
      banglaTo: 'ইংরেজি অনুশীলন করতে',
      verbBase: 'practice English',
      verbIng: 'practicing English',
      icon: Icons.auto_awesome_rounded,
      color: Colors.indigo,
    ),
  ];
}

class _TopicSpec {
  final String id;
  final String title;
  final String subtitle;
  final String focusBangla;
  final String banglaTo;
  final String verbBase;
  final String verbIng;
  final IconData icon;
  final Color color;

  const _TopicSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.focusBangla,
    required this.banglaTo,
    required this.verbBase,
    required this.verbIng,
    required this.icon,
    required this.color,
  });
}

class _QuestionPair {
  final String bengali;
  final String english;

  const _QuestionPair(
      this.bengali,
      this.english,
      );
}