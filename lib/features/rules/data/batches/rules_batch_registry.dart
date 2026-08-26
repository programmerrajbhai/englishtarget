import 'package:englishtarget/features/rules/data/batches/rules_batch_04.dart';

import '../../models/rule_content.dart';
import 'rules_batch_01.dart';
import 'rules_batch_02.dart';
import 'rules_batch_03.dart';

abstract final class RulesBatchRegistry {
  static final List<RuleContent> all = <RuleContent>[
    ...Batch01Rules.rules,
    ...Batch02Rules.rules,
    ...Batch03Rules.rules,
    ...Batch04Rules.rules,
  ];
}