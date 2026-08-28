import 'package:englishtarget/features/basic_sentences/data/basic_sentences_data.dart';
import 'package:englishtarget/features/basic_sentences/services/basic_sentence_progress_service.dart';
import 'package:englishtarget/features/basic_sentences/services/basic_sentence_xp_service.dart';
import 'package:englishtarget/features/daily_challenge/data/daily_challenge_data.dart';
import 'package:englishtarget/features/daily_challenge/models/daily_challenge_item.dart';
import 'package:englishtarget/features/daily_challenge/services/daily_challenge_progress_service.dart';
import 'package:englishtarget/features/question_making/data/question_making_data.dart';
import 'package:englishtarget/features/question_making/services/question_making_progress_service.dart';
import 'package:englishtarget/features/rules/models/rule_content.dart';
import 'package:englishtarget/features/rules/models/rules_data.dart';
import 'package:englishtarget/features/rules/repositories/rules_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rules data validation', () {
    test('exactly 60 rules are registered', () {
      expect(RulesRepository.allRules.length, 60);

      expect(RulesData.rules.length, 60);
    });

    test('rule metadata and content IDs match', () {
      final Set<String> metadataIds = RulesData.rules
          .map((rule) => rule.id)
          .toSet();

      final Set<String> contentIds = RulesRepository.allRules
          .map((RuleContent rule) => rule.id)
          .toSet();

      expect(
        metadataIds.length,
        RulesData.rules.length,
        reason: 'Duplicate ID exists in RulesData.',
      );

      expect(
        contentIds.length,
        RulesRepository.allRules.length,
        reason: 'Duplicate ID exists in rule batches.',
      );

      expect(
        metadataIds.difference(contentIds),
        isEmpty,
        reason: 'Some RulesData IDs have no content.',
      );

      expect(
        contentIds.difference(metadataIds),
        isEmpty,
        reason: 'Some batch content IDs have no metadata.',
      );
    });

    test('every rule contains 15 examples, '
        '10 tests and 5 speaking tests', () {
      expect(RulesRepository.findIncompleteRules(), isEmpty);

      for (int index = 0; index < RulesRepository.allRules.length; index++) {
        final RuleContent rule = RulesRepository.allRules[index];

        expect(
          rule.order,
          index + 1,
          reason: '${rule.id} has an incorrect order.',
        );

        expect(
          rule.examples.length,
          15,
          reason: '${rule.id} must have 15 examples.',
        );

        expect(rule.tests.length, 10, reason: '${rule.id} must have 10 tests.');

        expect(
          rule.speakingTests.length,
          5,
          reason: '${rule.id} must have 5 speaking tests.',
        );
      }
    });

    test('all rule examples are valid', () {
      final Set<String> exampleKeys = <String>{};

      for (final RuleContent rule in RulesRepository.allRules) {
        for (int index = 0; index < rule.examples.length; index++) {
          final RuleExample example = rule.examples[index];

          expect(
            example.bengali.trim(),
            isNotEmpty,
            reason:
                '${rule.id} example '
                '${index + 1} has no Bengali text.',
          );

          expect(
            example.english.trim(),
            isNotEmpty,
            reason:
                '${rule.id} example '
                '${index + 1} has no English text.',
          );

          expect(
            example.visualKey.trim(),
            isNotEmpty,
            reason:
                '${rule.id} example '
                '${index + 1} has no visual key.',
          );

          expect(
            example.visualKey,
            isNot('default'),
            reason:
                '${rule.id} example '
                '${index + 1} is using '
                'the default visual.',
          );

          final String uniqueKey = '${rule.id}_${example.visualKey}_$index';

          expect(exampleKeys.add(uniqueKey), isTrue);
        }
      }
    });

    test('all rule tests are valid', () {
      final Set<String> globalTestIds = <String>{};

      for (final RuleContent rule in RulesRepository.allRules) {
        final Set<String> localIds = <String>{};

        for (final RuleTest testItem in rule.tests) {
          expect(
            testItem.id.trim(),
            isNotEmpty,
            reason: '${rule.id} contains an empty test ID.',
          );

          expect(
            localIds.add(testItem.id),
            isTrue,
            reason:
                '${rule.id} contains duplicate '
                'test ID ${testItem.id}.',
          );

          expect(
            globalTestIds.add(testItem.id),
            isTrue,
            reason:
                'Global duplicate test ID: '
                '${testItem.id}.',
          );

          expect(testItem.question.trim(), isNotEmpty);

          expect(testItem.correctAnswer.trim(), isNotEmpty);

          expect(testItem.explanation.trim(), isNotEmpty);

          if (testItem.options.isNotEmpty) {
            expect(
              testItem.options.contains(testItem.correctAnswer),
              isTrue,
              reason:
                  '${testItem.id} correct answer '
                  'is not present in options.',
            );

            expect(
              testItem.options.toSet().length,
              testItem.options.length,
              reason:
                  '${testItem.id} contains '
                  'duplicate options.',
            );
          }
        }
      }
    });

    test('all speaking tests are valid', () {
      final Set<String> speakingIds = <String>{};

      for (final RuleContent rule in RulesRepository.allRules) {
        for (final SpeakingTest speaking in rule.speakingTests) {
          expect(
            speakingIds.add(speaking.id),
            isTrue,
            reason:
                'Duplicate speaking ID: '
                '${speaking.id}.',
          );

          expect(speaking.instruction.trim(), isNotEmpty);

          expect(speaking.expectedAnswer.trim(), isNotEmpty);

          expect(
            speaking.acceptedAnswers,
            isNotEmpty,
            reason:
                '${speaking.id} must contain '
                'accepted answers.',
          );

          expect(
            speaking.acceptedAnswers.contains(speaking.expectedAnswer),
            isTrue,
            reason:
                '${speaking.id} expected answer '
                'must be accepted.',
          );
        }
      }
    });
  });

  group('Basic Sentences validation', () {
    test('contains exactly 30 topics', () {
      expect(BasicSentencesData.topics.length, 30);
    });

    test('every topic contains '
        '10 learn, 10 build and 5 speaking sentences', () {
      final Set<String> topicIds = <String>{};

      final Set<String> sentenceIds = <String>{};

      for (final topic in BasicSentencesData.topics) {
        expect(
          topicIds.add(topic.id),
          isTrue,
          reason:
              'Duplicate basic topic ID: '
              '${topic.id}.',
        );

        expect(topic.title.trim(), isNotEmpty);

        expect(topic.subtitle.trim(), isNotEmpty);

        expect(
          topic.sentenceCount,
          25,
          reason:
              '${topic.id} sentenceCount '
              'must be 25.',
        );

        expect(
          topic.learnSentences.length,
          10,
          reason:
              '${topic.id} must contain '
              '10 learn sentences.',
        );

        expect(
          topic.buildSentences.length,
          10,
          reason:
              '${topic.id} must contain '
              '10 build sentences.',
        );

        expect(
          topic.speakSentences.length,
          5,
          reason:
              '${topic.id} must contain '
              '5 speaking sentences.',
        );

        final allSentences = <dynamic>[
          ...topic.learnSentences,
          ...topic.buildSentences,
          ...topic.speakSentences,
        ];

        expect(allSentences.length, 25);

        for (final sentence in allSentences) {
          expect(
            sentenceIds.add(sentence.id as String),
            isTrue,
            reason:
                'Duplicate basic sentence ID: '
                '${sentence.id}.',
          );

          expect(sentence.bengali.toString().trim(), isNotEmpty);

          expect(sentence.english.toString().trim(), isNotEmpty);

          expect(sentence.visualKey.toString().trim(), isNotEmpty);

          expect(sentence.words, isNotEmpty);
        }
      }
    });
  });

  group('Question Making validation', () {
    test('contains exactly 30 topics', () {
      expect(QuestionMakingData.topics.length, 30);
    });

    test('every topic contains '
        '25 valid questions', () {
      final Set<String> topicIds = <String>{};

      final Set<String> questionIds = <String>{};

      for (final topic in QuestionMakingData.topics) {
        expect(
          topicIds.add(topic.id),
          isTrue,
          reason:
              'Duplicate question topic ID: '
              '${topic.id}.',
        );

        expect(
          topic.questions.length,
          25,
          reason:
              '${topic.id} must contain '
              '25 questions.',
        );

        for (final question in topic.questions) {
          expect(
            questionIds.add(question.id),
            isTrue,
            reason:
                'Duplicate question ID: '
                '${question.id}.',
          );

          expect(question.bengali.trim(), isNotEmpty);

          expect(question.english.trim(), isNotEmpty);

          expect(
            question.english.trim().endsWith('?'),
            isTrue,
            reason: '${question.id} must end with ?',
          );

          expect(question.explanation.trim(), isNotEmpty);

          expect(question.words, isNotEmpty);
        }
      }
    });
  });

  group('Daily Challenge validation', () {
    test('daily item bank contains 30 items', () {
      expect(DailyChallengeData.all.length, 30);
    });

    test('all daily item IDs are unique', () {
      final Set<String> ids = <String>{};

      for (final DailyChallengeItem item in DailyChallengeData.all) {
        expect(
          ids.add(item.id),
          isTrue,
          reason:
              'Duplicate daily item ID: '
              '${item.id}.',
        );

        expect(item.bengali.trim(), isNotEmpty);

        expect(item.english.trim(), isNotEmpty);

        expect(item.words, isNotEmpty);

        if (item.type == DailyChallengeItemType.rule) {
          expect(item.options, isNotEmpty);

          expect(
            item.options.contains(item.correctAnswer),
            isTrue,
            reason:
                '${item.id} correct answer '
                'is missing from options.',
          );

          expect(item.explanation.trim(), isNotEmpty);
        }

        if (item.type == DailyChallengeItemType.questionMaking) {
          expect(item.english.endsWith('?'), isTrue);
        }
      }
    });

    test('today challenge contains correct distribution', () {
      final List<DailyChallengeItem> items = DailyChallengeData.today();

      expect(items.length, 10);

      expect(
        items.map((DailyChallengeItem item) => item.id).toSet().length,
        10,
      );

      expect(
        items
            .where(
              (DailyChallengeItem item) =>
                  item.type == DailyChallengeItemType.rule,
            )
            .length,
        2,
      );

      expect(
        items
            .where(
              (DailyChallengeItem item) =>
                  item.type == DailyChallengeItemType.basicSentence,
            )
            .length,
        3,
      );

      expect(
        items
            .where(
              (DailyChallengeItem item) =>
                  item.type == DailyChallengeItemType.questionMaking,
            )
            .length,
        3,
      );

      expect(
        items
            .where(
              (DailyChallengeItem item) =>
                  item.type == DailyChallengeItemType.speaking,
            )
            .length,
        2,
      );
    });
  });

  group('XP and progress validation', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      BasicSentenceXpService.totalXp.value = 0;
    });

    test('same basic practice cannot award XP twice', () async {
      await BasicSentenceProgressService.markAttended(
        topicId: 'test_topic',
        activityId: 'activity_1',
      );

      await BasicSentenceProgressService.markAttended(
        topicId: 'test_topic',
        activityId: 'activity_1',
      );

      expect(await BasicSentenceXpService.load(), 1);
    });

    test('25 basic practices award '
        '25 XP plus 10 bonus XP', () async {
      for (int index = 1; index <= 25; index++) {
        await BasicSentenceProgressService.markAttended(
          topicId: 'complete_topic',
          activityId: 'activity_$index',
        );
      }

      expect(await BasicSentenceXpService.load(), 35);
    });

    test('same question practice '
        'cannot award XP twice', () async {
      final int firstAward = await QuestionMakingProgressService.markAttended(
        topicId: 'question_topic',
        activityId: 'question_1',
      );

      final int secondAward = await QuestionMakingProgressService.markAttended(
        topicId: 'question_topic',
        activityId: 'question_1',
      );

      expect(firstAward, 1);
      expect(secondAward, 0);

      expect(await BasicSentenceXpService.load(), 1);
    });

    test('daily challenge awards '
        '50 XP only once per day', () async {
      final List<DailyChallengeItem> items = DailyChallengeData.today();

      for (final DailyChallengeItem item in items) {
        await DailyChallengeProgressService.markAnswer(
          itemId: item.id,
          correct: true,
        );
      }

      final bool firstCompletion =
          await DailyChallengeProgressService.completeChallenge();

      final bool secondCompletion =
          await DailyChallengeProgressService.completeChallenge();

      final DailyChallengeState state =
          await DailyChallengeProgressService.getState();

      expect(firstCompletion, isTrue);
      expect(secondCompletion, isFalse);
      expect(state.isComplete, isTrue);
      expect(state.xpAwarded, isTrue);
      expect(state.streak, 1);

      expect(await BasicSentenceXpService.load(), 50);
    });
  });
}
