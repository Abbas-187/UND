import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cycle_count_schedule.dart';
import '../../domain/repositories/cycle_count_schedule_repository.dart';

class CycleCountScheduleRepositoryImpl implements CycleCountScheduleRepository {
  CycleCountScheduleRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('cycle_count_schedules');

  @override
  Future<List<CycleCountSchedule>> getSchedules() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  @override
  Future<CycleCountSchedule?> getSchedule(String scheduleId) async {
    final doc = await _collection.doc(scheduleId).get();
    if (!doc.exists) return null;
    return _fromDoc(doc);
  }

  @override
  Future<CycleCountSchedule> createSchedule(CycleCountSchedule schedule) async {
    await _collection.doc(schedule.scheduleId).set(_toMap(schedule));
    return schedule;
  }

  @override
  Future<void> updateSchedule(CycleCountSchedule schedule) async {
    await _collection.doc(schedule.scheduleId).update(_toMap(schedule));
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    await _collection.doc(scheduleId).delete();
  }

  CycleCountSchedule _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CycleCountSchedule(
      scheduleId: doc.id,
      scheduleName: data['scheduleName'] as String,
      creationDate: (data['creationDate'] as Timestamp).toDate(),
      frequency: data['frequency'] as String,
      nextDueDate: (data['nextDueDate'] as Timestamp).toDate(),
      itemSelectionCriteria:
          Map<String, dynamic>.from(data['itemSelectionCriteria'] as Map),
      status: data['status'] as String,
      lastGeneratedSheetId: data['lastGeneratedSheetId'] as String?,
    );
  }

  Map<String, dynamic> _toMap(CycleCountSchedule schedule) {
    return {
      'scheduleName': schedule.scheduleName,
      'creationDate': schedule.creationDate,
      'frequency': schedule.frequency,
      'nextDueDate': schedule.nextDueDate,
      'itemSelectionCriteria': schedule.itemSelectionCriteria,
      'status': schedule.status,
      'lastGeneratedSheetId': schedule.lastGeneratedSheetId,
    };
  }
}
