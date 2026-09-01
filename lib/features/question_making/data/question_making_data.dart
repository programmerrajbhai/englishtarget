import 'package:flutter/material.dart';

import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';

abstract final class QuestionMakingData {
  static final List<QuestionMakingTopic> topics = _buildTopics();

  static List<QuestionMakingTopic> _buildTopics() {
    return <QuestionMakingTopic>[
      // ----- ADJECTIVES (State) -----
      _topicAdj('happy', 'Happy', 'খুশি', Icons.sentiment_satisfied_alt_rounded, Colors.orange),
      _topicAdj('sad', 'Sad', 'দুঃখিত', Icons.sentiment_dissatisfied_rounded, Colors.blue),
      _topicAdj('busy', 'Busy', 'ব্যস্ত', Icons.timer_rounded, Colors.red),
      _topicAdj('ready', 'Ready', 'প্রস্তুত', Icons.check_circle_rounded, Colors.green),
      _topicAdj('late', 'Late', 'দেরি', Icons.schedule_rounded, Colors.purple),
      _topicAdj('sick', 'Sick', 'অসুস্থ', Icons.sick_rounded, Colors.teal),
      _topicAdj('tired', 'Tired', 'ক্লান্ত', Icons.battery_alert_rounded, Colors.indigo),
      _topicAdj('angry', 'Angry', 'রাগান্বিত', Icons.mood_bad_rounded, Colors.deepOrange),
      _topicAdj('sure', 'Sure', 'নিশ্চিত', Icons.verified_rounded, Colors.lightBlue),
      _topicAdj('hungry', 'Hungry', 'ক্ষুধার্ত', Icons.restaurant_rounded, Colors.brown),

      // ----- NOUNS (Possession) -----
      _topicNoun('time', 'Time', 'সময়', false, Icons.access_time_rounded, Colors.blue),
      _topicNoun('money', 'Money', 'টাকা', false, Icons.payments_rounded, Colors.green),
      _topicNoun('book', 'Book', 'বই', true, Icons.menu_book_rounded, Colors.purple),
      _topicNoun('car', 'Car', 'গাড়ি', true, Icons.directions_car_rounded, Colors.red),
      _topicNoun('pen', 'Pen', 'কলম', true, Icons.edit_rounded, Colors.teal),
      _topicNoun('friend', 'Friend', 'বন্ধু', true, Icons.groups_rounded, Colors.orange),
      _topicNoun('idea', 'Idea', 'আইডিয়া', true, Icons.lightbulb_rounded, Colors.amber),
      _topicNoun('plan', 'Plan', 'পরিকল্পনা', true, Icons.event_note_rounded, Colors.indigo),
      _topicNoun('house', 'House', 'বাড়ি', true, Icons.home_rounded, Colors.brown),
      _topicNoun('job', 'Job', 'চাকরি', true, Icons.work_rounded, Colors.blueGrey),

      // ----- VERBS (Action) -----
      _topicAction('go', 'Going', 'go', 'going', 'went', 'যাও', 'যাচ্ছো', 'যাচ্ছে', 'যাচ্ছি', 'গিয়েছিলে', 'গিয়েছিল', Icons.directions_walk_rounded, Colors.green),
      _topicAction('come', 'Coming', 'come', 'coming', 'came', 'আসো', 'আসছো', 'আসছে', 'আসছি', 'এসেছিলে', 'এসেছিল', Icons.login_rounded, Colors.blue),
      _topicAction('play', 'Playing', 'play', 'playing', 'played', 'খেলো', 'খেলছো', 'খেলছে', 'খেলছি', 'খেলেছিলে', 'খেলেছিল', Icons.sports_soccer_rounded, Colors.orange),
      _topicAction('eat', 'Eating', 'eat', 'eating', 'ate', 'খাও', 'খাচ্ছো', 'খাচ্ছে', 'খাচ্ছি', 'খেয়েছিলে', 'খেয়েছিল', Icons.restaurant_rounded, Colors.red),
      _topicAction('sleep', 'Sleeping', 'sleep', 'sleeping', 'slept', 'ঘুমাও', 'ঘুমাচ্ছো', 'ঘুমাচ্ছে', 'ঘুমাচ্ছি', 'ঘুমিয়েছিলে', 'ঘুমিয়েছিল', Icons.bedtime_rounded, Colors.purple),
      _topicAction('read', 'Reading', 'read', 'reading', 'read', 'পড়ো', 'পড়ছো', 'পড়ছে', 'পড়ছি', 'পড়েছিলে', 'পড়েছিল', Icons.chrome_reader_mode_rounded, Colors.teal),
      _topicAction('write', 'Writing', 'write', 'writing', 'wrote', 'লিখো', 'লিখছো', 'লিখছে', 'লিখছি', 'লিখেছিলে', 'লিখেছিল', Icons.edit_note_rounded, Colors.indigo),
      _topicAction('work', 'Working', 'work', 'working', 'worked', 'কাজ করো', 'কাজ করছো', 'কাজ করছে', 'কাজ করছি', 'কাজ করেছিলে', 'কাজ করেছিল', Icons.business_center_rounded, Colors.brown),
      _topicAction('learn', 'Learning', 'learn', 'learning', 'learnt', 'শিখো', 'শিখছো', 'শিখছে', 'শিখছি', 'শিখেছিলে', 'শিখেছিল', Icons.school_rounded, Colors.lightBlue),
      _topicAction('wait', 'Waiting', 'wait', 'waiting', 'waited', 'অপেক্ষা করো', 'অপেক্ষা করছো', 'অপেক্ষা করছে', 'অপেক্ষা করছি', 'অপেক্ষা করেছিলে', 'অপেক্ষা করেছিল', Icons.hourglass_empty_rounded, Colors.deepOrange),
    ];
  }

  // Generator 1: Adjectives (Short 3-4 word questions)
  static QuestionMakingTopic _topicAdj(String id, String title, String bnAdj, IconData icon, Color color) {
    final List<List<String>> pairs = [
      ['তুমি কি $bnAdj?', 'Are you $id?'],
      ['সে কি $bnAdj?', 'Is he $id?'],
      ['তারা কি $bnAdj?', 'Are they $id?'],
      ['আমি কি $bnAdj?', 'Am I $id?'],
      ['আমরা কি $bnAdj?', 'Are we $id?'],
      ['তুমি কি $bnAdj ছিলে?', 'Were you $id?'],
      ['সে কি $bnAdj ছিল?', 'Was he $id?'],
      ['তারা কি $bnAdj ছিল?', 'Were they $id?'],
      ['আমি কি $bnAdj ছিলাম?', 'Was I $id?'],
      ['তুমি কি $bnAdj হবে?', 'Will you be $id?'],
      ['সে কি $bnAdj হবে?', 'Will he be $id?'],
      ['তুমি কেন $bnAdj?', 'Why are you $id?'],
      ['সে কেন $bnAdj?', 'Why is he $id?'],
      ['তারা কেন $bnAdj?', 'Why are they $id?'],
      ['তুমি কেন $bnAdj ছিলে?', 'Why were you $id?'],
      ['সে কেন $bnAdj ছিল?', 'Why was he $id?'],
      ['কীভাবে তুমি $bnAdj?', 'How are you $id?'],
      ['কীভাবে সে $bnAdj?', 'How is he $id?'],
      ['কে $bnAdj?', 'Who is $id?'],
      ['কারা $bnAdj?', 'Who are $id?'],
      ['কে $bnAdj ছিল?', 'Who was $id?'],
      ['তুমি কতটা $bnAdj?', 'How $id are you?'],
      ['সে কতটা $bnAdj?', 'How $id is he?'],
      ['তুমি কি $bnAdj নও?', 'Are you not $id?'],
      ['সে কি $bnAdj নয়?', 'Is he not $id?'],
    ];

    return _buildTopic(id, title, '$title Questions', icon, color, pairs);
  }

  // Generator 2: Nouns (Possession)
  static QuestionMakingTopic _topicNoun(String id, String title, String bnNoun, bool countable, IconData icon, Color color) {
    final String a = countable ? 'a ' : '';
    final String plural = countable ? '${id}s' : id;
    final List<List<String>> pairs = [
      ['তোমার কি $bnNoun আছে?', 'Do you have $a$id?'],
      ['তার কি $bnNoun আছে?', 'Does he have $a$id?'],
      ['তাদের কি $bnNoun আছে?', 'Do they have $a$id?'],
      ['আমাদের কি $bnNoun আছে?', 'Do we have $a$id?'],
      ['তোমার কি $bnNoun ছিল?', 'Did you have $a$id?'],
      ['তার কি $bnNoun ছিল?', 'Did he have $a$id?'],
      ['তোমার কি $bnNoun থাকবে?', 'Will you have $a$id?'],
      ['তার কি $bnNoun থাকবে?', 'Will he have $a$id?'],
      ['তোমার কেন $bnNoun আছে?', 'Why do you have $a$id?'],
      ['তার কেন $bnNoun আছে?', 'Why does he have $a$id?'],
      ['তোমার কেন $bnNoun নেই?', 'Why do you not have $a$id?'],
      ['তার কেন $bnNoun নেই?', 'Why does he not have $a$id?'],
      ['কার $bnNoun আছে?', 'Who has $a$id?'],
      ['কার $bnNoun ছিল?', 'Who had $a$id?'],
      ['তোমার কয়টি $bnNoun আছে?', countable ? 'How many $plural do you have?' : 'How much $id do you have?'],
      ['তার কয়টি $bnNoun আছে?', countable ? 'How many $plural does he have?' : 'How much $id does he have?'],
      ['তোমার কোন $bnNoun দরকার?', 'Which $id do you need?'],
      ['তার কোন $bnNoun দরকার?', 'Which $id does he need?'],
      ['তোমার কি $bnNoun দরকার?', 'Do you need $a$id?'],
      ['তার কি $bnNoun দরকার?', 'Does he need $a$id?'],
      ['তোমার কি $bnNoun চাই?', 'Do you want $a$id?'],
      ['তার কি $bnNoun চাই?', 'Does he want $a$id?'],
      ['তোমার $bnNoun কোথায়?', 'Where is your $id?'],
      ['তার $bnNoun কোথায়?', 'Where is his $id?'],
      ['তোমার $bnNoun কেমন?', 'How is your $id?'],
    ];

    return _buildTopic(id, title, '$title Questions', icon, color, pairs);
  }

  // Generator 3: Action Verbs
  static QuestionMakingTopic _topicAction(String id, String title, String v1, String vIng, String v3, String bnYou, String bnYouIng, String bnHeIng, String bnIIng, String bnYouPast, String bnHePast, IconData icon, Color color) {
    final List<List<String>> pairs = [
      ['তুমি কি $bnYouIng?', 'Are you $vIng?'],
      ['সে কি $bnHeIng?', 'Is he $vIng?'],
      ['তারা কি $bnHeIng?', 'Are they $vIng?'],
      ['আমি কি $bnIIng?', 'Am I $vIng?'],
      ['তুমি কি $bnYouPast?', 'Were you $vIng?'],
      ['সে কি $bnHePast?', 'Was he $vIng?'],
      ['তুমি কেন $bnYouIng?', 'Why are you $vIng?'],
      ['সে কেন $bnHeIng?', 'Why is he $vIng?'],
      ['তুমি কোথায় $bnYouIng?', 'Where are you $vIng?'],
      ['সে কোথায় $bnHeIng?', 'Where is he $vIng?'],
      ['তুমি কখন $bnYouIng?', 'When are you $vIng?'],
      ['সে কখন $bnHeIng?', 'When is he $vIng?'],
      ['তুমি কীভাবে $bnYouIng?', 'How are you $vIng?'],
      ['সে কীভাবে $bnHeIng?', 'How is he $vIng?'],
      ['কে $bnHeIng?', 'Who is $vIng?'],
      ['কারা $bnHeIng?', 'Who are $vIng?'],
      ['তুমি কি $v1 করতে পারো?', 'Can you $v1?'],
      ['সে কি $v1 করতে পারে?', 'Can he $v1?'],
      ['তুমি কি $v1 করবে?', 'Will you $v1?'],
      ['সে কি $v1 করবে?', 'Will he $v1?'],
      ['তুমি কি $v1 করতে চাও?', 'Do you want to $v1?'],
      ['সে কি $v1 করতে চায়?', 'Does he want to $v1?'],
      ['তোমার কি $v1 করা উচিত?', 'Should you $v1?'],
      ['তার কি $v1 করা উচিত?', 'Should he $v1?'],
      ['তুমি কি $bnYouPast?', 'Did you $v1?'],
    ];

    return _buildTopic(id, title, '$title Questions', icon, color, pairs);
  }

  static QuestionMakingTopic _buildTopic(String id, String title, String subtitle, IconData icon, Color color, List<List<String>> pairs) {
    return QuestionMakingTopic(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      questions: List.generate(
        pairs.length,
            (index) => QuestionMakingItem(
          id: '${id}_${index + 1}',
          bengali: pairs[index][0],
          english: pairs[index][1],
          explanation: 'Question structure practice.',
          visualKey: id,
          icon: icon,
          color: color,
        ),
      ),
    );
  }
}