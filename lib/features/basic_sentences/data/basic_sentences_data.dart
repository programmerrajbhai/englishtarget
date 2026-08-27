import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/basic_sentence.dart';
import '../models/basic_sentence_topic.dart';
import 'basic_sentence_extra_topics.dart';

abstract final class BasicSentencesData {
  static BasicSentence _fromLine(
      String prefix,
      int index,
      String line,
      IconData icon,
      Color color,
      ) {
    final List<String> parts = line.split('||');

    return BasicSentence(
      id: '${prefix}_$index',
      bengali: parts[0].trim(),
      english: parts[1].trim(),
      visualKey: '${prefix}_$index',
      icon: icon,
      color: color,
    );
  }

  static List<BasicSentence> _makeList(
      String prefix,
      String content,
      IconData icon,
      Color color,
      ) {
    final List<String> lines = content.trim().split('\n');

    return <BasicSentence>[
      for (int index = 0; index < lines.length; index++)
        _fromLine(
          prefix,
          index + 1,
          lines[index],
          icon,
          color,
        ),
    ];
  }

  static final List<BasicSentenceTopic> topics =
  <BasicSentenceTopic>[
    BasicSentenceTopic(
      id: 'introduce_yourself',
      title: 'Introduce Yourself',
      subtitle: 'নিজের পরিচয়',
      icon: Icons.person_rounded,
      color: AppColors.primary,
      sentenceCount: 25,
      learnSentences: _makeList(
        'intro_learn',
        '''
আমার নাম রাজ।||My name is Raj.
আমি একজন ডেভেলপার।||I am a developer.
আমি বাংলাদেশে থাকি।||I live in Bangladesh.
আমি ঢাকা থেকে এসেছি।||I am from Dhaka.
তোমার সঙ্গে দেখা হয়ে ভালো লাগলো।||Nice to meet you.
আমি ইংরেজি শিখছি।||I am learning English.
আমি একজন ছাত্র।||I am a student.
আমি প্রযুক্তি পছন্দ করি।||I like technology.
আমি প্রতিদিন কাজ করি।||I work every day.
আমি নতুন মানুষের সঙ্গে কথা বলতে পছন্দ করি।||I like talking to new people.
''',
        Icons.person_rounded,
        AppColors.primary,
      ),
      buildSentences: _makeList(
        'intro_build',
        '''
আমি একজন ফ্রিল্যান্সার।||I am a freelancer.
আমার বয়স বিশ বছর।||I am twenty years old.
আমি রংপুরে থাকি।||I live in Rangpur.
আমি মোবাইল অ্যাপ তৈরি করি।||I build mobile apps.
আমি ওয়েবসাইট তৈরি করতে পারি।||I can build websites.
আমি প্রতিদিন ইংরেজি অনুশীলন করি।||I practise English every day.
আমার শখ হলো প্রোগ্রামিং।||My hobby is programming.
আমি মানুষের সাহায্য করতে পছন্দ করি।||I like helping people.
আমি একজন পরিশ্রমী মানুষ।||I am a hardworking person.
আমি আমার ভবিষ্যৎ নিয়ে আশাবাদী।||I am hopeful about my future.
''',
        Icons.code_rounded,
        AppColors.primary,
      ),
      speakSentences: _makeList(
        'intro_speak',
        '''
নিজের নাম বলুন।||My name is Raj.
নিজের পেশা বলুন।||I am a software developer.
নিজের দেশ বলুন।||I am from Bangladesh.
আপনি কী শিখছেন বলুন।||I am learning English.
বিদায় জানান।||It was nice talking to you.
''',
        Icons.record_voice_over_rounded,
        AppColors.primary,
      ),
    ),
    BasicSentenceTopic(
      id: 'daily_routine',
      title: 'Daily Routine',
      subtitle: 'দৈনন্দিন কাজ',
      icon: Icons.wb_sunny_rounded,
      color: AppColors.amber,
      sentenceCount: 25,
      learnSentences: _makeList(
        'routine_learn',
        '''
আমি ভোরে ঘুম থেকে উঠি।||I wake up early.
আমি দাঁত ব্রাশ করি।||I brush my teeth.
আমি গোসল করি।||I take a shower.
আমি সকালে নাস্তা করি।||I eat breakfast.
আমি কাজে যাই।||I go to work.
আমি সকালে পড়াশোনা করি।||I study in the morning.
আমি দুপুরে বাসায় ফিরি।||I come home in the afternoon.
আমি একটু বিশ্রাম নিই।||I take a short break.
আমি রাতে রাতের খাবার খাই।||I have dinner at night.
আমি তাড়াতাড়ি ঘুমাতে যাই।||I go to bed early.
''',
        Icons.wb_sunny_rounded,
        AppColors.amber,
      ),
      buildSentences: _makeList(
        'routine_build',
        '''
আমি ছয়টায় ঘুম থেকে উঠি।||I wake up at six.
আমি আমার বিছানা গুছাই।||I make my bed.
ঘুম থেকে উঠে পানি পান করি।||I drink water after waking up.
আমি সকালে ফোন দেখি।||I check my phone in the morning.
আমি নয়টায় কাজ শুরু করি।||I start my work at nine.
আমি একটায় দুপুরের খাবার খাই।||I have lunch at one.
আমি সন্ধ্যায় হাঁটতে যাই।||I go for a walk in the evening.
আমি ঘুমানোর আগে বই পড়ি।||I read a book before bed.
আমি আট ঘণ্টা ঘুমাই।||I sleep for eight hours.
আমি একটি daily routine অনুসরণ করি।||I follow a daily routine.
''',
        Icons.schedule_rounded,
        AppColors.amber,
      ),
      speakSentences: _makeList(
        'routine_speak',
        '''
আপনার সকাল সম্পর্কে বলুন।||I wake up early in the morning.
আপনি কখন নাস্তা করেন বলুন।||I eat breakfast at eight.
আপনার কাজ সম্পর্কে বলুন।||I work during the day.
সন্ধ্যার কাজ বলুন।||I relax in the evening.
রাতে কী করেন বলুন।||I read before I go to bed.
''',
        Icons.access_time_rounded,
        AppColors.amber,
      ),
    ),
    BasicSentenceTopic(
      id: 'family_friends',
      title: 'Family & Friends',
      subtitle: 'পরিবার ও বন্ধু',
      icon: Icons.groups_rounded,
      color: AppColors.blue,
      sentenceCount: 25,
      learnSentences: _makeList(
        'family_learn',
        '''
এটি আমার পরিবার।||This is my family.
আমার একজন ভাই আছে।||I have one brother.
আমার একজন বোন আছে।||I have one sister.
আমার বাবা একজন শিক্ষক।||My father is a teacher.
আমার মা বাসায় থাকেন।||My mother stays at home.
আমার পরিবার ছোট।||My family is small.
আমি আমার পরিবারকে ভালোবাসি।||I love my family.
সে আমার সবচেয়ে ভালো বন্ধু।||He is my best friend.
আমরা একসঙ্গে সময় কাটাই।||We spend time together.
আমার অনেক ভালো বন্ধু আছে।||I have many good friends.
''',
        Icons.groups_rounded,
        AppColors.blue,
      ),
      buildSentences: _makeList(
        'family_build',
        '''
আমার ভাই আমার চেয়ে বড়।||My brother is older than me.
আমার বোন খুব মেধাবী।||My sister is very intelligent.
আমরা একই শহরে থাকি।||We live in the same city.
আমার বাবা প্রতিদিন কাজ করেন।||My father works every day.
আমার মা খুব যত্নশীল।||My mother is very caring.
আমি আমার বন্ধুকে সাহায্য করি।||I help my friend.
আমরা প্রতি সপ্তাহে দেখা করি।||We meet every week.
সে আমার ভালো বন্ধু।||She is a good friend of mine.
আমরা একসঙ্গে খেলি।||We play together.
আমি আমার বন্ধুদের বিশ্বাস করি।||I trust my friends.
''',
        Icons.people_alt_rounded,
        AppColors.blue,
      ),
      speakSentences: _makeList(
        'family_speak',
        '''
আপনার পরিবার সম্পর্কে বলুন।||I have a small family.
আপনার ভাই সম্পর্কে বলুন।||I have one brother.
আপনার মায়ের কথা বলুন।||My mother is very kind.
আপনার বন্ধুর কথা বলুন।||He is my best friend.
পরিবারের প্রতি ভালোবাসা প্রকাশ করুন।||I love my family very much.
''',
        Icons.family_restroom_rounded,
        AppColors.blue,
      ),
    ),
    BasicSentenceTopic(
      id: 'home_house',
      title: 'Home & House',
      subtitle: 'বাড়ি ও ঘর',
      icon: Icons.home_rounded,
      color: AppColors.purple,
      sentenceCount: 25,
      learnSentences: _makeList(
        'home_learn',
        '''
এটি আমার বাড়ি।||This is my house.
আমার বাড়ি বড়।||My house is big.
আমাদের একটি সুন্দর বাগান আছে।||We have a beautiful garden.
আমার ঘর পরিষ্কার।||My room is clean.
বইটি টেবিলের উপর আছে।||The book is on the table.
চাবিটি দরজার পাশে আছে।||The key is beside the door.
রান্নাঘরটি নিচে আছে।||The kitchen is downstairs.
আমরা বসার ঘরে বসি।||We sit in the living room.
আমার বিছানা জানালার পাশে।||My bed is beside the window.
আমি আমার বাড়িতে স্বাচ্ছন্দ্যবোধ করি।||I feel comfortable at home.
''',
        Icons.home_rounded,
        AppColors.purple,
      ),
      buildSentences: _makeList(
        'home_build',
        '''
আমার ঘরে একটি ডেস্ক আছে।||There is a desk in my room.
দেয়ালে একটি ছবি আছে।||There is a picture on the wall.
ফ্রিজটি রান্নাঘরে আছে।||The refrigerator is in the kitchen.
জুতাগুলো দরজার কাছে আছে।||The shoes are near the door.
আমি প্রতিদিন ঘর পরিষ্কার করি।||I clean the house every day.
আমরা রাতে বসার ঘরে থাকি।||We stay in the living room at night.
আমার বাড়ির সামনে একটি গাছ আছে।||There is a tree in front of my house.
বাথরুমটি হলওয়ের পাশে।||The bathroom is beside the hallway.
আমি আমার ঘরে পড়াশোনা করি।||I study in my room.
আমাদের বাড়িতে তিনটি কক্ষ আছে।||There are three rooms in our house.
''',
        Icons.chair_rounded,
        AppColors.purple,
      ),
      speakSentences: _makeList(
        'home_speak',
        '''
আপনার বাড়ি সম্পর্কে বলুন।||I live in a comfortable house.
আপনার ঘর সম্পর্কে বলুন।||My room is clean and bright.
আপনার ডেস্ক সম্পর্কে বলুন।||My desk is beside the window.
বাড়িতে কী আছে বলুন।||There is a garden in front of my house.
আপনি কোথায় পড়াশোনা করেন বলুন।||I study in my room.
''',
        Icons.house_rounded,
        AppColors.purple,
      ),
    ),
    BasicSentenceTopic(
      id: 'food_drinks',
      title: 'Food & Drinks',
      subtitle: 'খাবার ও পানীয়',
      icon: Icons.restaurant_rounded,
      color: AppColors.error,
      sentenceCount: 25,
      learnSentences: _makeList(
        'food_learn',
        '''
আমি ভাত পছন্দ করি।||I like rice.
আমি পানি পান করি।||I drink water.
সে চা পছন্দ করে।||She likes tea.
আমি প্রতিদিন ফল খাই।||I eat fruit every day.
এই খাবারটি সুস্বাদু।||This food is delicious.
আমি খুব ক্ষুধার্ত।||I am very hungry.
আমি এক কাপ কফি চাই।||I want a cup of coffee.
দয়া করে আমাকে মেনু দিন।||Please give me the menu.
আমি মুরগি খেতে চাই।||I want to eat chicken.
বিলটি নিয়ে আসুন।||Please bring the bill.
''',
        Icons.restaurant_rounded,
        AppColors.error,
      ),
      buildSentences: _makeList(
        'food_build',
        '''
আমি সকালের নাস্তায় ডিম খাই।||I eat eggs for breakfast.
সে দুপুরে মাছ খায়।||He eats fish at lunch.
আমি চিনি ছাড়া চা পান করি।||I drink tea without sugar.
এই খাবারটি খুব ঝাল।||This food is very spicy.
আমি একটি স্যান্ডউইচ অর্ডার করতে চাই।||I would like to order a sandwich.
আপনার প্রিয় খাবার কী?||What is your favourite food?
আমি ঠান্ডা পানি চাই।||I would like some cold water.
আমরা একসঙ্গে রাতের খাবার খাই।||We have dinner together.
সে রান্না করতে পছন্দ করে।||She likes cooking.
খাবারটি প্রস্তুত হয়ে গেছে।||The food is ready.
''',
        Icons.local_dining_rounded,
        AppColors.error,
      ),
      speakSentences: _makeList(
        'food_speak',
        '''
আপনার প্রিয় খাবার বলুন।||My favourite food is rice.
রেস্টুরেন্টে অর্ডার দিন।||I would like to order chicken.
একটি পানীয় চাইতে বলুন।||Please give me some water.
খাবারের স্বাদ বলুন।||The food is very delicious.
বিল চাইতে বলুন।||Please bring the bill.
''',
        Icons.fastfood_rounded,
        AppColors.error,
      ),
    ),
    BasicSentenceTopic(
      id: 'shopping',
      title: 'Shopping',
      subtitle: 'কেনাকাটা',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.purple,
      sentenceCount: 25,
      learnSentences: _makeList(
        'shopping_learn',
        '''
আমি বাজারে যাচ্ছি।||I am going to the market.
আমি একটি শার্ট কিনতে চাই।||I want to buy a shirt.
এটির দাম কত?||How much is this?
এটি খুব দামি।||This is very expensive.
আপনার কি অন্য রং আছে?||Do you have another colour?
আমি এটি পছন্দ করি।||I like this.
আমি এটি পরে দেখতে পারি?||Can I try this on?
দয়া করে আমাকে সাহায্য করুন।||Please help me.
আমি এটি কিনব।||I will buy this.
আমি কার্ড দিয়ে পেমেন্ট করব।||I will pay by card.
''',
        Icons.shopping_bag_rounded,
        AppColors.purple,
      ),
      buildSentences: _makeList(
        'shopping_build',
        '''
আমি এক জোড়া জুতা খুঁজছি।||I am looking for a pair of shoes.
এই পণ্যটির দাম কমান।||Please reduce the price of this product.
এটি আমার জন্য ছোট।||This is small for me.
এটি আমার জন্য বড়।||This is big for me.
আমার কালো রঙটি পছন্দ।||I prefer the black colour.
আপনার কাছে কি medium size আছে?||Do you have a medium size?
আমি নগদে টাকা দেব।||I will pay in cash.
আমার একটি ব্যাগ দরকার।||I need a bag.
দয়া করে রসিদটি দিন।||Please give me the receipt.
আমি পরে আবার আসব।||I will come again later.
''',
        Icons.storefront_rounded,
        AppColors.purple,
      ),
      speakSentences: _makeList(
        'shopping_speak',
        '''
দাম জিজ্ঞেস করুন।||How much does this cost?
একটি size চাইতে বলুন।||Do you have a larger size?
দাম কমাতে বলুন।||Can you give me a discount?
পণ্যটি পছন্দ হয়েছে বলুন।||I really like this product.
পেমেন্টের কথা বলুন।||I will pay by card.
''',
        Icons.sell_rounded,
        AppColors.purple,
      ),
    ),
    BasicSentenceTopic(
      id: 'school_study',
      title: 'School & Study',
      subtitle: 'পড়াশোনা',
      icon: Icons.school_rounded,
      color: AppColors.blue,
      sentenceCount: 25,
      learnSentences: _makeList(
        'school_learn',
        '''
আমি প্রতিদিন পড়াশোনা করি।||I study every day.
আমার আজ ক্লাস আছে।||I have a class today.
সে একজন ভালো ছাত্র।||He is a good student.
আমি ইংরেজি পড়ছি।||I am studying English.
আমার একটি বই দরকার।||I need a book.
আমি homework শেষ করেছি।||I have finished my homework.
পরীক্ষা আগামীকাল।||The exam is tomorrow.
আমার শিক্ষক খুব ভালো।||My teacher is very good.
আমি একটি প্রশ্ন করতে চাই।||I want to ask a question.
আমি পরীক্ষার জন্য প্রস্তুত।||I am ready for the exam.
''',
        Icons.school_rounded,
        AppColors.blue,
      ),
      buildSentences: _makeList(
        'school_build',
        '''
আমি লাইব্রেরিতে পড়াশোনা করি।||I study in the library.
আমরা একই ক্লাসে পড়ি।||We study in the same class.
সে আমাকে গণিতে সাহায্য করে।||She helps me with mathematics.
আমি নোট লিখছি।||I am writing notes.
আমার কলমটি কোথায়?||Where is my pen?
আজকের lesson খুব সহজ।||Today’s lesson is very easy.
আমি প্রতিদিন নতুন শব্দ শিখি।||I learn new words every day.
আমি কঠিন বিষয়গুলো অনুশীলন করি।||I practise difficult subjects.
আমরা একসঙ্গে project করি।||We do projects together.
আমি আমার ফলাফল নিয়ে খুশি।||I am happy with my result.
''',
        Icons.auto_stories_rounded,
        AppColors.blue,
      ),
      speakSentences: _makeList(
        'school_speak',
        '''
আপনার পড়াশোনা সম্পর্কে বলুন।||I study English every day.
পরীক্ষা সম্পর্কে বলুন।||My exam is tomorrow.
আপনার শিক্ষক সম্পর্কে বলুন।||My teacher is very helpful.
সহায়তা চাইতে বলুন।||Can you help me with this question?
আপনার লক্ষ্য বলুন।||I want to improve my English.
''',
        Icons.edit_note_rounded,
        AppColors.blue,
      ),
    ),
    BasicSentenceTopic(
      id: 'work_office',
      title: 'Work & Office',
      subtitle: 'কাজ ও অফিস',
      icon: Icons.work_rounded,
      color: AppColors.primary,
      sentenceCount: 25,
      learnSentences: _makeList(
        'work_learn',
        '''
আমি অফিসে কাজ করি।||I work in an office.
আমি একজন সফটওয়্যার ডেভেলপার।||I am a software developer.
আমার আজ একটি meeting আছে।||I have a meeting today.
আমি একটি project-এ কাজ করছি।||I am working on a project.
সে আমার সহকর্মী।||He is my colleague.
আমি সময়মতো অফিসে আসি।||I come to the office on time.
আমাদের team খুব ভালো।||Our team is very good.
আমি একটি email পাঠিয়েছি।||I have sent an email.
আমার একটু সাহায্য দরকার।||I need some help.
আজকের কাজ শেষ হয়েছে।||Today’s work is finished.
''',
        Icons.work_rounded,
        AppColors.primary,
      ),
      buildSentences: _makeList(
        'work_build',
        '''
আমি সকাল নয়টায় কাজ শুরু করি।||I start work at nine in the morning.
আমরা client-এর সঙ্গে কথা বলেছি।||We talked with the client.
আমি report তৈরি করছি।||I am preparing a report.
দয়া করে file-টি check করুন।||Please check the file.
আমাদের deadline আগামীকাল।||Our deadline is tomorrow.
আমি task-টি শেষ করেছি।||I have completed the task.
সে একটি নতুন idea দিয়েছে।||She has given a new idea.
আমরা সমস্যাটি সমাধান করেছি।||We have solved the problem.
আমি meeting-এর জন্য প্রস্তুত।||I am ready for the meeting.
আমি বাসা থেকে কাজ করি।||I work from home.
''',
        Icons.business_center_rounded,
        AppColors.primary,
      ),
      speakSentences: _makeList(
        'work_speak',
        '''
আপনার পেশা বলুন।||I am a software developer.
আপনার কাজ সম্পর্কে বলুন।||I work on mobile applications.
Meeting শুরু করতে বলুন।||Let us start the meeting.
সহকর্মীর কাছে সাহায্য চান।||Can you help me with this task?
কাজ শেষ হয়েছে বলুন।||I have finished my work.
''',
        Icons.co_present_rounded,
        AppColors.primary,
      ),
    ),
    BasicSentenceTopic(
      id: 'travel_transport',
      title: 'Travel & Transport',
      subtitle: 'ভ্রমণ ও যানবাহন',
      icon: Icons.directions_bus_rounded,
      color: AppColors.amber,
      sentenceCount: 25,
      learnSentences: _makeList(
        'travel_learn',
        '''
আমি ভ্রমণ করতে পছন্দ করি।||I like travelling.
আমি বাসে যাই।||I go by bus.
ট্রেনটি কখন ছাড়বে?||When will the train leave?
স্টেশনটি কোথায়?||Where is the station?
আমি একটি টিকিট চাই।||I want a ticket.
এই বাসটি ঢাকায় যায়।||This bus goes to Dhaka.
আমার একটি map দরকার।||I need a map.
ভ্রমণটি খুব আনন্দের ছিল।||The trip was enjoyable.
আমি হোটেলে থাকব।||I will stay at a hotel.
আমরা আগামীকাল রওনা হব।||We will leave tomorrow.
''',
        Icons.directions_bus_rounded,
        AppColors.amber,
      ),
      buildSentences: _makeList(
        'travel_build',
        '''
আমি বিমানবন্দরে যাচ্ছি।||I am going to the airport.
আমার flight সকাল দশটায়।||My flight is at ten in the morning.
দয়া করে রাস্তা দেখান।||Please show me the way.
এখান থেকে কত দূর?||How far is it from here?
আমি একটি taxi ডাকতে চাই।||I want to call a taxi.
এই seat-টি কি খালি?||Is this seat empty?
আমরা এক ঘণ্টা অপেক্ষা করেছি।||We waited for one hour.
আমার luggage কোথায়?||Where is my luggage?
হোটেলের booking করা আছে।||The hotel is booked.
আমি নিরাপদে পৌঁছেছি।||I have arrived safely.
''',
        Icons.flight_rounded,
        AppColors.amber,
      ),
      speakSentences: _makeList(
        'travel_speak',
        '''
গন্তব্য বলুন।||I am going to Cox’s Bazar.
টিকিট চাইতে বলুন।||I would like one ticket.
রাস্তা জিজ্ঞেস করুন।||How can I get to the station?
সময় জিজ্ঞেস করুন।||How long will the journey take?
Taxi চাইতে বলুন।||Please call a taxi.
''',
        Icons.luggage_rounded,
        AppColors.amber,
      ),
    ),
    BasicSentenceTopic(
      id: 'health_feelings',
      title: 'Health & Feelings',
      subtitle: 'স্বাস্থ্য ও অনুভূতি',
      icon: Icons.favorite_rounded,
      color: AppColors.error,
      sentenceCount: 25,
      learnSentences: _makeList(
        'health_learn',
        '''
আমি ভালো আছি।||I am fine.
আমার একটু অসুস্থ লাগছে।||I feel a little sick.
আমার মাথা ব্যথা করছে।||I have a headache.
আমার জ্বর হয়েছে।||I have a fever.
আমার বিশ্রাম দরকার।||I need some rest.
আমি খুব খুশি।||I am very happy.
সে দুঃখিত।||She is sad.
আমি ক্লান্ত।||I am tired.
আমি ভয় পাচ্ছি না।||I am not afraid.
আমি এখন ভালো বোধ করছি।||I feel better now.
''',
        Icons.favorite_rounded,
        AppColors.error,
      ),
      buildSentences: _makeList(
        'health_build',
        '''
আমার ডাক্তার দেখানো দরকার।||I need to see a doctor.
দয়া করে আমাকে পানি দিন।||Please give me some water.
আমি গতকাল থেকে অসুস্থ।||I have been sick since yesterday.
আমার পেটে ব্যথা করছে।||I have a stomachache.
আমার ওষুধ খেতে হবে।||I have to take medicine.
আমি প্রতিদিন exercise করি।||I exercise every day.
ঘুম স্বাস্থ্যের জন্য গুরুত্বপূর্ণ।||Sleep is important for health.
আমি এখন অনেক ভালো আছি।||I am much better now.
আমি আমার অনুভূতি প্রকাশ করি।||I express my feelings.
আমার সাহায্য দরকার।||I need help.
''',
        Icons.health_and_safety_rounded,
        AppColors.error,
      ),
      speakSentences: _makeList(
        'health_speak',
        '''
আপনার শরীরের অবস্থা বলুন।||I do not feel well.
ব্যথার কথা বলুন।||I have a headache.
ডাক্তারের কাছে সাহায্য চান।||I need to see a doctor.
আপনার অনুভূতি বলুন।||I feel very happy today.
বিশ্রামের কথা বলুন।||I need some rest.
''',
        Icons.healing_rounded,
        AppColors.error,
      ),
    ),
    BasicSentenceTopic(
      id: 'time_weather',
      title: 'Time & Weather',
      subtitle: 'সময় ও আবহাওয়া',
      icon: Icons.cloud_rounded,
      color: AppColors.blue,
      sentenceCount: 25,
      learnSentences: _makeList(
        'weather_learn',
        '''
এখন কয়টা বাজে?||What time is it now?
আজ সোমবার।||Today is Monday.
আজ খুব গরম।||It is very hot today.
বৃষ্টি হচ্ছে।||It is raining.
আকাশ মেঘলা।||The sky is cloudy.
আজ আবহাওয়া সুন্দর।||The weather is beautiful today.
আগামীকাল ঠান্ডা হবে।||It will be cold tomorrow.
আমি সকালে আসব।||I will come in the morning.
মিটিং পাঁচটায় হবে।||The meeting will be at five.
আমি রাতে পড়াশোনা করি।||I study at night.
''',
        Icons.cloud_rounded,
        AppColors.blue,
      ),
      buildSentences: _makeList(
        'weather_build',
        '''
আজ বাইরে যাওয়া কঠিন।||It is difficult to go outside today.
বৃষ্টি থেমে গেছে।||The rain has stopped.
দয়া করে ছাতা নিয়ে যান।||Please take an umbrella.
আজকের temperature বেশি।||Today’s temperature is high.
শীতকালে দিন ছোট হয়।||Days are shorter in winter.
আমি দুপুরে ব্যস্ত থাকব।||I will be busy in the afternoon.
তুমি কখন আসবে?||When will you come?
আমরা সন্ধ্যায় দেখা করব।||We will meet in the evening.
গতকাল আবহাওয়া ভালো ছিল।||The weather was good yesterday.
সময় খুব দ্রুত চলে যায়।||Time passes very quickly.
''',
        Icons.wb_cloudy_rounded,
        AppColors.blue,
      ),
      speakSentences: _makeList(
        'weather_speak',
        '''
সময় জিজ্ঞেস করুন।||What time is it now?
আজকের আবহাওয়া বলুন।||The weather is nice today.
বৃষ্টির কথা বলুন।||It is raining outside.
আগামীকালের পরিকল্পনা বলুন।||I will come tomorrow morning.
Meeting-এর সময় বলুন।||The meeting will be at five.
''',
        Icons.access_time_filled_rounded,
        AppColors.blue,
      ),
    ),
    BasicSentenceTopic(
      id: 'phone_conversation',
      title: 'Phone Conversation',
      subtitle: 'ফোনে কথা বলা',
      icon: Icons.phone_rounded,
      color: AppColors.purple,
      sentenceCount: 25,
      learnSentences: _makeList(
        'phone_learn',
        '''
হ্যালো, কেমন আছেন?||Hello, how are you?
আমি রাজের সঙ্গে কথা বলতে চাই।||I want to speak to Raj.
আপনি কি আমাকে শুনতে পাচ্ছেন?||Can you hear me?
আমি পরে ফোন করব।||I will call later.
দয়া করে অপেক্ষা করুন।||Please wait.
আপনি কোথায় আছেন?||Where are you?
আমি এখন ব্যস্ত।||I am busy now.
আপনি কি আমাকে message করতে পারেন?||Can you message me?
ফোন করার জন্য ধন্যবাদ।||Thank you for calling.
আবার কথা হবে।||Talk to you later.
''',
        Icons.phone_rounded,
        AppColors.purple,
      ),
      buildSentences: _makeList(
        'phone_build',
        '''
আমি আপনাকে পরে ফোন করব।||I will call you later.
দয়া করে আপনার নাম বলুন।||Please tell me your name.
লাইনটি খুব খারাপ।||The line is very bad.
আমি আপনাকে ঠিকমতো শুনতে পাচ্ছি না।||I cannot hear you clearly.
আপনি কি একটু জোরে কথা বলবেন?||Could you speak a little louder?
আমি এখন meeting-এ আছি।||I am in a meeting now.
দয়া করে আমাকে একটি message পাঠান।||Please send me a message.
আমি পাঁচ মিনিটের মধ্যে ফোন করব।||I will call in five minutes.
আপনার phone number দিন।||Please give me your phone number.
ঠিক আছে, পরে কথা হবে।||Okay, talk to you later.
''',
        Icons.call_rounded,
        AppColors.purple,
      ),
      speakSentences: _makeList(
        'phone_speak',
        '''
ফোনে greeting দিন।||Hello, how are you?
কারও সঙ্গে কথা বলতে চান বলুন।||I want to speak to you.
শুনতে না পাওয়ার কথা বলুন।||I cannot hear you clearly.
পরে ফোন করার কথা বলুন।||I will call you later.
ফোন শেষ করুন।||Thank you for calling.
''',
        Icons.phone_in_talk_rounded,
        AppColors.purple,
      ),
    ),


    ...BasicSentenceExtraTopics.completedItems,
  ];

}