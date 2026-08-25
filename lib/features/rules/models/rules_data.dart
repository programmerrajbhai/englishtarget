import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/rule_item.dart';

abstract final class RulesData {
  static const List<String> categories = [
    'All',
    'Foundation',
    'Basics',
    'Daily',
    'Past & Future',
    'Modals',
    'Questions',
  ];

  static final List<RuleItem> rules = List<RuleItem>.unmodifiable(
    _seeds.map(_createRule),
  );

  static RuleItem _createRule(_RuleSeed seed) {
    return RuleItem(
      serial: seed.serial,
      id: seed.id,
      title: seed.title,
      shortMeaning: seed.shortMeaning,
      explanation: seed.explanation,
      structure: seed.structure,
      level: seed.level,
      category: seed.category,
      icon: _iconFor(seed.serial, seed.category),
      color: _colorFor(seed.category),
      totalLessons: 3,
      progress: 0,
    );
  }

  static Color _colorFor(String category) {
    switch (category) {
      case 'Foundation':
        return AppColors.primary;
      case 'Basics':
        return AppColors.blue;
      case 'Daily':
        return AppColors.purple;
      case 'Past & Future':
        return AppColors.amber;
      case 'Modals':
        return const Color(0xFFEA6B4D);
      case 'Questions':
        return const Color(0xFF0E9F9A);
      default:
        return AppColors.primary;
    }
  }

  static IconData _iconFor(
      int serial,
      String category,
      ) {
    switch (serial) {
      case 1:
        return Icons.people_alt_rounded;
      case 2:
        return Icons.merge_type_rounded;
      case 3:
        return Icons.touch_app_rounded;
      case 4:
        return Icons.groups_rounded;
      case 5:
        return Icons.place_rounded;
      case 6:
        return Icons.add_home_rounded;
      case 7:
        return Icons.looks_one_rounded;
      case 8:
        return Icons.label_important_rounded;
      case 9:
        return Icons.format_list_numbered_rounded;
      case 10:
        return Icons.key_rounded;
      case 11:
        return Icons.person_pin_rounded;
      case 12:
        return Icons.workspace_premium_rounded;
      case 13:
        return Icons.near_me_rounded;
      case 14:
        return Icons.help_outline_rounded;
      case 15:
        return Icons.help_center_rounded;
      case 16:
        return Icons.person_search_rounded;
      case 17:
        return Icons.search_rounded;
      case 18:
        return Icons.info_rounded;
      case 19:
        return Icons.inventory_2_rounded;
      case 20:
        return Icons.history_rounded;
      case 21:
        return Icons.account_tree_rounded;
      case 22:
        return Icons.replay_rounded;
      case 23:
        return Icons.question_answer_rounded;
      case 24:
        return Icons.block_rounded;
      case 25:
        return Icons.play_circle_rounded;
      case 26:
        return Icons.live_help_rounded;
      case 27:
        return Icons.compare_arrows_rounded;
      case 28:
        return Icons.repeat_rounded;
      case 29:
        return Icons.favorite_rounded;
      case 30:
        return Icons.lightbulb_rounded;
      case 31:
        return Icons.history_toggle_off_rounded;
      case 32:
        return Icons.remove_circle_rounded;
      case 33:
        return Icons.update_rounded;
      case 34:
        return Icons.spellcheck_rounded;
      case 35:
        return Icons.swap_horiz_rounded;
      case 36:
        return Icons.help_rounded;
      case 37:
        return Icons.cancel_rounded;
      case 38:
        return Icons.timelapse_rounded;
      case 39:
        return Icons.arrow_forward_rounded;
      case 40:
        return Icons.event_available_rounded;
      case 41:
        return Icons.bolt_rounded;
      case 42:
        return Icons.volunteer_activism_rounded;
      case 43:
        return Icons.recommend_rounded;
      case 44:
        return Icons.gavel_rounded;
      case 45:
        return Icons.cloud_rounded;
      case 46:
        return Icons.room_service_rounded;
      case 47:
        return Icons.assignment_rounded;
      case 48:
        return Icons.flag_rounded;
      case 49:
        return Icons.group_add_rounded;
      case 50:
        return Icons.record_voice_over_rounded;
      case 51:
        return Icons.question_mark_rounded;
      case 52:
        return Icons.badge_rounded;
      case 53:
        return Icons.location_on_rounded;
      case 54:
        return Icons.schedule_rounded;
      case 55:
        return Icons.psychology_alt_rounded;
      case 56:
        return Icons.route_rounded;
      case 57:
        return Icons.calculate_rounded;
      case 58:
        return Icons.pin_drop_rounded;
      case 59:
        return Icons.alt_route_rounded;
      case 60:
        return Icons.link_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  static const List<_RuleSeed> _seeds = [
    _RuleSeed(
      serial: 1,
      id: 'subject_pronouns',
      title: 'Subject Pronouns',
      shortMeaning:
      'I, You, He, She, It, We ও They-এর ব্যবহার',
      explanation:
      'Sentence-এ কে কাজ করছে বা কার সম্পর্কে বলা হচ্ছে, সেটি বোঝাতে Subject Pronoun ব্যবহার হয়।',
      structure: 'Subject Pronoun + Verb + Object',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 2,
      id: 'am_is_are',
      title: 'Am, Is & Are',
      shortMeaning:
      'পরিচয়, অবস্থা ও অবস্থান বোঝাতে',
      explanation:
      'বর্তমান সময়ে পরিচয়, অবস্থা, পেশা বা অবস্থান প্রকাশ করতে Am, Is এবং Are ব্যবহার হয়।',
      structure: 'Subject + am/is/are + information',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 3,
      id: 'this_that',
      title: 'This & That',
      shortMeaning:
      'কাছের ও দূরের একটি বস্তু বোঝাতে',
      explanation:
      'কাছের একটি ব্যক্তি বা বস্তু বোঝাতে This এবং দূরের একটি ব্যক্তি বা বস্তু বোঝাতে That ব্যবহার হয়।',
      structure: 'This/That + is + object',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 4,
      id: 'these_those',
      title: 'These & Those',
      shortMeaning:
      'কাছের ও দূরের একাধিক বস্তু বোঝাতে',
      explanation:
      'কাছের একাধিক বস্তু বোঝাতে These এবং দূরের একাধিক বস্তু বোঝাতে Those ব্যবহার হয়।',
      structure: 'These/Those + are + plural object',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 5,
      id: 'here_there',
      title: 'Here & There',
      shortMeaning:
      'এখানে ও সেখানে অবস্থান বোঝাতে',
      explanation:
      'বক্তার কাছের স্থান বোঝাতে Here এবং দূরের স্থান বোঝাতে There ব্যবহার হয়।',
      structure: 'Subject + verb + here/there',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 6,
      id: 'there_is_are',
      title: 'There is & There are',
      shortMeaning:
      'কোনো কিছু আছে বোঝাতে',
      explanation:
      'একটি বস্তু আছে বোঝাতে There is এবং একাধিক বস্তু আছে বোঝাতে There are ব্যবহার হয়।',
      structure: 'There is/are + object + place',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 7,
      id: 'a_an',
      title: 'A & An',
      shortMeaning:
      'অনির্দিষ্ট একটি ব্যক্তি বা বস্তু বোঝাতে',
      explanation:
      'Consonant sound-এর আগে A এবং vowel sound-এর আগে An ব্যবহার হয়।',
      structure: 'a/an + singular noun',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 8,
      id: 'the',
      title: 'The',
      shortMeaning:
      'নির্দিষ্ট ব্যক্তি বা বস্তু বোঝাতে',
      explanation:
      'নির্দিষ্ট, পরিচিত বা আগে বলা ব্যক্তি ও বস্তুর আগে The ব্যবহার হয়।',
      structure: 'the + specific noun',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 9,
      id: 'singular_plural',
      title: 'Singular & Plural',
      shortMeaning:
      'একটি ও একাধিক বস্তু বোঝাতে',
      explanation:
      'একটি ব্যক্তি বা বস্তুকে Singular এবং একাধিককে Plural বলা হয়।',
      structure: 'one book / two books',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 10,
      id: 'possessive_adjectives',
      title: 'Possessive Adjectives',
      shortMeaning:
      'My, Your, His, Her, Our ও Their',
      explanation:
      'কোনো ব্যক্তি বা বস্তু কার, তা noun-এর আগে বোঝাতে Possessive Adjective ব্যবহার হয়।',
      structure: 'Possessive adjective + noun',
      level: RuleLevel.beginner,
      category: 'Foundation',
    ),
    _RuleSeed(
      serial: 11,
      id: 'object_pronouns',
      title: 'Object Pronouns',
      shortMeaning:
      'Me, Him, Her, Us ও Them-এর ব্যবহার',
      explanation:
      'কাজটি কার ওপর হচ্ছে, সেটি বোঝাতে Object Pronoun ব্যবহার হয়।',
      structure: 'Subject + verb + object pronoun',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 12,
      id: 'possessive_pronouns',
      title: 'Possessive Pronouns',
      shortMeaning:
      'Mine, Yours, Hers, Ours ও Theirs',
      explanation:
      'Noun পুনরায় না বলে কোনো জিনিস কার, তা বোঝাতে Possessive Pronoun ব্যবহার হয়।',
      structure: 'Subject + be verb + possessive pronoun',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 13,
      id: 'this_is_that_is',
      title: 'This is & That is',
      shortMeaning:
      'কাছের বা দূরের কিছু পরিচয় করাতে',
      explanation:
      'কাছের বা দূরের ব্যক্তি ও বস্তুকে পরিচয় করিয়ে দিতে এই structure ব্যবহার হয়।',
      structure: 'This/That + is + information',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 14,
      id: 'is_this_that',
      title: 'Is this? & Is that?',
      shortMeaning:
      'একটি কাছের বা দূরের বস্তু সম্পর্কে প্রশ্ন',
      explanation:
      'কাছের বা দূরের একটি বস্তু সম্পর্কে Yes/No question করতে ব্যবহার হয়।',
      structure: 'Is + this/that + information?',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 15,
      id: 'are_these_those',
      title: 'Are these? & Are those?',
      shortMeaning:
      'একাধিক বস্তু সম্পর্কে প্রশ্ন করতে',
      explanation:
      'কাছের বা দূরের একাধিক বস্তু সম্পর্কে Yes/No question করতে ব্যবহার হয়।',
      structure: 'Are + these/those + information?',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 16,
      id: 'who_is_this_that',
      title: 'Who is this/that?',
      shortMeaning:
      'কোনো ব্যক্তির পরিচয় জানতে',
      explanation:
      'কাছের বা দূরের কোনো ব্যক্তি কে, সেটি জানতে এই question ব্যবহার হয়।',
      structure: 'Who + is + this/that?',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 17,
      id: 'what_is_this_that',
      title: 'What is this/that?',
      shortMeaning:
      'কাছের বা দূরের কোনো বস্তু কী জানতে',
      explanation:
      'কোনো অপরিচিত বস্তু সম্পর্কে জানতে এই question ব্যবহার হয়।',
      structure: 'What + is + this/that?',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 18,
      id: 'it_is',
      title: 'It is & It’s',
      shortMeaning:
      'বস্তু, সময়, আবহাওয়া ও পরিস্থিতি বোঝাতে',
      explanation:
      'কোনো বস্তু, সময়, দিন, আবহাওয়া বা সাধারণ পরিস্থিতি বোঝাতে It ব্যবহার হয়।',
      structure: 'It + is + information',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 19,
      id: 'have_has',
      title: 'Have & Has',
      shortMeaning:
      'কোনো কিছু থাকা বা মালিকানা বোঝাতে',
      explanation:
      'I, You, We, They-এর সঙ্গে Have এবং He, She, It-এর সঙ্গে Has ব্যবহার হয়।',
      structure: 'Subject + have/has + object',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 20,
      id: 'had',
      title: 'Had',
      shortMeaning:
      'অতীতে কোনো কিছু ছিল বোঝাতে',
      explanation:
      'অতীতে কারও কাছে কোনো কিছু ছিল বা কোনো অভিজ্ঞতা হয়েছিল বোঝাতে Had ব্যবহার হয়।',
      structure: 'Subject + had + object',
      level: RuleLevel.beginner,
      category: 'Basics',
    ),
    _RuleSeed(
      serial: 21,
      id: 'subject_verb_object',
      title: 'Subject + Verb + Object',
      shortMeaning:
      'সাধারণ English sentence-এর সঠিক order',
      explanation:
      'সাধারণ affirmative sentence তৈরি করতে Subject, Verb এবং Object সঠিক order-এ বসে।',
      structure: 'Subject + Verb + Object',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 22,
      id: 'present_simple',
      title: 'Present Simple',
      shortMeaning:
      'অভ্যাস, নিয়মিত কাজ ও সাধারণ সত্য',
      explanation:
      'নিয়মিত কাজ, অভ্যাস এবং সাধারণ সত্য প্রকাশ করতে Present Simple ব্যবহার হয়।',
      structure: 'Subject + base verb/verb-s + object',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 23,
      id: 'do_does_questions',
      title: 'Do & Does Questions',
      shortMeaning:
      'বর্তমানের কাজ ও অভ্যাস সম্পর্কে প্রশ্ন',
      explanation:
      'I, You, We, They-এর সঙ্গে Do এবং He, She, It-এর সঙ্গে Does ব্যবহার হয়।',
      structure: 'Do/Does + subject + base verb?',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 24,
      id: 'do_not_does_not',
      title: 'Do not & Does not',
      shortMeaning:
      'বর্তমানের negative sentence তৈরি করতে',
      explanation:
      'বর্তমান সময়ে কোনো কাজ হয় না বোঝাতে Do not বা Does not ব্যবহার হয়।',
      structure: 'Subject + do/does not + base verb',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 25,
      id: 'present_continuous',
      title: 'Present Continuous',
      shortMeaning:
      'এখন কোনো কাজ চলছে বোঝাতে',
      explanation:
      'কথা বলার সময় কোনো কাজ চলমান থাকলে Present Continuous ব্যবহার হয়।',
      structure: 'Subject + am/is/are + verb-ing',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 26,
      id: 'am_is_are_questions',
      title: 'Am/Is/Are Questions',
      shortMeaning:
      'অবস্থা বা চলমান কাজ সম্পর্কে প্রশ্ন',
      explanation:
      'Be verb sentence এবং Present Continuous-এর Yes/No question তৈরি করতে ব্যবহার হয়।',
      structure: 'Am/Is/Are + subject + information?',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 27,
      id: 'present_simple_vs_continuous',
      title: 'Simple vs Continuous',
      shortMeaning:
      'নিয়মিত কাজ ও এখনকার কাজের পার্থক্য',
      explanation:
      'Present Simple নিয়মিত কাজ এবং Present Continuous এখন চলমান কাজ বোঝায়।',
      structure: 'I work / I am working',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 28,
      id: 'frequency_adverbs',
      title: 'Frequency Adverbs',
      shortMeaning:
      'Always, Usually, Often, Sometimes ও Never',
      explanation:
      'কোনো কাজ কতবার হয়, সেটি বোঝাতে Frequency Adverb ব্যবহার হয়।',
      structure: 'Subject + frequency adverb + main verb',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 29,
      id: 'like_love_hate',
      title: 'Like, Love & Hate',
      shortMeaning:
      'পছন্দ, ভালোবাসা ও অপছন্দ বোঝাতে',
      explanation:
      'কোনো ব্যক্তি, বস্তু বা কাজ সম্পর্কে পছন্দ ও অপছন্দ প্রকাশ করতে ব্যবহার হয়।',
      structure: 'Subject + like/love/hate + noun/verb-ing',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 30,
      id: 'want_need',
      title: 'Want & Need',
      shortMeaning:
      'ইচ্ছা ও প্রয়োজন বোঝাতে',
      explanation:
      'কোনো কিছু চাওয়া বোঝাতে Want এবং প্রয়োজন বোঝাতে Need ব্যবহার হয়।',
      structure: 'Subject + want/need + object',
      level: RuleLevel.elementary,
      category: 'Daily',
    ),
    _RuleSeed(
      serial: 31,
      id: 'was_were',
      title: 'Was & Were',
      shortMeaning:
      'অতীতের পরিচয়, অবস্থা বা অবস্থান',
      explanation:
      'অতীতে কোনো ব্যক্তি বা বস্তুর অবস্থা ও অবস্থান বোঝাতে Was এবং Were ব্যবহার হয়।',
      structure: 'Subject + was/were + information',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 32,
      id: 'was_not_were_not',
      title: 'Was not & Were not',
      shortMeaning:
      'অতীতের negative অবস্থা বোঝাতে',
      explanation:
      'অতীতে কোনো ব্যক্তি বা বস্তু কোনো অবস্থায় ছিল না বোঝাতে ব্যবহার হয়।',
      structure: 'Subject + was/were not + information',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 33,
      id: 'past_simple',
      title: 'Past Simple',
      shortMeaning:
      'অতীতে শেষ হওয়া কাজ বোঝাতে',
      explanation:
      'অতীতে শুরু ও শেষ হয়ে যাওয়া কাজ প্রকাশ করতে Past Simple ব্যবহার হয়।',
      structure: 'Subject + past verb + object',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 34,
      id: 'regular_past_verbs',
      title: 'Regular Past Verbs',
      shortMeaning:
      'Worked, Played ও Watched-এর ব্যবহার',
      explanation:
      'যেসব verb-এর past form সাধারণত ed যোগ করে তৈরি হয়, সেগুলো Regular Verb।',
      structure: 'Base verb + ed',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 35,
      id: 'irregular_past_verbs',
      title: 'Irregular Past Verbs',
      shortMeaning:
      'Went, Ate, Saw, Came ও Took',
      explanation:
      'যেসব verb-এর past form ed যোগ করে তৈরি হয় না, সেগুলো Irregular Verb।',
      structure: 'go → went, eat → ate',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 36,
      id: 'did_questions',
      title: 'Did Questions',
      shortMeaning:
      'অতীতের কাজ সম্পর্কে প্রশ্ন',
      explanation:
      'অতীতে কোনো কাজ হয়েছিল কি না জানতে Did দিয়ে question তৈরি হয়।',
      structure: 'Did + subject + base verb?',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 37,
      id: 'did_not',
      title: 'Did not',
      shortMeaning:
      'অতীতে কোনো কাজ হয়নি বোঝাতে',
      explanation:
      'অতীতে কোনো কাজ করা হয়নি বোঝাতে Did not-এর পরে base verb ব্যবহার হয়।',
      structure: 'Subject + did not + base verb',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 38,
      id: 'past_continuous',
      title: 'Past Continuous',
      shortMeaning:
      'অতীতে কোনো কাজ চলছিল বোঝাতে',
      explanation:
      'অতীতের নির্দিষ্ট সময়ে চলমান কাজ প্রকাশ করতে Past Continuous ব্যবহার হয়।',
      structure: 'Subject + was/were + verb-ing',
      level: RuleLevel.preIntermediate,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 39,
      id: 'will',
      title: 'Will',
      shortMeaning:
      'ভবিষ্যতের সিদ্ধান্ত ও প্রতিশ্রুতি',
      explanation:
      'ভবিষ্যতের তাৎক্ষণিক সিদ্ধান্ত, প্রতিশ্রুতি ও prediction বোঝাতে Will ব্যবহার হয়।',
      structure: 'Subject + will + base verb',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 40,
      id: 'going_to',
      title: 'Going to',
      shortMeaning:
      'আগে থেকে করা ভবিষ্যৎ পরিকল্পনা',
      explanation:
      'আগে থেকেই পরিকল্পনা করা ভবিষ্যতের কাজ বোঝাতে Going to ব্যবহার হয়।',
      structure: 'Subject + am/is/are going to + verb',
      level: RuleLevel.elementary,
      category: 'Past & Future',
    ),
    _RuleSeed(
      serial: 41,
      id: 'can_cannot',
      title: 'Can & Cannot',
      shortMeaning:
      'সক্ষমতা ও অনুমতি বোঝাতে',
      explanation:
      'কোনো কাজ করতে পারা, না পারা বা অনুমতি চাওয়ার জন্য Can ব্যবহার হয়।',
      structure: 'Subject + can/cannot + base verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 42,
      id: 'could',
      title: 'Could',
      shortMeaning:
      'অতীতের সক্ষমতা ও ভদ্র অনুরোধ',
      explanation:
      'অতীতের সক্ষমতা এবং ভদ্রভাবে কোনো অনুরোধ করতে Could ব্যবহার হয়।',
      structure: 'Subject + could + base verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 43,
      id: 'should',
      title: 'Should & Should not',
      shortMeaning:
      'পরামর্শ দেওয়া বা না দেওয়া',
      explanation:
      'কাউকে কোনো কাজ করার বা না করার পরামর্শ দিতে Should ব্যবহার হয়।',
      structure: 'Subject + should/should not + verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 44,
      id: 'must',
      title: 'Must & Must not',
      shortMeaning:
      'বাধ্যবাধকতা ও কঠোর নিষেধ',
      explanation:
      'জোরালো প্রয়োজন, নিয়ম বা কঠোর নিষেধ বোঝাতে Must ব্যবহার হয়।',
      structure: 'Subject + must/must not + verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 45,
      id: 'may_might',
      title: 'May & Might',
      shortMeaning:
      'সম্ভাবনা ও formal permission',
      explanation:
      'সম্ভাবনা বোঝাতে May/Might এবং formal permission-এর জন্য May ব্যবহার হয়।',
      structure: 'Subject + may/might + base verb',
      level: RuleLevel.preIntermediate,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 46,
      id: 'would_like',
      title: 'Would like',
      shortMeaning:
      'ভদ্রভাবে ইচ্ছা বা কিছু চাওয়া',
      explanation:
      'ভদ্রভাবে কোনো কিছু চাওয়া বা কোনো কাজ করার ইচ্ছা প্রকাশ করতে ব্যবহার হয়।',
      structure: 'Subject + would like + noun/to-verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 47,
      id: 'have_to',
      title: 'Have to & Has to',
      shortMeaning:
      'প্রয়োজন বা বাধ্য হয়ে কিছু করা',
      explanation:
      'বাইরের নিয়ম বা পরিস্থিতির কারণে কোনো কাজ করতে হয় বোঝাতে ব্যবহার হয়।',
      structure: 'Subject + have/has to + verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 48,
      id: 'want_to_need_to',
      title: 'Want to & Need to',
      shortMeaning:
      'কিছু করতে চাওয়া বা প্রয়োজন হওয়া',
      explanation:
      'কোনো কাজ করার ইচ্ছা বা প্রয়োজন প্রকাশ করতে Want to এবং Need to ব্যবহার হয়।',
      structure: 'Subject + want/need to + verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 49,
      id: 'lets',
      title: 'Let’s',
      shortMeaning:
      'একসঙ্গে কিছু করার প্রস্তাব',
      explanation:
      'বক্তাসহ অন্য কাউকে একসঙ্গে কোনো কাজ করার প্রস্তাব দিতে Let’s ব্যবহার হয়।',
      structure: 'Let’s + base verb',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 50,
      id: 'imperatives',
      title: 'Imperative Sentences',
      shortMeaning:
      'নির্দেশ, অনুরোধ ও পরামর্শ',
      explanation:
      'কাউকে সরাসরি নির্দেশ, অনুরোধ বা পরামর্শ দিতে Subject ছাড়া base verb দিয়ে sentence শুরু হয়।',
      structure: 'Base verb + object',
      level: RuleLevel.elementary,
      category: 'Modals',
    ),
    _RuleSeed(
      serial: 51,
      id: 'what',
      title: 'What',
      shortMeaning:
      'কী বা কোন বিষয় জানতে',
      explanation:
      'কোনো বস্তু, কাজ বা তথ্য সম্পর্কে জানতে What ব্যবহার হয়।',
      structure: 'What + helping verb + subject + verb?',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 52,
      id: 'who_whose',
      title: 'Who & Whose',
      shortMeaning:
      'ব্যক্তি এবং মালিকানা জানতে',
      explanation:
      'ব্যক্তি সম্পর্কে জানতে Who এবং কোনো জিনিস কার জানতে Whose ব্যবহার হয়।',
      structure: 'Who/Whose + question structure?',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 53,
      id: 'where',
      title: 'Where',
      shortMeaning:
      'স্থান জানতে',
      explanation:
      'কোনো ব্যক্তি, বস্তু বা কাজের অবস্থান জানতে Where ব্যবহার হয়।',
      structure: 'Where + helping verb + subject + verb?',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 54,
      id: 'when_what_time',
      title: 'When & What time',
      shortMeaning:
      'সময় জানতে',
      explanation:
      'সাধারণ সময় জানতে When এবং নির্দিষ্ট ঘড়ির সময় জানতে What time ব্যবহার হয়।',
      structure: 'When/What time + helping verb + subject + verb?',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 55,
      id: 'why_because',
      title: 'Why & Because',
      shortMeaning:
      'কারণ জানতে ও কারণ বলতে',
      explanation:
      'কারণ জানতে Why এবং প্রশ্নের কারণমূলক উত্তর দিতে Because ব্যবহার হয়।',
      structure: 'Why...? Because + reason',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 56,
      id: 'how',
      title: 'How',
      shortMeaning:
      'পদ্ধতি, অবস্থা ও উপায় জানতে',
      explanation:
      'কোনো কাজ কীভাবে হয় বা কারও অবস্থা কেমন, তা জানতে How ব্যবহার হয়।',
      structure: 'How + helping verb + subject + verb?',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 57,
      id: 'how_many_much',
      title: 'How many & How much',
      shortMeaning:
      'সংখ্যা ও পরিমাণ জানতে',
      explanation:
      'Countable noun-এর সংখ্যা জানতে How many এবং uncountable noun-এর পরিমাণ জানতে How much ব্যবহার হয়।',
      structure: 'How many/much + noun + question?',
      level: RuleLevel.preIntermediate,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 58,
      id: 'in_on_at',
      title: 'In, On & At',
      shortMeaning:
      'সময় ও স্থানের preposition',
      explanation:
      'সময় এবং স্থানের ধরন অনুযায়ী In, On ও At ব্যবহার হয়।',
      structure: 'in/on/at + time/place',
      level: RuleLevel.elementary,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 59,
      id: 'to_from_for_with_by',
      title: 'To, From, For, With & By',
      shortMeaning:
      'দিক, উৎস, উদ্দেশ্য, সঙ্গ ও মাধ্যম',
      explanation:
      'Movement, source, purpose, companionship এবং method বোঝাতে এই prepositionগুলো ব্যবহার হয়।',
      structure: 'verb + preposition + noun',
      level: RuleLevel.preIntermediate,
      category: 'Questions',
    ),
    _RuleSeed(
      serial: 60,
      id: 'connecting_words',
      title: 'And, But, Or, Because & So',
      shortMeaning:
      'দুটি কথা বা sentence যুক্ত করতে',
      explanation:
      'কথা যোগ, বিপরীত কথা, বিকল্প, কারণ ও ফলাফল প্রকাশ করতে connecting word ব্যবহার হয়।',
      structure: 'Clause + connector + clause',
      level: RuleLevel.preIntermediate,
      category: 'Questions',
    ),
  ];
}

class _RuleSeed {
  final int serial;
  final String id;
  final String title;
  final String shortMeaning;
  final String explanation;
  final String structure;
  final RuleLevel level;
  final String category;

  const _RuleSeed({
    required this.serial,
    required this.id,
    required this.title,
    required this.shortMeaning,
    required this.explanation,
    required this.structure,
    required this.level,
    required this.category,
  });
}