import '../data/batches/rules_batch_registry.dart';
import '../models/rule_content.dart';

abstract final class RulesRepository {
  static final List<RuleContent> allRules =
  List<RuleContent>.unmodifiable(
    RulesBatchRegistry.all,
  );

  static RuleContent? findById(String id) {
    for (final RuleContent rule in allRules) {
      if (rule.id == id) {
        return rule;
      }
    }

    return null;
  }

  static List<RuleContent> findByCategory(String category) {
    return allRules
        .where((RuleContent rule) => rule.category == category)
        .toList(growable: false);
  }

  static bool validateRuleContent(RuleContent rule) {
    return rule.examples.length == 15 &&
        rule.tests.length == 10 &&
        rule.speakingTests.length == 5;
  }

  static List<RuleContent> findIncompleteRules() {
    return allRules
        .where((RuleContent rule) => !validateRuleContent(rule))
        .toList(growable: false);
  }

  static bool hasContent(String id) {
    return allRules.any((RuleContent rule) => rule.id == id);
  }
}