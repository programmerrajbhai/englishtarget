import '../models/freelancer_lesson.dart';

/// Builds a full 10-step session without making the course file unnecessarily
/// large. Every lesson starts with its own topic-specific turns, then practises
/// the professional communication skills required in that chapter.
abstract final class FreelancerPracticeBuilder {
  static List<BuyerTurn> forLesson(FreelancerLesson lesson) {
    final List<BuyerTurn> result = <BuyerTurn>[
      ...lesson.conversation,
      ...?_chapterPractice[lesson.chapter],
    ];
    return List<BuyerTurn>.unmodifiable(result.take(10));
  }

  static const Map<int, List<BuyerTurn>>
  _chapterPractice = <int, List<BuyerTurn>>{
    1: <BuyerTurn>[
      BuyerTurn(
        buyerMessage: 'Have you worked on a similar project?',
        banglaMeaning: 'আপনি কি এমন কোনো প্রজেক্টে আগে কাজ করেছেন?',
        acceptedReplies: <String>[
          'Yes, I have worked on similar projects.',
          'Yes, I have relevant experience.',
        ],
        hint: 'Confirm your relevant experience.',
      ),
      BuyerTurn(
        buyerMessage: 'Can you share an example of your work?',
        banglaMeaning: 'আপনি কি আপনার কাজের একটি উদাহরণ দেখাতে পারবেন?',
        acceptedReplies: <String>[
          'Yes, I can share a relevant example.',
          'Certainly, I will share my portfolio.',
        ],
        hint: 'Offer a relevant example or portfolio.',
      ),
      BuyerTurn(
        buyerMessage: 'Are you available to discuss the details?',
        banglaMeaning: 'আপনি কি বিস্তারিত আলোচনা করার জন্য সময় দিতে পারবেন?',
        acceptedReplies: <String>[
          'Yes, I am available to discuss the details.',
          'Yes, please share a convenient time.',
        ],
        hint: 'Confirm availability politely.',
      ),
      BuyerTurn(
        buyerMessage: 'What information should I send first?',
        banglaMeaning: 'প্রথমে আমার কোন তথ্য পাঠানো উচিত?',
        acceptedReplies: <String>[
          'Please send the project requirements first.',
          'Please share your goals and required features.',
        ],
        hint: 'Ask for the key requirements.',
      ),
      BuyerTurn(
        buyerMessage: 'Do you understand my business idea?',
        banglaMeaning: 'আপনি কি আমার ব্যবসার ধারণাটি বুঝেছেন?',
        acceptedReplies: <String>[
          'Yes, I understand your business idea.',
          'Yes, I understand the main goal.',
        ],
        hint: 'Confirm your understanding.',
      ),
      BuyerTurn(
        buyerMessage: 'Can we continue this conversation tomorrow?',
        banglaMeaning: 'আমরা কি আগামীকাল এই আলোচনা চালিয়ে যেতে পারি?',
        acceptedReplies: <String>[
          'Yes, we can continue tomorrow.',
          'Certainly, please message me tomorrow.',
        ],
        hint: 'Agree and remain professional.',
      ),
      BuyerTurn(
        buyerMessage: 'Why should I choose you?',
        banglaMeaning: 'আমি কেন আপনাকে বেছে নেব?',
        acceptedReplies: <String>[
          'I communicate clearly and deliver quality work.',
          'I am reliable and focused on quality.',
        ],
        hint: 'Give one short professional strength.',
      ),
    ],
    2: <BuyerTurn>[
      BuyerTurn(
        buyerMessage: 'What exactly is included in your offer?',
        banglaMeaning: 'আপনার অফারে ঠিক কী কী অন্তর্ভুক্ত?',
        acceptedReplies: <String>[
          'The agreed features and two revisions are included.',
          'The complete agreed scope is included.',
        ],
        hint: 'Explain what the offer includes.',
      ),
      BuyerTurn(
        buyerMessage: 'Can you summarize the project scope?',
        banglaMeaning: 'আপনি কি প্রজেক্টের কাজগুলো সংক্ষেপে বলতে পারবেন?',
        acceptedReplies: <String>[
          'Yes, I will summarize the complete project scope.',
          'Certainly, let me confirm the agreed requirements.',
        ],
        hint: 'Offer a clear scope summary.',
      ),
      BuyerTurn(
        buyerMessage: 'Does your price include revisions?',
        banglaMeaning: 'আপনার মূল্যের মধ্যে কি revision অন্তর্ভুক্ত?',
        acceptedReplies: <String>[
          'Yes, the price includes two revisions.',
          'Two revisions are included in the price.',
        ],
        hint: 'State the revision limit.',
      ),
      BuyerTurn(
        buyerMessage: 'Can you begin this week?',
        banglaMeaning: 'আপনি কি এই সপ্তাহে শুরু করতে পারবেন?',
        acceptedReplies: <String>[
          'Yes, I can begin this week.',
          'Yes, I can start after confirmation.',
        ],
        hint: 'Confirm a realistic start time.',
      ),
      BuyerTurn(
        buyerMessage: 'How will we confirm the requirements?',
        banglaMeaning: 'আমরা কীভাবে প্রয়োজনগুলো নিশ্চিত করব?',
        acceptedReplies: <String>[
          'I will send a written summary for confirmation.',
          'I will list the requirements for your approval.',
        ],
        hint: 'Suggest written confirmation.',
      ),
      BuyerTurn(
        buyerMessage: 'What happens if I need extra features?',
        banglaMeaning: 'আমার অতিরিক্ত feature প্রয়োজন হলে কী হবে?',
        acceptedReplies: <String>[
          'We can discuss a separate offer for extra features.',
          'Extra features may require more time and budget.',
        ],
        hint: 'Protect the agreed scope politely.',
      ),
      BuyerTurn(
        buyerMessage: 'Are we ready to start the project?',
        banglaMeaning: 'আমরা কি প্রজেক্ট শুরু করার জন্য প্রস্তুত?',
        acceptedReplies: <String>[
          'Yes, we can start after your confirmation.',
          'Yes, the scope, budget, and deadline are clear.',
        ],
        hint: 'Confirm all key terms.',
      ),
    ],
    3: <BuyerTurn>[
      BuyerTurn(
        buyerMessage: 'Did you receive all the files?',
        banglaMeaning: 'আপনি কি সব ফাইল পেয়েছেন?',
        acceptedReplies: <String>[
          'Yes, I received all the files.',
          'Yes, thank you for sending the files.',
        ],
        hint: 'Confirm receipt clearly.',
      ),
      BuyerTurn(
        buyerMessage: 'What are you working on today?',
        banglaMeaning: 'আপনি আজ কোন কাজটি করছেন?',
        acceptedReplies: <String>[
          'I am working on the main interface today.',
          'Today I am completing the current milestone.',
        ],
        hint: 'Give a specific progress update.',
      ),
      BuyerTurn(
        buyerMessage: 'Is everything going as planned?',
        banglaMeaning: 'সবকিছু কি পরিকল্পনা অনুযায়ী চলছে?',
        acceptedReplies: <String>[
          'Yes, everything is going as planned.',
          'Yes, the project is on schedule.',
        ],
        hint: 'Confirm the project status.',
      ),
      BuyerTurn(
        buyerMessage: 'When will you send the next update?',
        banglaMeaning: 'আপনি পরবর্তী update কখন পাঠাবেন?',
        acceptedReplies: <String>[
          'I will send the next update tomorrow.',
          'You will receive another update tomorrow.',
        ],
        hint: 'Give a clear update time.',
      ),
      BuyerTurn(
        buyerMessage: 'Can we have a quick call?',
        banglaMeaning: 'আমরা কি একটি ছোট call করতে পারি?',
        acceptedReplies: <String>[
          'Yes, please share a convenient time.',
          'Certainly, I am available for a quick call.',
        ],
        hint: 'Accept and arrange a time.',
      ),
      BuyerTurn(
        buyerMessage: 'Could you explain the current progress?',
        banglaMeaning: 'বর্তমান অগ্রগতি একটু বুঝিয়ে বলবেন?',
        acceptedReplies: <String>[
          'Yes, I have completed the first milestone.',
          'Certainly, let me explain the current progress.',
        ],
        hint: 'Summarize the completed work.',
      ),
      BuyerTurn(
        buyerMessage: 'Do you need anything else from me?',
        banglaMeaning: 'আমার কাছ থেকে আর কিছু প্রয়োজন?',
        acceptedReplies: <String>[
          'No, I have everything I need right now.',
          'I will let you know if I need anything else.',
        ],
        hint: 'Respond politely and clearly.',
      ),
    ],
    4: <BuyerTurn>[
      BuyerTurn(
        buyerMessage: 'Can you make one more change?',
        banglaMeaning: 'আপনি কি আরও একটি পরিবর্তন করতে পারবেন?',
        acceptedReplies: <String>[
          'Yes, please share the exact change.',
          'Certainly, please describe the required change.',
        ],
        hint: 'Ask for a specific revision.',
      ),
      BuyerTurn(
        buyerMessage: 'Why will this change cost extra?',
        banglaMeaning: 'এই পরিবর্তনের জন্য অতিরিক্ত খরচ কেন হবে?',
        acceptedReplies: <String>[
          'Because it is outside the agreed project scope.',
          'This change requires additional work and time.',
        ],
        hint: 'Explain the scope calmly.',
      ),
      BuyerTurn(
        buyerMessage: 'Can you solve this issue today?',
        banglaMeaning: 'আপনি কি আজ এই সমস্যাটি সমাধান করতে পারবেন?',
        acceptedReplies: <String>[
          'I will do my best to solve it today.',
          'I am working on the solution now.',
        ],
        hint: 'Promise only what is realistic.',
      ),
      BuyerTurn(
        buyerMessage: 'How much extra time do you need?',
        banglaMeaning: 'আপনার কতটা অতিরিক্ত সময় প্রয়োজন?',
        acceptedReplies: <String>[
          'I need one additional day.',
          'I need one more day to complete it properly.',
        ],
        hint: 'Request a precise extension.',
      ),
      BuyerTurn(
        buyerMessage: 'Will this problem happen again?',
        banglaMeaning: 'এই সমস্যাটি কি আবার হবে?',
        acceptedReplies: <String>[
          'I am taking steps to prevent it.',
          'I will test the solution carefully.',
        ],
        hint: 'Explain your prevention plan.',
      ),
      BuyerTurn(
        buyerMessage: 'Please keep me updated.',
        banglaMeaning: 'অনুগ্রহ করে আমাকে update জানাবেন।',
        acceptedReplies: <String>[
          'Certainly, I will keep you updated.',
          'Of course, I will share regular updates.',
        ],
        hint: 'Reassure the buyer.',
      ),
      BuyerTurn(
        buyerMessage: 'Can we agree on the new deadline?',
        banglaMeaning: 'আমরা কি নতুন deadline নিশ্চিত করতে পারি?',
        acceptedReplies: <String>[
          'Yes, the new deadline will be tomorrow.',
          'Yes, I confirm the updated deadline.',
        ],
        hint: 'Confirm the revised deadline.',
      ),
    ],
    5: <BuyerTurn>[
      BuyerTurn(
        buyerMessage: 'Has everything been tested?',
        banglaMeaning: 'সবকিছু কি পরীক্ষা করা হয়েছে?',
        acceptedReplies: <String>[
          'Yes, I have tested all the main features.',
          'Yes, everything has been carefully tested.',
        ],
        hint: 'Confirm final testing.',
      ),
      BuyerTurn(
        buyerMessage: 'Did you include the source files?',
        banglaMeaning: 'আপনি কি source file-গুলো যুক্ত করেছেন?',
        acceptedReplies: <String>[
          'Yes, all source files are included.',
          'Yes, I attached the complete source files.',
        ],
        hint: 'Confirm the included files.',
      ),
      BuyerTurn(
        buyerMessage: 'Can you explain how to use it?',
        banglaMeaning: 'এটি কীভাবে ব্যবহার করতে হবে বুঝিয়ে বলবেন?',
        acceptedReplies: <String>[
          'Yes, I will provide clear instructions.',
          'Certainly, I can guide you through it.',
        ],
        hint: 'Offer simple guidance.',
      ),
      BuyerTurn(
        buyerMessage: 'What if I find a small issue?',
        banglaMeaning: 'আমি ছোট কোনো সমস্যা পেলে কী হবে?',
        acceptedReplies: <String>[
          'Please message me and I will check it.',
          'I will help you with any confirmed issue.',
        ],
        hint: 'Offer reasonable support.',
      ),
      BuyerTurn(
        buyerMessage: 'How do I approve the delivery?',
        banglaMeaning: 'আমি delivery কীভাবে approve করব?',
        acceptedReplies: <String>[
          'Please review the files and approve the delivery.',
          'You can approve it after checking the final work.',
        ],
        hint: 'Explain the approval step.',
      ),
      BuyerTurn(
        buyerMessage: 'Can I contact you for future work?',
        banglaMeaning: 'ভবিষ্যৎ কাজের জন্য কি আপনার সঙ্গে যোগাযোগ করতে পারি?',
        acceptedReplies: <String>[
          'Yes, I would be happy to work with you again.',
          'Certainly, you can contact me anytime.',
        ],
        hint: 'Welcome future work.',
      ),
      BuyerTurn(
        buyerMessage: 'Thank you for your work.',
        banglaMeaning: 'আপনার কাজের জন্য ধন্যবাদ।',
        acceptedReplies: <String>[
          'Thank you for the opportunity.',
          'You are welcome. It was a pleasure working with you.',
        ],
        hint: 'Close the conversation warmly.',
      ),
    ],
  };
}
