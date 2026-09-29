import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

// ── Shared UI helpers ─────────────────────────────────────────────────────────
const _blue = Color(0xFF2A6FDB);

InputDecoration _fieldDecor(
  String label, {
  String? hint,
  String? error,
  String? helper,
}) => InputDecoration(
  labelText: label,
  hintText: hint,
  errorText: error,
  helperText: error == null ? helper : null,
  border: const OutlineInputBorder(),
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
);

Widget _cancelBtn(BuildContext context) => TextButton(
  onPressed: () => Navigator.pop(context),
  child: Text(
    AppLocalizations.of(context)!.cancel,
    style: const TextStyle(color: Color(0xFF5A6A85)),
  ),
);

Widget _confirmBtn(BuildContext context, String label, VoidCallback onTap) =>
    FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: _blue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(label),
    );

// ─────────────────────────────────────────────────────────────────────────────
// Add Level
// ─────────────────────────────────────────────────────────────────────────────

void addLevelDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => _AddLevelDialog(ref: ref),
  );
}

class _AddLevelDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddLevelDialog({required this.ref});

  @override
  State<_AddLevelDialog> createState() => _AddLevelDialogState();
}

class _AddLevelDialogState extends State<_AddLevelDialog> {
  final nameController = TextEditingController();
  final classesContr = TextEditingController();
  String? nameError;
  String? classesError;

  @override
  void dispose() {
    nameController.dispose();
    classesContr.dispose();
    super.dispose();
  }

  bool _validate() {
    nameError = classesError = null;
    final name = nameController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (name.isEmpty) {
      nameError = l10n.validationLevelNameRequired;
    } else if (name.length < 2) {
      nameError = l10n.validationNameMinTwoChars;
    } else if (widget.ref.read(levelsProvider).levels.containsKey(name)) {
      nameError = l10n.validationLevelAlreadyExists;
    }
    final cls = classesContr.text.trim();
    if (cls.isEmpty) {
      classesError = l10n.validationClassesRequired;
    } else if ((int.tryParse(cls) ?? 0) < 1) {
      classesError = l10n.validationMustBeNumberGteOne;
    }
    setState(() {});
    return nameError == null && classesError == null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      title: Text(
        l10n.addLevel,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2E4A),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              onChanged: (_) => setState(() => nameError = null),
              decoration: _fieldDecor(
                l10n.labelLevelName,
                hint: l10n.hintLevelName,
                error: nameError,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: classesContr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => classesError = null),
              decoration: _fieldDecor(
                l10n.labelNumberOfClasses,
                hint: l10n.hintNumberOfClasses,
                error: classesError,
              ),
            ),
          ],
        ),
      ),
      actions: [
        _cancelBtn(context),
        _confirmBtn(context, l10n.addLevel, () {
          if (!_validate()) return;
          widget.ref
              .read(levelsProvider.notifier)
              .addLevel(
                nameController.text.trim(),
                int.parse(classesContr.text),
              );
          Navigator.pop(context);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Subject
// ─────────────────────────────────────────────────────────────────────────────

void addSubjectDialog(
  BuildContext context,
  WidgetRef ref, {
  SubjectEncoder? existing,
}) {
  showDialog(
    context: context,
    builder: (_) => _AddSubjectDialog(ref: ref, existing: existing),
  );
}

class _AddSubjectDialog extends StatefulWidget {
  final WidgetRef ref;
  final SubjectEncoder? existing;
  const _AddSubjectDialog({required this.ref, this.existing});

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final nameController = TextEditingController();
  final minRestHoursController = TextEditingController();
  final avoidHoursController = TextEditingController();
  String? nameError;
  String? minRestHoursError;
  String? avoidHoursError;
  // null = no color chosen yet (first swatch auto-selected below)
  int? _selectedColor;
  bool? _requiresRoom;

  bool get _isEditMode => widget.existing != null;

  /// Curated palette – 20 visually distinct, schedule-friendly colors.
  static const List<Color> _palette = [
    Colors.white, // transparent one
    Color(0xFF4A90D9), // sky blue
    Color(0xFF27AE60), // emerald
    Color(0xFFE67E22), // tangerine
    Color(0xFFFFD700), //yellow,
    Color(0xFF8E44AD), // violet
    Color(0xFFE74C3C), // rose red
    Color(0xFF16A085), // teal
    Color(0xFFF39C12), // amber
    Color(0xFF2980B9), // cobalt
    Color(0xFF1ABC9C), // mint
    Color(0xFFD35400), // burnt orange
    Color(0xFF9B59B6), // lavender
    Color(0xFF2ECC71), // green
    Color(0xFFC0392B), // crimson
    Color(0xFF3498DB), // cornflower
    Color(0xFFE91E63), // pink
    Color(0xFF00BCD4), // cyan
    Color(0xFFFF9800), // deep amber
    Color(0xFF5C6BC0), // indigo
    Color(0xFF26A69A), // teal green
    Color(0xFFEC407A), // rose
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      nameController.text = existing.subjectName ?? '';
      _selectedColor = existing.color;
      _requiresRoom = existing.requiresRoom;
      minRestHoursController.text = existing.minRestHours != null
          ? (existing.minRestHours! - 24).toString()
          : '';
      avoidHoursController.text = existing.avoidHours?.join(',') ?? '';
    } else {
      // null = no color chosen yet (first swatch auto-selected below)
      _selectedColor = null;
      _requiresRoom = null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    minRestHoursController.dispose();
    avoidHoursController.dispose();
    super.dispose();
  }

  /// Validate the subject name, min rest hours, and avoid hours.
  bool _validate() {
    nameError = null;
    minRestHoursError = null;
    avoidHoursError = null;
    final name = nameController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (name.isEmpty) {
      nameError = l10n.validationSubjectNameRequired;
    } else if (name.length < 2) {
      nameError = l10n.validationNameMinTwoChars;
    } else if (widget.ref
        .read(subjectsProvider)
        .subjects
        .any(
          (e) =>
              e.subjectName == name &&
              e.subjectId != widget.existing?.subjectId,
        )) {
      nameError = l10n.validationSubjectAlreadyExists;
    }
    final minRestHoursText = minRestHoursController.text.trim();
    if (minRestHoursText.isNotEmpty &&
        (int.tryParse(minRestHoursText) == null ||
            int.parse(minRestHoursText) < 0)) {
      minRestHoursError = l10n.validationNonNegativeNumber;
    }
    final avoidHoursText = avoidHoursController.text.trim();
    if (avoidHoursText.isNotEmpty &&
        avoidHoursText
            .split(',')
            .any((hour) => int.tryParse(hour.trim()) == null)) {
      avoidHoursError = l10n.validationCommaSeparatedNumbers;
    }
    setState(() {});
    return nameError == null &&
        minRestHoursError == null &&
        avoidHoursError == null;
  }

  // void _addSubject() {
  //   if (!_validate()) return;
  //   final avoidHoursText = avoidHoursController.text.trim();
  //   widget.ref
  //       .read(subjectsProvider.notifier)
  //       .addSubject(
  //         nameController.text.trim(),
  //         {},
  //         color: _selectedColor,
  //         requiresRoom: _requiresRoom ?? true,
  //         minRestHours: int.tryParse(minRestHoursController.text.trim()),
  //         avoidHours: avoidHoursText.isEmpty
  //             ? null
  //             : avoidHoursText
  //                   .split(',')
  //                   .map((hour) => int.parse(hour.trim()))
  //                   .toList(),
  //       );
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      title: Text(
        _isEditMode ? l10n.editSubject : l10n.createSubject,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2E4A),
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              autofocus: true,
              onChanged: (_) => setState(() => nameError = null),
              onFieldSubmitted: (_) {
                if (!_validate()) return;
                _submit();
                Navigator.pop(context);
              },
              decoration: _fieldDecor(
                AppLocalizations.of(context)!.subject,
                hint: l10n.hintSubjectName,
                error: nameError,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.subjectColor,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A6A85),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            // ── Color grid ──────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _palette.map((color) {
                final isSelected = _selectedColor == color.toARGB32();
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color.toARGB32());
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Color(0xFF1A2E4A), width: 3)
                          : Border.all(color: Colors.transparent, width: 2),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.advancedParameters),
              children: [
                TextFormField(
                  controller: minRestHoursController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => minRestHoursError = null),
                  decoration: _fieldDecor(
                    l10n.minimumRestHours,
                    hint: l10n.optional,
                    error: minRestHoursError,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: avoidHoursController,
                  keyboardType: TextInputType.text,
                  onChanged: (_) => setState(() => avoidHoursError = null),
                  decoration: _fieldDecor(
                    l10n.avoidHours,
                    hint: l10n.avoidHoursHint,
                    error: avoidHoursError,
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${l10n.subjRequireRooms} ?'),
                  value: _requiresRoom ?? true,
                  onChanged: (value) {
                    setState(() {
                      _requiresRoom = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        _cancelBtn(context),
        _confirmBtn(context, _isEditMode ? l10n.save : l10n.addSubject, () {
          if (!_validate()) return;
          _submit();
          Navigator.pop(context);
        }),
      ],
    );
  }

  void _submit() {
    final name = nameController.text.trim();
    final minRestHours = int.tryParse(minRestHoursController.text.trim());
    final avoidHours = avoidHoursController.text.isEmpty
        ? null
        : avoidHoursController.text
              .split(',')
              .map((hour) => int.parse(hour.trim()))
              .toList();
    final existing = widget.existing;
    if (existing == null) {
      widget.ref
          .read(subjectsProvider.notifier)
          .addSubject(
            name,
            {},
            color: _selectedColor,
            requiresRoom: _requiresRoom ?? true,
            minRestHours: minRestHours != null ? minRestHours + 24 : null,
            avoidHours: avoidHours?.map((hour) => hour - 1).toList(),
          );
    } else {
      widget.ref
          .read(subjectsProvider.notifier)
          .editSubject(
            existing.subjectId,
            name: name,
            color: _selectedColor,
            requiresRoom: _requiresRoom ?? true,
            minRestHours: minRestHours != null ? minRestHours + 24 : null,
            avoidHours: avoidHours,
          );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Room
// ─────────────────────────────────────────────────────────────────────────────

void addRoomDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => _AddRoomDialog(ref: ref),
  );
}

class _AddRoomDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddRoomDialog({required this.ref});

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  final nameController = TextEditingController();
  String? nameError;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  bool _validate() {
    nameError = null;
    final name = nameController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (name.isEmpty) {
      nameError = l10n.validationRoomNameRequired;
    } else if (name.length < 2) {
      nameError = l10n.validationNameMinTwoChars;
    } else if (widget.ref
        .read(roomsProvider)
        .rooms
        .any((e) => e.roomName == name)) {
      nameError = l10n.validationRoomNameAlreadyExists;
    }
    setState(() {});
    return nameError == null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      title: Text(
        l10n.addRoom,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2E4A),
        ),
      ),
      content: TextFormField(
        controller: nameController,
        autofocus: true,
        onChanged: (_) => setState(() => nameError = null),
        decoration: _fieldDecor(
          AppLocalizations.of(context)!.cardRoomName,
          hint: l10n.hintRoomName,
          error: nameError,
        ),
      ),
      actions: [
        _cancelBtn(context),
        _confirmBtn(context, AppLocalizations.of(context)!.addRoom, () {
          if (!_validate()) return;
          widget.ref
              .read(roomsProvider.notifier)
              .addRoom(nameController.text.trim(), 0, [], [], {});
          Navigator.pop(context);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generate Rooms
// ─────────────────────────────────────────────────────────────────────────────

void generateRoomsDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => _GenerateRoomsDialog(ref: ref),
  );
}

class _GenerateRoomsDialog extends StatefulWidget {
  final WidgetRef ref;
  const _GenerateRoomsDialog({required this.ref});

  @override
  State<_GenerateRoomsDialog> createState() => _GenerateRoomsDialogState();
}

class _GenerateRoomsDialogState extends State<_GenerateRoomsDialog> {
  final generateNum = TextEditingController();
  final namePattern = TextEditingController();
  String? numError;

  @override
  void dispose() {
    generateNum.dispose();
    namePattern.dispose();
    super.dispose();
  }

  bool _validate() {
    numError = null;
    final n = generateNum.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (n.isEmpty) {
      numError = l10n.validationNumberOfRoomsRequired;
    } else if ((int.tryParse(n) ?? 0) < 1) {
      numError = l10n.validationMustBeNumberGteOne;
    }
    setState(() {});
    return numError == null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      title: Text(
        l10n.generateRooms,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2E4A),
        ),
      ),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: generateNum,
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() => numError = null),
              decoration: _fieldDecor(
                l10n.numberOfRooms,
                hint: l10n.numberOfRoomsHint,
                error: numError,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: namePattern,
              decoration: _fieldDecor(
                l10n.namePatternLabel,
                hint: l10n.namePatternHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        _cancelBtn(context),
        _confirmBtn(context, l10n.generate, () {
          if (!_validate()) return;
          widget.ref
              .read(roomsProvider.notifier)
              .generateRooms(
                int.parse(generateNum.text),
                namePattern.text.trim().isNotEmpty
                    ? namePattern.text
                    : 'Room #',
              );
          Navigator.pop(context);
        }),
      ],
    );
  }

  /// Update Minutes dialog
}

//===================================================================================
// Update Minutes dialog
//===================================================================================
void updateMinuteDialog(BuildContext context, WidgetRef ref, int index) {
  showDialog(
    context: context,
    builder: (_) => _UpdateMinuteDialog(ref: ref, index: index),
  );
}

class _UpdateMinuteDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _UpdateMinuteDialog({required this.ref, required this.index});
  final int index;
  @override
  ConsumerState<_UpdateMinuteDialog> createState() =>
      _UpdateMinuteDialogState();
}

class _UpdateMinuteDialogState extends ConsumerState<_UpdateMinuteDialog> {
  // Start and end minutes are now edited independently, since a header
  // represents a time range (e.g. 09:00–10:00) rather than a single time.
  final startMinutesController = TextEditingController();
  final endMinutesController = TextEditingController();
  @override
  void dispose() {
    startMinutesController.dispose();
    endMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      title: Text(
        l10n.titleUpdateMinutes,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2E4A),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startMinutesController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _fieldDecor(l10n.startHourLabel),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: endMinutesController,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _fieldDecor(l10n.endHourLabel),
            ),
          ],
        ),
      ),
      actions: [
        _cancelBtn(context),
        _confirmBtn(context, l10n.btnUpdate, () {
          final startMinutes = int.tryParse(startMinutesController.text);
          final endMinutes = int.tryParse(endMinutesController.text);
          final isValid =
              startMinutes != null &&
              startMinutes >= 0 &&
              startMinutes <= 59 &&
              endMinutes != null &&
              endMinutes >= 0 &&
              endMinutes <= 59;
          if (!isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.minutesMustBeBetween1And59,
                ),
                backgroundColor: Color(0xFFE6A23C),
              ),
            );
            return;
          }

          final notifier = widget.ref.read(settingsProvider.notifier);
          notifier.updateMinute(widget.index, startMinutes);
          notifier.updateEndMinute(widget.index, endMinutes);
          Navigator.pop(context);
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Number Of Groups
// ─────────────────────────────────────────────────────────────────────────────
void addGroupsDialog(
  BuildContext context,
  WidgetRef ref,
  List<SubjectEncoder> subjects,
  String className,
  int classId,
  List<int>? classIds,
) {
  showDialog(
    context: context,
    builder: (_) => _NumberOfGroupsDialog(
      ref: ref,
      subjects: subjects,
      className: className,
      classId: classId,
      classIds: classIds,
    ),
  );
}

class _NumberOfGroupsDialog extends StatefulWidget {
  const _NumberOfGroupsDialog({
    required this.ref,
    required this.subjects,
    required this.className,
    required this.classId,
    required this.classIds,
  });
  final WidgetRef ref;
  final List<SubjectEncoder> subjects;
  final String className;
  final int classId;

  final List<int>? classIds;
  @override
  State<_NumberOfGroupsDialog> createState() => _NumberOfGroupsDialogState();
}

class _NumberOfGroupsDialogState extends State<_NumberOfGroupsDialog> {
  final groupsController = TextEditingController();
  String? groupsError;
  int? selectedSubjectIndex;
  int? spinValue;
  bool applyToOthers = false;
  @override
  void dispose() {
    groupsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      title: Text(
        "${l10n.subject} : ${widget.subjects[selectedSubjectIndex ?? 0].subjectName}",
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A2E4A),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownMenu(
              onSelected: (value) {
                selectedSubjectIndex = (value ?? 0);
              },
              dropdownMenuEntries: List.generate(widget.subjects.length, (
                index,
              ) {
                return DropdownMenuEntry(
                  value: index,
                  label: widget.subjects[index].subjectName ?? "Unknown",
                );
              }),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 200,
              child: SpinBox(
                max: 10,
                min: 2,
                value: 1,
                decoration: _fieldDecor(l10n.groups),
                onChanged: (val) {
                  spinValue = val.toInt();
                },
              ),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              title: Text(l10n.groupsApplyToOthers),
              subtitle: Text(l10n.groupsApplyToOthersDesc),
              value: applyToOthers,
              onChanged: (val) {
                setState(() {
                  applyToOthers = val ?? false;
                });
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
      actions: [
        _cancelBtn(context),
        _confirmBtn(context, l10n.groupsAdd, () {
          final groups = spinValue;
          final isValid = groups != null && groups >= 2 && groups <= 10;
          if (!isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('groups must be greater than 1'),
                backgroundColor: Color(0xFFE6A23C),
              ),
            );

            return;
          }
          if (selectedSubjectIndex == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select a subject'),
                backgroundColor: Color(0xFFE6A23C),
              ),
            );
            return;
          }
          if (applyToOthers) {
            widget.ref
                .read(groupsProvider.notifier)
                .applySameRuleToAllClasses(
                  widget.classIds ?? [],
                  selectedSubjectIndex! + 1,
                  spinValue!,
                );
          } else {
            widget.ref
                .read(groupsProvider.notifier)
                .addNewGroup(
                  widget.classId,
                  selectedSubjectIndex! + 1,
                  spinValue!,
                );
          }
          Navigator.pop(context);
        }),
      ],
    );
  }
}
