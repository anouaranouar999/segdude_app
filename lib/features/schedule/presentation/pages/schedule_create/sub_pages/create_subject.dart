import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/widgets/add_dialogs.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/widgets/custom_container.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/responsive_width_guard.dart';

// ── UI constants ──────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// FIX: was ConsumerWidget — TextEditingControllers (subjectNameContr, weeklyHours)
//      and GlobalKey/Set were fields on ConsumerWidget which has no dispose(),
//      causing them to remain in memory indefinitely.
//      Converted to ConsumerStatefulWidget so State.dispose() is called
//      when the widget leaves the tree.
// ─────────────────────────────────────────────────────────────────────────────
class CreateSubject extends ConsumerStatefulWidget {
  const CreateSubject({super.key});

  @override
  ConsumerState<CreateSubject> createState() => _CreateSubjectState();
}

class _CreateSubjectState extends ConsumerState<CreateSubject> {
  // ── Moved from ConsumerWidget fields → State so dispose() is called ────────
  final _formKey = GlobalKey<FormState>();
  final subjectNameContr = TextEditingController();
  final TextEditingController weeklyHours = TextEditingController();
  final Set<int> selectedIndices = {};
  final prefs = SharedPreferencesService();

  // Computed once per widget lifetime instead of on every rebuild
  late final Color randomColor = Colors
      .primaries[Random().nextInt(Colors.primaries.length)]
      .withAlpha(20);

  @override
  void dispose() {
    // Controllers are now properly released when the widget leaves the tree
    subjectNameContr.dispose();
    weeklyHours.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  // Below this width the levels column + subjects table (two fixed-width
  // 150px SpinBoxes per row, see `build` below) starts producing RenderFlex
  // overflows, so the page isn't built at all.
  static const double _kMinPageWidth = 800;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidthGuard(minWidth: _kMinPageWidth, builder: _buildPage);
  }

  Widget _buildPage(BuildContext context) {
    const pageBg = Color(0xFFF4F7FB);
    const blue = Color(0xFF2A6FDB);
    const divider = Color(0xFFDDE3EC);
    final l10n = AppLocalizations.of(context)!;
    final List<String> levelsList = ref.watch(
      levelsProvider.select((s) => s.levels.keys.map((e) => e).toList()),
    );
    final selectedLevel = ref.watch(
      levelsProvider.select((s) => s.selectedLevel),
    );
    final subjects = ref.watch(subjectsProvider.select((s) => s.subjects));
    final levelIds = ref.watch(levelsProvider.select((s) => s.levelIds));
    final consecutiveHours = ref.watch(
      subjectsProvider.select((s) => s.consecutiveHours),
    );

    final TextStyle titlesTxtStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF2A4A7F),
      letterSpacing: 0.2,
    );

    return Form(
      key: _formKey,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyA, control: true): () =>
              addSubjectDialog(context, ref),
          const SingleActivator(LogicalKeyboardKey.keyA, meta: true): () =>
              addSubjectDialog(context, ref),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.createSubject)),
            backgroundColor: pageBg,
            floatingActionButtonLocation: subjects.isEmpty
                ? FloatingActionButtonLocation.centerFloat
                : FloatingActionButtonLocation.endFloat,
            body: Row(
              children: [
                // ── Column 1 — Levels list ─────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        color: const Color(0xFFEEF3FB),
                        width: double.infinity,
                        alignment: .center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(l10n.levels, style: titlesTxtStyle),
                      ),
                      const Divider(height: 1, color: divider),
                      // Level tiles — customContainer preserved exactly
                      ...levelsList.map(
                        (level) => customContainer(
                          randomColor,
                          level != selectedLevel,
                          child: Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              title: Text(
                                level,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: level == selectedLevel
                                      ? blue
                                      : const Color(0xFF1A2E4A),
                                ),
                              ),
                              subtitle: Text(
                                level == selectedLevel
                                    ? l10n.levelSelected
                                    : l10n.levelTapToSelect,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: level == selectedLevel
                                      ? blue
                                      : const Color(0xFF8A9BB5),
                                ),
                              ),
                              onTap: () {
                                ref
                                    .read(levelsProvider.notifier)
                                    .setSelectedLevel(level);
                              },
                              trailing: level == selectedLevel
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.green,
                                      size: 28,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Divider ────────────────────────────────────────────
                const VerticalDivider(width: 1, thickness: 1),

                // ── Column 2 — Subjects table ──────────────────────────
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 41,
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(l10n.subjects, style: titlesTxtStyle),
                            ),
                            Row(
                              mainAxisAlignment: .spaceAround,
                              children: [
                                Container(
                                  alignment: .center,
                                  // color: Colors.amber,
                                  width: 165,
                                  child: Text(
                                    l10n.weeklyHours,
                                    style: titlesTxtStyle,
                                  ),
                                ),

                                Container(
                                  alignment: .center,
                                  width: 147,
                                  // color: Colors.green,
                                  child: Text(
                                    l10n.consecutive,
                                    style: titlesTxtStyle,
                                  ),
                                ),
                                SizedBox(width: 13),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: divider),

                      // if subjects list is empty
                      subjects.isEmpty
                          ? Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 60,
                                      color: Color(0xFF8A9BB5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      l10n.createSubjectEmptyHint,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF5A6A85),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : //-------------------------------------------------- List of subjects
                            Expanded(
                              child: ListView(
                                children: subjects.map<Widget>((e) {
                                  final bool isLevelValid =
                                      selectedLevel != 'None' &&
                                      levelsList.contains(selectedLevel);
                                  final int levelKey = isLevelValid
                                      ? levelIds[selectedLevel]!
                                      : 0;

                                  return Container(
                                    margin: const EdgeInsets.only(
                                      top: 2,
                                      bottom: 2,
                                      left: 5,
                                      right: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: divider),
                                      borderRadius: BorderRadius.circular(5),
                                      //---------------------------------show subject with selected color from dialog
                                      color: Color(
                                        e.color ?? 0xFFFFFFFF,
                                      ).withAlpha(50),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // Subject name + delete
                                        //--------------------------------
                                        // show no rooms icon if no rooms assigned to subject
                                        if (!e.requiresRoom)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.no_meeting_room,
                                              size: 20,
                                              color: blue,
                                            ),
                                          ),

                                        // add icon for subject
                                        Expanded(
                                          child: Material(
                                            type: MaterialType.transparency,
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              onTap: () {
                                                debugPrint(
                                                  'Subject tapped: ${e.toJson()}',
                                                );
                                              },
                                              title: Text(
                                                '${e.subjectName}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Color(0xFF1A2E4A),
                                                ),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () =>
                                                        addSubjectDialog(
                                                          context,
                                                          ref,
                                                          existing: e,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                      color: blue,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: Text(
                                                            l10n.warning,
                                                          ),
                                                          content: Text(
                                                            l10n.deleteSubjectWarning,
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: Text(
                                                                l10n.cancel,
                                                              ),
                                                            ),
                                                            TextButton(
                                                              //  delete subjcet and related teachers and groups
                                                              // remove subject from rooms and groups, then reindex subject IDs for groups
                                                              // reindex subjectids for groups
                                                              onPressed: () {
                                                                ref
                                                                    .read(
                                                                      roomsProvider
                                                                          .notifier,
                                                                    )
                                                                    .removeSubjectFromRooms(
                                                                      e.subjectId,
                                                                    );
                                                                ref
                                                                    .read(
                                                                      groupsProvider
                                                                          .notifier,
                                                                    )
                                                                    .removeGroupsOfSubject(
                                                                      e.subjectId,
                                                                    );
                                                                ref
                                                                    .read(
                                                                      groupsProvider
                                                                          .notifier,
                                                                    )
                                                                    .reindexSubjectIds(
                                                                      e.subjectId,
                                                                    );
                                                                ref
                                                                    .read(
                                                                      subjectsProvider
                                                                          .notifier,
                                                                    )
                                                                    .removeSubject(
                                                                      e.subjectId,
                                                                    );
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              },
                                                              child: Text(
                                                                l10n.continueBtn,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Color(0xFFD94040),
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // -------------------------------------------- SpinBox Weekly Hours
                                        SizedBox(
                                          width: 150,
                                          child: SpinBox(
                                            key: ValueKey(
                                              'weekly_${e.subjectId}_$levelKey',
                                            ),
                                            min: 0,
                                            max: 99,
                                            enabled: isLevelValid,
                                            value: isLevelValid
                                                ? double.parse(
                                                    '${e.weeklyHours?['$levelKey'] ?? 0} ',
                                                  )
                                                : 0.0,
                                            onSubmitted: (value) {
                                              if (!isLevelValid) return;
                                              ref
                                                  .read(
                                                    subjectsProvider.notifier,
                                                  )
                                                  .editSubject(
                                                    e.subjectId,
                                                    weeklyHours: {
                                                      '$levelKey': value
                                                          .toInt(),
                                                    },
                                                  );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        // -------------------------------------------- SpinBox Consecutive Hours
                                        SizedBox(
                                          width: 150,
                                          child: SpinBox(
                                            key: ValueKey(
                                              'consec_${e.subjectId}_$levelKey',
                                            ),
                                            min: 0,
                                            max: 99,
                                            enabled: isLevelValid,
                                            value: () {
                                              if (!isLevelValid) return 0.0;

                                              // Prefer a specific rule for this subject+level
                                              final perLevel = consecutiveHours
                                                  .where(
                                                    (ch) =>
                                                        ch.subjectId ==
                                                            e.subjectId &&
                                                        (ch.levelIds?.contains(
                                                              levelKey,
                                                            ) ??
                                                            false),
                                                  );
                                              if (perLevel.isNotEmpty) {
                                                return (perLevel
                                                            .first
                                                            .consecutiveHours ??
                                                        0)
                                                    .toDouble();
                                              }

                                              // Fallback: global/default rule for the subject (levelIds==null or contains 0)
                                              final globalRule =
                                                  consecutiveHours.where(
                                                    (ch) =>
                                                        ch.subjectId ==
                                                            e.subjectId &&
                                                        (ch.levelIds == null ||
                                                            (ch.levelIds
                                                                    ?.contains(
                                                                      0,
                                                                    ) ??
                                                                false)),
                                                  );
                                              if (globalRule.isNotEmpty) {
                                                return (globalRule
                                                            .first
                                                            .consecutiveHours ??
                                                        0)
                                                    .toDouble();
                                              }

                                              return 0.0;
                                            }(),
                                            onSubmitted: (value) {
                                              if (!isLevelValid) return;
                                              ref
                                                  .read(
                                                    subjectsProvider.notifier,
                                                  )
                                                  .editConsecutiveHours(
                                                    e.subjectId,
                                                    value.toInt(),
                                                    levelKey,
                                                  );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),

            // FAB — AnimatedSwitcher preserved exactly
            floatingActionButton: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: subjects.isEmpty
                  ? ElevatedButton.icon(
                      key: const ValueKey('add_btn_empty'),
                      onPressed: () => addSubjectDialog(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 26),
                      label: Text(l10n.addSubject),
                    )
                  : FloatingActionButton(
                      key: const ValueKey('add_btn_fab'),
                      onPressed: () => addSubjectDialog(context, ref),
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      hoverColor: Colors.blue.withValues(alpha: 0.75),
                      tooltip: l10n.addSubjectTooltip,
                      child: const Icon(Icons.add, size: 36),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
