import 'package:flutter/material.dart';

class FreelancerLesson {
  final int id;
  final int chapter;
  final String chapterTitle;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<FreelancerPhrase> phrases;
  final List<BuyerTurn> conversation;

  const FreelancerLesson({
    required this.id,
    required this.chapter,
    required this.chapterTitle,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.phrases,
    required this.conversation,
  });
}

class FreelancerPhrase {
  final String english;
  final String bangla;

  const FreelancerPhrase(this.english, this.bangla);
}

class BuyerTurn {
  final String buyerMessage;
  final String banglaMeaning;
  final List<String> acceptedReplies;
  final String hint;

  const BuyerTurn({
    required this.buyerMessage,
    required this.banglaMeaning,
    required this.acceptedReplies,
    required this.hint,
  });
}
