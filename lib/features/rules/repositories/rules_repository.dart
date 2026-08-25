
import '../data/batches/rules_batch_01.dart';
import '../models/rule_content.dart';

abstract final class RulesRepository {
  static const List<RuleContent> allRules = [
    ...Batch01Rules.rules,
  ];

  static RuleContent? findById(String id) {
    for (final rule in allRules) {
      if (rule.id == id) {
        return rule;
      }
    }

    return null;
  }

  static List<RuleContent> findByCategory(
      String category,
      ) {
    return allRules
        .where(
          (rule) => rule.category == category,
    )
        .toList();
  }

  static bool validateRuleContent(
      RuleContent rule,
      ) {
    return rule.examples.length == 15 &&
        rule.tests.length == 10 &&
        rule.speakingTests.length == 5;
  }

  static List<RuleContent> findIncompleteRules() {
    return allRules
        .where(
          (rule) => !validateRuleContent(rule),
    )
        .toList();
  }
}