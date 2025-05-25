import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reason_code_repository_impl.dart';
import '../../domain/repositories/reason_code_repository.dart';

final reasonCodeRepositoryProvider = Provider<ReasonCodeRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  return ReasonCodeRepositoryImpl(firestore);
});
