import 'package:englishtarget/features/rules/data/batches/rules_batch_04.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_05.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_06.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_07.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_08.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_09.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_10.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_11.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_12.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_13.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_14.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_15.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_16.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_17.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_18.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_19.dart';
import 'package:englishtarget/features/rules/data/batches/rules_batch_20.dart';

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
    ...Batch05Rules.rules,
    ...Batch06Rules.rules,
    ...Batch07Rules.rules,
    ...Batch08Rules.rules,
    ...Batch09Rules.rules,
    ...Batch10Rules.rules,
    ...Batch11Rules.rules,
    ...Batch12Rules.rules,
    ...Batch13Rules.rules,
    ...Batch14Rules.rules,
    ...Batch15Rules.rules,
    ...Batch16Rules.rules,
    ...Batch17Rules.rules,
    ...Batch18Rules.rules,
    ...Batch19Rules.rules,
    ...Batch20Rules.rules,
  ];
}