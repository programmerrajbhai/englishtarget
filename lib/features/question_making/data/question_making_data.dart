import 'package:flutter/material.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';

abstract final class QuestionMakingData {
  static final List<QuestionMakingTopic> topics =
  _createTopics();

  static List<QuestionMakingTopic> _createTopics() {
    const List<_TopicSpec> specs = <_TopicSpec>[
      _TopicSpec(
        id: 'wh_questions',
        title: 'WH Questions',
        subtitle: 'What, Why, Where, When',
        focusBangla: 'প্রশ্ন করা',
        verbBase: 'ask questions',
        verbIng: 'asking questions',
        icon: Icons.help_rounded,
        color: Colors.green,
      ),
      _TopicSpec(
        id: 'do_does_questions',
        title: 'Do / Does Questions',
        subtitle: 'দৈনন্দিন প্রশ্ন',
        focusBangla: 'ইংরেজি অনুশীলন',
        verbBase: 'practice English',
        verbIng: 'practicing English',
        icon: Icons.question_answer_rounded,
        color: Colors.blue,
      ),
      _TopicSpec(
        id: 'is_am_are_questions',
        title: 'Is / Am / Are Questions',
        subtitle: 'অবস্থা ও পরিচয়',
        focusBangla: 'পড়াশোনা',
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
        verbBase: 'help your friend',
        verbIng: 'helping your friend',
        icon: Icons.volunteer_activism_rounded,
        color: Colors.orange,
      ),
      _TopicSpec(
        id: 'will_would_questions',
        title: 'Will / Would Questions',
        subtitle: 'ভবিষ্যৎ ও ইচ্ছা',
        focusBangla: 'পরিবারের কাছে যাওয়া',
        verbBase: 'visit your family',
        verbIng: 'visiting your family',
        icon: Icons.event_available_rounded,
        color: Colors.teal,
      ),
      _TopicSpec(
        id: 'did_questions',
        title: 'Did Questions',
        subtitle: 'অতীতের প্রশ্ন',
        focusBangla: 'সিনেমা দেখা',
        verbBase: 'watch a movie',
        verbIng: 'watching a movie',
        icon: Icons.movie_rounded,
        color: Colors.red,
      ),
      _TopicSpec(
        id: 'have_has_questions',
        title: 'Have / Has Questions',
        subtitle: 'অভিজ্ঞতা ও মালিকানা',
        focusBangla: 'সকালের নাশতা খাওয়া',
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
        verbBase: 'call your friend',
        verbIng: 'calling your friend',
        icon: Icons.people_rounded,
        color: Colors.purple,
      ),
      _TopicSpec(
        id: 'how_questions',
        title: 'How Questions',
        subtitle: 'কীভাবে সম্পর্কে প্রশ্ন',
        focusBangla: 'বাসে ভ্রমণ করা',
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
        verbBase: 'spend money',
        verbIng: 'spending money',
        icon: Icons.payments_rounded,
        color: Colors.green,
      ),
      _TopicSpec(
        id: 'daily_routine_questions',
        title: 'Daily Routine Questions',
        subtitle: 'প্রতিদিনের কাজ',
        focusBangla: 'সকালে ঘুম থেকে ওঠা',
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
        verbBase: 'open the window',
        verbIng: 'opening the window',
        icon: Icons.lock_open_rounded,
        color: Colors.orange,
      ),
      _TopicSpec(
        id: 'request_questions',
        title: 'Request Questions',
        subtitle: 'অনুরোধ করা',
        focusBangla: 'সাহায্য করা',
        verbBase: 'help me',
        verbIng: 'helping me',
        icon: Icons.handshake_rounded,
        color: Colors.teal,
      ),
      _TopicSpec(
        id: 'opinion_questions',
        title: 'Opinion Questions',
        subtitle: 'মতামত জানতে প্রশ্ন',
        focusBangla: 'এই ধারণাটি পছন্দ করা',
        verbBase: 'like this idea',
        verbIng: 'liking this idea',
        icon: Icons.forum_rounded,
        color: Colors.purple,
      ),
      _TopicSpec(
        id: 'mixed_questions',
        title: 'Mixed Questions',
        subtitle: 'সব ধরনের প্রশ্ন',
        focusBangla: 'ইংরেজি অনুশীলন করা',
        verbBase: 'practice English',
        verbIng: 'practicing English',
        icon: Icons.auto_awesome_rounded,
        color: Colors.indigo,
      ),
    ];

    return specs
        .map(_createTopic)
        .toList(growable: false);
  }

  static QuestionMakingTopic _createTopic(
      _TopicSpec spec,
      ) {
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
        'তুমি কী করো?',
        'What do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কোথায় এটি করো?',
        'Where do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কখন এটি করো?',
        'When do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কেন এটি করো?',
        'Why do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কীভাবে এটি করো?',
        'How do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কার সঙ্গে এটি করো?',
        'Who do you ${spec.verbBase} with?',
      ),
      _QuestionPair(
        'তুমি কি প্রতিদিন এটি করো?',
        'Do you ${spec.verbBase} every day?',
      ),
      _QuestionPair(
        'সে কি এটি করে?',
        'Does he ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি গতকাল এটি করেছিলে?',
        'Did you ${spec.verbBase} yesterday?',
      ),
      _QuestionPair(
        'তুমি কি আগামীকাল এটি করবে?',
        'Will you ${spec.verbBase} tomorrow?',
      ),
      _QuestionPair(
        'তুমি কি এটি করতে পারো?',
        'Can you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি এটি করতে পারতে?',
        'Could you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কি এটি করতে চাও?',
        'Would you like to ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি গতকাল কী করেছিলে?',
        'What did you ${spec.verbBase} yesterday?',
      ),
      _QuestionPair(
        'তুমি গতকাল কোথায় এটি করেছিলে?',
        'Where did you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কখন এটি করবে?',
        'When will you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কেন এটি করবে?',
        'Why will you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কার সঙ্গে এটি করবে?',
        'Who will you ${spec.verbBase} with?',
      ),
      _QuestionPair(
        'তুমি কতবার এটি করো?',
        'How often do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কতক্ষণ এটি করো?',
        'How long do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'তুমি কতবার এটি করো?',
        'How many times do you ${spec.verbBase}?',
      ),
      _QuestionPair(
        'সে কী করে?',
        'What does she ${spec.verbBase}?',
      ),
      _QuestionPair(
        'সে কোথায় এটি করে?',
        'Where does she ${spec.verbBase}?',
      ),
      _QuestionPair(
        'সে কি এটি করছে?',
        'Is he ${spec.verbIng}?',
      ),
      _QuestionPair(
        'তুমি কি এটি করছো?',
        'Are you ${spec.verbIng}?',
      ),
    ];

    return pairs.asMap().entries.map(
          (MapEntry<int, _QuestionPair> entry) {
        return QuestionMakingItem(
          id: '${spec.id}_${entry.key + 1}',
          bengali: entry.value.bengali,
          english: entry.value.english,
          explanation:
          'প্রশ্নে question word-এর পরে helping verb এবং subject বসে।',
          visualKey: spec.id,
          icon: spec.icon,
          color: spec.color,
        );
      },
    ).toList(growable: false);
  }
}

class _TopicSpec {
  final String id;
  final String title;
  final String subtitle;
  final String focusBangla;
  final String verbBase;
  final String verbIng;
  final IconData icon;
  final Color color;

  const _TopicSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.focusBangla,
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