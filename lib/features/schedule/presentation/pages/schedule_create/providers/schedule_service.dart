import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';

class ScheduleService {
  final Ref ref;

  ScheduleService(this.ref);

  void removeLevel(String name) {
    final levelsState = ref.read(levelsProvider);
    if (!levelsState.levels.containsKey(name)) return;

    final removeLevelId = levelsState.levelIds[name];
    if (removeLevelId == null) return;

    // Remove from subjects
    ref
        .read(subjectsProvider.notifier)
        .removeLevelReferences(name, removeLevelId);

    // Remove from teachers
    ref.read(teachersProvider.notifier).removeQualifiedLevel(removeLevelId);

    // Remove level core
    ref.read(levelsProvider.notifier).removeLevelCore(name, removeLevelId);
  }
}

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(ref);
});
