import 'package:flutter/material.dart';

import '../models/freelancer_lesson.dart';

abstract final class FreelancerCourseData {
  static const List<FreelancerLesson> lessons = <FreelancerLesson>[
    FreelancerLesson(
      id: 1,
      chapter: 1,
      chapterTitle: 'First Contact',
      title: 'Reply to the First Message',
      subtitle: 'Respond quickly, politely and professionally.',
      icon: Icons.mark_chat_unread_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Hello! Thank you for contacting me.',
          'হ্যালো! যোগাযোগ করার জন্য ধন্যবাদ।',
        ),
        FreelancerPhrase(
          'I would be happy to help.',
          'আমি আনন্দের সঙ্গে সাহায্য করব।',
        ),
        FreelancerPhrase(
          'Please share the project details.',
          'অনুগ্রহ করে প্রজেক্টের বিস্তারিত জানান।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Hello, are you available for a project?',
          banglaMeaning:
              'হ্যালো, আপনি কি একটি প্রজেক্টের জন্য সময় দিতে পারবেন?',
          acceptedReplies: <String>[
            'Hello! Yes, I am available.',
            'Yes, I am available for the project.',
          ],
          hint: 'Say hello and confirm that you are available.',
        ),
        BuyerTurn(
          buyerMessage: 'Can you build a landing page?',
          banglaMeaning: 'আপনি কি একটি ল্যান্ডিং পেজ তৈরি করতে পারবেন?',
          acceptedReplies: <String>[
            'Yes, I can build a landing page.',
            'I would be happy to build it.',
          ],
          hint: 'Confirm your ability professionally.',
        ),
        BuyerTurn(
          buyerMessage: 'What information do you need?',
          banglaMeaning: 'আপনার কী তথ্য প্রয়োজন?',
          acceptedReplies: <String>[
            'Please share the project details.',
            'Please share your requirements.',
          ],
          hint: 'Ask for the project requirements.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 2,
      chapter: 1,
      chapterTitle: 'First Contact',
      title: 'Introduce Yourself',
      subtitle: 'Explain your skills with a short introduction.',
      icon: Icons.person_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'I am a Flutter developer.',
          'আমি একজন Flutter ডেভেলপার।',
        ),
        FreelancerPhrase(
          'I have four years of experience.',
          'আমার চার বছরের অভিজ্ঞতা আছে।',
        ),
        FreelancerPhrase(
          'I specialize in mobile applications.',
          'আমি মোবাইল অ্যাপ্লিকেশনে বিশেষজ্ঞ।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Please tell me about yourself.',
          banglaMeaning: 'অনুগ্রহ করে নিজের সম্পর্কে বলুন।',
          acceptedReplies: <String>[
            'I am a Flutter developer.',
            'I am a professional mobile app developer.',
          ],
          hint: 'Mention your profession.',
        ),
        BuyerTurn(
          buyerMessage: 'How much experience do you have?',
          banglaMeaning: 'আপনার কত বছরের অভিজ্ঞতা আছে?',
          acceptedReplies: <String>[
            'I have four years of experience.',
            'I have several years of experience.',
          ],
          hint: 'Mention your experience clearly.',
        ),
        BuyerTurn(
          buyerMessage: 'What do you specialize in?',
          banglaMeaning: 'আপনি কোন বিষয়ে বিশেষজ্ঞ?',
          acceptedReplies: <String>[
            'I specialize in mobile applications.',
            'I specialize in Flutter development.',
          ],
          hint: 'Describe your main skill.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 3,
      chapter: 1,
      chapterTitle: 'First Contact',
      title: 'Understand Client Needs',
      subtitle: 'Identify the buyer’s real goal and expectations.',
      icon: Icons.manage_search_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase('What is your main goal?', 'আপনার প্রধান লক্ষ্য কী?'),
        FreelancerPhrase(
          'Who is your target audience?',
          'আপনার লক্ষ্য ব্যবহারকারী কারা?',
        ),
        FreelancerPhrase(
          'I understand your requirements.',
          'আমি আপনার প্রয়োজনগুলো বুঝেছি।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'I need an app for my business.',
          banglaMeaning: 'আমার ব্যবসার জন্য একটি অ্যাপ প্রয়োজন।',
          acceptedReplies: <String>[
            'What is your main goal?',
            'Could you explain your main goal?',
          ],
          hint: 'Ask about the goal.',
        ),
        BuyerTurn(
          buyerMessage: 'The app is for new customers.',
          banglaMeaning: 'অ্যাপটি নতুন গ্রাহকদের জন্য।',
          acceptedReplies: <String>[
            'Who is your target audience?',
            'Could you describe your target audience?',
          ],
          hint: 'Ask about the audience.',
        ),
        BuyerTurn(
          buyerMessage: 'That is everything I need.',
          banglaMeaning: 'এটাই আমার প্রয়োজন।',
          acceptedReplies: <String>[
            'I understand your requirements.',
            'Thank you. I understand the requirements.',
          ],
          hint: 'Confirm your understanding.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 4,
      chapter: 2,
      chapterTitle: 'Requirements & Agreement',
      title: 'Ask Clear Questions',
      subtitle: 'Remove confusion before starting the project.',
      icon: Icons.help_center_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Which features do you need?',
          'আপনার কোন কোন ফিচার প্রয়োজন?',
        ),
        FreelancerPhrase(
          'Do you have a reference?',
          'আপনার কাছে কোনো রেফারেন্স আছে?',
        ),
        FreelancerPhrase(
          'Could you explain this part?',
          'এই অংশটি একটু বুঝিয়ে বলবেন?',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'The app needs several features.',
          banglaMeaning: 'অ্যাপটিতে কয়েকটি ফিচার প্রয়োজন।',
          acceptedReplies: <String>[
            'Which features do you need?',
            'Could you list the required features?',
          ],
          hint: 'Ask for the feature list.',
        ),
        BuyerTurn(
          buyerMessage: 'I want a modern design.',
          banglaMeaning: 'আমি একটি আধুনিক ডিজাইন চাই।',
          acceptedReplies: <String>[
            'Do you have a reference?',
            'Could you share a design reference?',
          ],
          hint: 'Ask for a visual reference.',
        ),
        BuyerTurn(
          buyerMessage: 'The checkout should be simple.',
          banglaMeaning: 'চেকআউটটি সহজ হওয়া উচিত।',
          acceptedReplies: <String>[
            'Could you explain this part?',
            'Could you explain the checkout flow?',
          ],
          hint: 'Ask for clarification.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 5,
      chapter: 2,
      chapterTitle: 'Requirements & Agreement',
      title: 'Confirm the Requirements',
      subtitle: 'Repeat the scope clearly and receive confirmation.',
      icon: Icons.fact_check_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Let me confirm the requirements.',
          'আমি প্রয়োজনগুলো নিশ্চিত করে নিচ্ছি।',
        ),
        FreelancerPhrase(
          'The app will have five screens.',
          'অ্যাপটিতে পাঁচটি স্ক্রিন থাকবে।',
        ),
        FreelancerPhrase('Is that correct?', 'এটি কি সঠিক?'),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Have you understood the project?',
          banglaMeaning: 'আপনি কি প্রজেক্টটি বুঝেছেন?',
          acceptedReplies: <String>[
            'Let me confirm the requirements.',
            'Yes. Let me confirm the requirements.',
          ],
          hint: 'Start confirming the scope.',
        ),
        BuyerTurn(
          buyerMessage: 'How many screens will it have?',
          banglaMeaning: 'এতে কতটি স্ক্রিন থাকবে?',
          acceptedReplies: <String>[
            'The app will have five screens.',
            'It will have five screens.',
          ],
          hint: 'State the agreed screen count.',
        ),
        BuyerTurn(
          buyerMessage: 'Anything else?',
          banglaMeaning: 'আর কিছু?',
          acceptedReplies: <String>[
            'Is that correct?',
            'Please confirm if that is correct.',
          ],
          hint: 'Ask the buyer to confirm.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 6,
      chapter: 2,
      chapterTitle: 'Requirements & Agreement',
      title: 'Discuss Price & Budget',
      subtitle: 'Talk about money politely and confidently.',
      icon: Icons.payments_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase('What is your budget?', 'আপনার বাজেট কত?'),
        FreelancerPhrase(
          'My price is fifty dollars.',
          'আমার মূল্য পঞ্চাশ ডলার।',
        ),
        FreelancerPhrase(
          'This includes two revisions.',
          'এর মধ্যে দুটি revision অন্তর্ভুক্ত।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'How much will you charge?',
          banglaMeaning: 'আপনি কত টাকা নেবেন?',
          acceptedReplies: <String>[
            'My price is fifty dollars.',
            'I will charge fifty dollars.',
          ],
          hint: 'State your price politely.',
        ),
        BuyerTurn(
          buyerMessage: 'Can you reduce the price?',
          banglaMeaning: 'আপনি কি মূল্য কমাতে পারবেন?',
          acceptedReplies: <String>[
            'I can offer a small discount.',
            'I can reduce the price slightly.',
          ],
          hint: 'Offer a small discount politely.',
        ),
        BuyerTurn(
          buyerMessage: 'How many revisions are included?',
          banglaMeaning: 'কতটি revision অন্তর্ভুক্ত?',
          acceptedReplies: <String>[
            'This includes two revisions.',
            'Two revisions are included.',
          ],
          hint: 'Explain the revision limit.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 7,
      chapter: 2,
      chapterTitle: 'Requirements & Agreement',
      title: 'Set Deadline & Confirm',
      subtitle: 'Agree on scope, price and delivery time.',
      icon: Icons.event_available_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'I can deliver it by Friday.',
          'আমি শুক্রবারের মধ্যে এটি দিতে পারব।',
        ),
        FreelancerPhrase(
          'The project will take five days.',
          'প্রজেক্টটি করতে পাঁচ দিন লাগবে।',
        ),
        FreelancerPhrase(
          'We can start after confirmation.',
          'নিশ্চিত করার পর আমরা শুরু করতে পারি।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'When can you deliver the project?',
          banglaMeaning: 'আপনি কখন প্রজেক্টটি দিতে পারবেন?',
          acceptedReplies: <String>[
            'I can deliver it by Friday.',
            'I can deliver the project by Friday.',
          ],
          hint: 'Give a clear delivery date.',
        ),
        BuyerTurn(
          buyerMessage: 'How long will it take?',
          banglaMeaning: 'কত সময় লাগবে?',
          acceptedReplies: <String>[
            'The project will take five days.',
            'It will take five days.',
          ],
          hint: 'State the duration.',
        ),
        BuyerTurn(
          buyerMessage: 'Can we start now?',
          banglaMeaning: 'আমরা কি এখন শুরু করতে পারি?',
          acceptedReplies: <String>[
            'We can start after confirmation.',
            'Yes, we can start after confirmation.',
          ],
          hint: 'Confirm the next step.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 8,
      chapter: 3,
      chapterTitle: 'Working with the Client',
      title: 'Start the Project',
      subtitle: 'Collect resources and begin professionally.',
      icon: Icons.rocket_launch_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'I am ready to start.',
          'আমি শুরু করার জন্য প্রস্তুত।',
        ),
        FreelancerPhrase(
          'Please send the required files.',
          'প্রয়োজনীয় ফাইলগুলো পাঠান।',
        ),
        FreelancerPhrase(
          'I will update you tomorrow.',
          'আমি আগামীকাল আপনাকে update দেব।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'The project is confirmed.',
          banglaMeaning: 'প্রজেক্টটি নিশ্চিত হয়েছে।',
          acceptedReplies: <String>[
            'Thank you. I am ready to start.',
            'I am ready to start.',
          ],
          hint: 'Confirm that you can begin.',
        ),
        BuyerTurn(
          buyerMessage: 'What do you need from me?',
          banglaMeaning: 'আমার কাছ থেকে আপনার কী প্রয়োজন?',
          acceptedReplies: <String>[
            'Please send the required files.',
            'Please send the content and logo.',
          ],
          hint: 'Ask for project resources.',
        ),
        BuyerTurn(
          buyerMessage: 'When will I receive an update?',
          banglaMeaning: 'আমি কখন update পাব?',
          acceptedReplies: <String>[
            'I will update you tomorrow.',
            'You will receive an update tomorrow.',
          ],
          hint: 'Promise a realistic update time.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 9,
      chapter: 3,
      chapterTitle: 'Working with the Client',
      title: 'Give Progress Updates',
      subtitle: 'Keep the buyer informed without being asked.',
      icon: Icons.update_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'I have completed the homepage.',
          'আমি homepage সম্পন্ন করেছি।',
        ),
        FreelancerPhrase(
          'I am working on the dashboard.',
          'আমি dashboard-এর কাজ করছি।',
        ),
        FreelancerPhrase(
          'I will send a preview today.',
          'আমি আজ একটি preview পাঠাব।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'How is the project going?',
          banglaMeaning: 'প্রজেক্টের কাজ কেমন চলছে?',
          acceptedReplies: <String>[
            'The project is going well.',
            'Everything is progressing well.',
          ],
          hint: 'Give a short status update.',
        ),
        BuyerTurn(
          buyerMessage: 'What have you completed?',
          banglaMeaning: 'আপনি কী সম্পন্ন করেছেন?',
          acceptedReplies: <String>[
            'I have completed the homepage.',
            'The homepage is complete.',
          ],
          hint: 'Mention the completed work.',
        ),
        BuyerTurn(
          buyerMessage: 'Can I see the current version?',
          banglaMeaning: 'আমি কি বর্তমান version দেখতে পারি?',
          acceptedReplies: <String>[
            'I will send a preview today.',
            'Yes, I will share a preview today.',
          ],
          hint: 'Confirm when you will share it.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 10,
      chapter: 3,
      chapterTitle: 'Working with the Client',
      title: 'Join Meetings & Calls',
      subtitle: 'Speak clearly during a professional meeting.',
      icon: Icons.video_call_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Can you hear me clearly?',
          'আপনি কি আমাকে পরিষ্কার শুনতে পাচ্ছেন?',
        ),
        FreelancerPhrase(
          'Could you repeat that, please?',
          'অনুগ্রহ করে কথাটি আবার বলবেন?',
        ),
        FreelancerPhrase(
          'Let me share my screen.',
          'আমি আমার screen share করছি।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Hello, can you hear me?',
          banglaMeaning: 'হ্যালো, আপনি কি আমাকে শুনতে পাচ্ছেন?',
          acceptedReplies: <String>[
            'Yes, I can hear you clearly.',
            'Yes, I can hear you.',
          ],
          hint: 'Confirm the audio.',
        ),
        BuyerTurn(
          buyerMessage: 'I want to explain a new feature.',
          banglaMeaning: 'আমি একটি নতুন feature বুঝিয়ে বলতে চাই।',
          acceptedReplies: <String>[
            'Sure, please go ahead.',
            'Of course. Please explain it.',
          ],
          hint: 'Invite the buyer to continue.',
        ),
        BuyerTurn(
          buyerMessage: 'Can you show me the current work?',
          banglaMeaning: 'বর্তমান কাজটি দেখাতে পারবেন?',
          acceptedReplies: <String>[
            'Yes. Let me share my screen.',
            'Sure, I will share my screen.',
          ],
          hint: 'Offer to share your screen.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 11,
      chapter: 4,
      chapterTitle: 'Feedback & Problems',
      title: 'Handle Feedback & Revisions',
      subtitle: 'Receive feedback calmly and confirm changes.',
      icon: Icons.rate_review_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Thank you for the feedback.',
          'মতামতের জন্য ধন্যবাদ।',
        ),
        FreelancerPhrase('I will make the changes.', 'আমি পরিবর্তনগুলো করব।'),
        FreelancerPhrase(
          'Please list the revisions.',
          'অনুগ্রহ করে revisionগুলো তালিকা করুন।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'I need a few changes.',
          banglaMeaning: 'আমার কয়েকটি পরিবর্তন প্রয়োজন।',
          acceptedReplies: <String>[
            'Sure. Please list the revisions.',
            'Of course. Please share the changes.',
          ],
          hint: 'Ask for a clear revision list.',
        ),
        BuyerTurn(
          buyerMessage: 'Please change the main color.',
          banglaMeaning: 'মূল রংটি পরিবর্তন করুন।',
          acceptedReplies: <String>[
            'I will make the change.',
            'Sure, I will change the main color.',
          ],
          hint: 'Confirm the requested change.',
        ),
        BuyerTurn(
          buyerMessage: 'Can you finish it today?',
          banglaMeaning: 'আজ এটি শেষ করতে পারবেন?',
          acceptedReplies: <String>[
            'Yes, I will finish it today.',
            'I can complete the revision today.',
          ],
          hint: 'Confirm a realistic revision time.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 12,
      chapter: 4,
      chapterTitle: 'Feedback & Problems',
      title: 'Handle Extra Work',
      subtitle: 'Protect the scope and charge for extra tasks.',
      icon: Icons.add_task_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'This is outside the original scope.',
          'এটি মূল কাজের সীমার বাইরে।',
        ),
        FreelancerPhrase(
          'This will require extra time.',
          'এটির জন্য অতিরিক্ত সময় প্রয়োজন।',
        ),
        FreelancerPhrase(
          'I can send a custom offer.',
          'আমি একটি custom offer পাঠাতে পারি।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Can you add another page?',
          banglaMeaning: 'আপনি কি আরেকটি page যোগ করতে পারবেন?',
          acceptedReplies: <String>[
            'Yes, but this is outside the original scope.',
            'I can add it as extra work.',
          ],
          hint: 'Mention that it is extra work.',
        ),
        BuyerTurn(
          buyerMessage: 'Will it affect the deadline?',
          banglaMeaning: 'এতে কি deadline পরিবর্তন হবে?',
          acceptedReplies: <String>[
            'This will require extra time.',
            'Yes, it will require additional time.',
          ],
          hint: 'Explain the time impact.',
        ),
        BuyerTurn(
          buyerMessage: 'How can we proceed?',
          banglaMeaning: 'আমরা কীভাবে এগোতে পারি?',
          acceptedReplies: <String>[
            'I can send a custom offer.',
            'I will send an additional offer.',
          ],
          hint: 'Suggest a professional next step.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 13,
      chapter: 4,
      chapterTitle: 'Feedback & Problems',
      title: 'Explain Delays & Problems',
      subtitle: 'Be honest, offer a solution and request time.',
      icon: Icons.warning_amber_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'I encountered a technical issue.',
          'আমি একটি technical সমস্যার সম্মুখীন হয়েছি।',
        ),
        FreelancerPhrase(
          'I am working on a solution.',
          'আমি সমাধানের কাজ করছি।',
        ),
        FreelancerPhrase('I need one extra day.', 'আমার আরও এক দিন প্রয়োজন।'),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Why is the project delayed?',
          banglaMeaning: 'প্রজেক্টটি দেরি হচ্ছে কেন?',
          acceptedReplies: <String>[
            'I encountered a technical issue.',
            'There was an unexpected technical issue.',
          ],
          hint: 'Explain the issue briefly.',
        ),
        BuyerTurn(
          buyerMessage: 'What are you doing about it?',
          banglaMeaning: 'আপনি এটি সমাধানে কী করছেন?',
          acceptedReplies: <String>[
            'I am working on a solution.',
            'I am fixing the issue now.',
          ],
          hint: 'Focus on the solution.',
        ),
        BuyerTurn(
          buyerMessage: 'When will it be ready?',
          banglaMeaning: 'এটি কখন প্রস্তুত হবে?',
          acceptedReplies: <String>[
            'I need one extra day.',
            'It will be ready tomorrow.',
          ],
          hint: 'Give a clear updated deadline.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 14,
      chapter: 5,
      chapterTitle: 'Delivery & Success',
      title: 'Deliver the Final Project',
      subtitle: 'Present the finished work and guide the buyer.',
      icon: Icons.inventory_2_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'The project is now complete.',
          'প্রজেক্টটি এখন সম্পন্ন।',
        ),
        FreelancerPhrase(
          'I have attached all files.',
          'আমি সব ফাইল যুক্ত করেছি।',
        ),
        FreelancerPhrase(
          'Please review the final version.',
          'অনুগ্রহ করে final version দেখুন।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Is the project complete?',
          banglaMeaning: 'প্রজেক্টটি কি সম্পন্ন হয়েছে?',
          acceptedReplies: <String>[
            'Yes, the project is now complete.',
            'The project is complete.',
          ],
          hint: 'Confirm completion.',
        ),
        BuyerTurn(
          buyerMessage: 'Where are the files?',
          banglaMeaning: 'ফাইলগুলো কোথায়?',
          acceptedReplies: <String>[
            'I have attached all files.',
            'All files are attached.',
          ],
          hint: 'Tell the buyer about the files.',
        ),
        BuyerTurn(
          buyerMessage: 'What should I do next?',
          banglaMeaning: 'এরপর আমার কী করা উচিত?',
          acceptedReplies: <String>[
            'Please review the final version.',
            'Please review and confirm the delivery.',
          ],
          hint: 'Ask the buyer to review.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 15,
      chapter: 5,
      chapterTitle: 'Delivery & Success',
      title: 'Payment & Review',
      subtitle: 'Follow up politely and request feedback.',
      icon: Icons.reviews_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Please approve the final delivery.',
          'অনুগ্রহ করে final delivery approve করুন।',
        ),
        FreelancerPhrase(
          'Could you release the payment?',
          'আপনি কি payment release করতে পারবেন?',
        ),
        FreelancerPhrase(
          'Your feedback would help me.',
          'আপনার feedback আমাকে সাহায্য করবে।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Everything looks good.',
          banglaMeaning: 'সবকিছু ভালো দেখাচ্ছে।',
          acceptedReplies: <String>[
            'Thank you. Please approve the final delivery.',
            'Thank you for confirming the work.',
          ],
          hint: 'Thank the buyer and request approval.',
        ),
        BuyerTurn(
          buyerMessage: 'Is there anything else?',
          banglaMeaning: 'আর কিছু আছে?',
          acceptedReplies: <String>[
            'Could you release the payment?',
            'Please release the payment when convenient.',
          ],
          hint: 'Request payment politely.',
        ),
        BuyerTurn(
          buyerMessage: 'I will complete the order now.',
          banglaMeaning: 'আমি এখন order complete করব।',
          acceptedReplies: <String>[
            'Thank you. Your feedback would help me.',
            'Thank you. I would appreciate your review.',
          ],
          hint: 'Ask for an honest review.',
        ),
      ],
    ),
    FreelancerLesson(
      id: 16,
      chapter: 5,
      chapterTitle: 'Delivery & Success',
      title: 'Final Client Simulation',
      subtitle: 'Complete a full client conversation confidently.',
      icon: Icons.workspace_premium_rounded,
      phrases: <FreelancerPhrase>[
        FreelancerPhrase(
          'Thank you for contacting me.',
          'যোগাযোগ করার জন্য ধন্যবাদ।',
        ),
        FreelancerPhrase(
          'I understand your requirements.',
          'আমি আপনার প্রয়োজনগুলো বুঝেছি।',
        ),
        FreelancerPhrase(
          'Please review the final delivery.',
          'অনুগ্রহ করে final delivery দেখুন।',
        ),
      ],
      conversation: <BuyerTurn>[
        BuyerTurn(
          buyerMessage: 'Hello, can you develop my mobile app?',
          banglaMeaning: 'হ্যালো, আপনি কি আমার mobile app তৈরি করতে পারবেন?',
          acceptedReplies: <String>[
            'Hello! Yes, I can develop your mobile app.',
            'Yes, I would be happy to help.',
          ],
          hint: 'Greet the buyer and confirm your ability.',
        ),
        BuyerTurn(
          buyerMessage: 'What information do you need?',
          banglaMeaning: 'আপনার কী তথ্য প্রয়োজন?',
          acceptedReplies: <String>[
            'Please share your complete requirements.',
            'Please share the features and design reference.',
          ],
          hint: 'Ask for clear requirements.',
        ),
        BuyerTurn(
          buyerMessage: 'Can you deliver it in ten days?',
          banglaMeaning: 'আপনি কি দশ দিনের মধ্যে দিতে পারবেন?',
          acceptedReplies: <String>[
            'Yes, I can deliver it in ten days.',
            'Ten days will be enough for the project.',
          ],
          hint: 'Confirm a realistic deadline.',
        ),
        BuyerTurn(
          buyerMessage: 'The work looks perfect.',
          banglaMeaning: 'কাজটি নিখুঁত হয়েছে।',
          acceptedReplies: <String>[
            'Thank you. Please approve the final delivery.',
            'Thank you. I would appreciate your review.',
          ],
          hint: 'Close the project professionally.',
        ),
      ],
    ),
  ];

  static FreelancerLesson byId(int id) =>
      lessons.firstWhere((FreelancerLesson lesson) => lesson.id == id);
}
