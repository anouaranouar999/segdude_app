import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/responsive_width_guard.dart';

class AddRooms extends ConsumerStatefulWidget {
  const AddRooms({super.key});

  @override
  ConsumerState<AddRooms> createState() => _AddRoomsState();
}

class _AddRoomsState extends ConsumerState<AddRooms>
    with SingleTickerProviderStateMixin {
  // ── Design tokens — static const, scoped to State ─────────────────────────
  static const _blue = Color(0xFF2A6FDB);
  static const _headerBg = Color(0xFFEEF3FB);
  static const _headerText = Color(0xFF2A4A7F);
  static const _divider = Color(0xFFDDE3EC);
  static const _pageBg = Color(0xFFF4F7FB);
  static const _textPrimary = Color(0xFF1A2E4A);
  static const _textMuted = Color(0xFF5A6A85);
  static const _errorRed = Color(0xFFD94040);
  static const _successGreen = Color(0xFF16A34A);

  // ── Form state — all existing logic preserved exactly ─────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final Set<int> _allowedSubjectIds = {};
  final Set<int> _allowedLevelIds = {};
  int? _forcedSubjectId;
  bool _submitting = false;

  // ── Edit mode — null means Add Room mode ──────────────────────────────────
  int? _editingRoomId;
  // Forced-subject value the room had when Edit Mode was entered, used to
  // detect whether the forced-subject association actually changed on Save.
  int? _originalForcedSubjectId;

  // ── Tracks which room IDs have animated in — prevents re-animation ─────────
  final Set<int> _seenRoomIds = {};

  // ── Page-load animation ───────────────────────────────────────────────────
  late final AnimationController _pageAnimCtrl;
  late final Animation<double> _pageFade;
  late final Animation<Offset> _pageSlide;
  // ── params for selected classes of level ─────────────────────────────────────────────────────────────
  final Set<int> _selectedLevelIds = {};
  final Set<int> _selectedClassIdsByLevel = {};

  @override
  void initState() {
    super.initState();
    // Pre-seed with existing rooms so only newly added ones animate
    final existing = ref.read(roomsProvider).rooms;
    _seenRoomIds.addAll(existing.map((r) => r.roomId));

    _pageAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _pageFade = CurvedAnimation(parent: _pageAnimCtrl, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageAnimCtrl, curve: Curves.easeOut));
    _pageAnimCtrl.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _pageAnimCtrl.dispose();
    super.dispose();
  }

  // ── Static UI helpers — identical design system as add_teacher ────────────

  static InputDecoration _fieldDecor(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Color(0xFF90A4AE)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorRed, width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      );

  static Widget _card({
    required String title,
    String? tooltip,
    required Widget child,
  }) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _divider),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _headerText,
                  letterSpacing: 0.5,
                ),
              ),
              if (tooltip != null) ...[
                const SizedBox(width: 6),
                _InfoTooltip(message: tooltip),
              ],
            ],
          ),
        ),
        child,
      ],
    ),
  );

  static Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 14),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: _textMuted,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _divider)),
      ],
    ),
  );

  static Widget _emptyHint(String message) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _headerBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, size: 14, color: _headerText),
        const SizedBox(width: 6),
        Text(message, style: const TextStyle(fontSize: 12, color: _headerText)),
      ],
    ),
  );

  static Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: _headerBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: _headerText),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: _textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
        ),
      ],
    ),
  );

  // ── Help bottom sheet ─────────────────────────────────────────────────────

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const _RoomHelpSheet(),
    );
  }

  // ── Form submission — ALL EXISTING LOGIC PRESERVED EXACTLY ───────────────

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final capacity = _capacityCtrl.text.trim().isEmpty
        ? 40
        : int.parse(_capacityCtrl.text.trim());

    final finalAllowedSubjects = _allowedLevelIds.toList();
    if (_forcedSubjectId != null &&
        !finalAllowedSubjects.contains(_forcedSubjectId!)) {
      finalAllowedSubjects.add(_forcedSubjectId!);
    }

    final levelsState = ref.read(levelsProvider);
    final Map<int, List<int>> allowedClassesMap = {};
    for (final classId in _selectedClassIdsByLevel) {
      final cls = levelsState.classes.firstWhere(
        (c) => c.classId == classId,
        orElse: () => ClassLevelEncoder(classId, null, null, 0),
      );
      if (cls.levelId != null) {
        allowedClassesMap.putIfAbsent(cls.levelId!, () => []).add(classId);
      }
    }
    for (final key in allowedClassesMap.keys) {
      allowedClassesMap[key]!.sort();
    }

    final isEditing = _editingRoomId != null;
    final int roomId;
    if (isEditing) {
      roomId = _editingRoomId!;
      ref
          .read(roomsProvider.notifier)
          .editRoom(
            roomId,
            _nameCtrl.text.trim(),
            capacity,
            finalAllowedSubjects..sort(),
            _allowedSubjectIds.toList()..sort(),
            allowedClassesMap,
            true,
          );
    } else {
      roomId = ref
          .read(roomsProvider.notifier)
          .addRoom(
            _nameCtrl.text.trim(),
            capacity,
            finalAllowedSubjects..sort(),
            _allowedSubjectIds.toList()..sort(),
            allowedClassesMap,
          );
    }

    // Only touch the forced-subject association when it actually changed —
    // in Add mode this is always true (a brand-new room), matching the
    // original behavior exactly.
    final forcedSubjectChanged =
        !isEditing || _forcedSubjectId != _originalForcedSubjectId;
    if (isEditing && _originalForcedSubjectId != null && forcedSubjectChanged) {
      // Detach the room from the subject it was previously forced to,
      // using the same primitive already used when a room is deleted.
      ref.read(subjectsProvider.notifier).removeEditForcedRoom(roomId);
    }
    if (_forcedSubjectId != null && forcedSubjectChanged) {
      final subject = ref
          .read(subjectsProvider)
          .subjects
          .firstWhere((s) => s.subjectId == _forcedSubjectId!);
      final updatedRooms = List<int>.from(subject.forcedRoomsIds ?? [])
        ..add(roomId);
      ref
          .read(subjectsProvider.notifier)
          .editSubject(_forcedSubjectId!, forcedRoomsIds: updatedRooms);
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final name = _nameCtrl.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              isEditing
                  ? l10n.roomUpdatedSuccessfully(name)
                  : l10n.roomAddedSuccessfully(name),
            ),
          ],
        ),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
    _nameCtrl.clear();
    _capacityCtrl.clear();
    setState(() {
      _allowedSubjectIds.clear();
      _allowedLevelIds.clear();
      _selectedLevelIds.clear();
      _selectedClassIdsByLevel.clear();
      _forcedSubjectId = null;
      _originalForcedSubjectId = null;
      _editingRoomId = null;
      _submitting = false;
    });
  }

  // ── Enter Edit Mode — pre-fills the existing Add Room form with the
  // selected room's current data. Reuses the same form/state used for Add;
  // does not open a new page or dialog. ─────────────────────────────────────
  void _enterEditMode(RoomEncoder room) {
    FocusScope.of(context).unfocus();

    // Source of truth for "forced/used-only" subject is the subjects list —
    // same lookup already used to render the "Forced:" badge on the tile.
    final forcedSubjects = ref
        .read(subjectsProvider)
        .subjects
        .where((s) => s.forcedRoomsIds?.contains(room.roomId) ?? false)
        .toList();
    final forcedSubjectId = forcedSubjects.isNotEmpty
        ? forcedSubjects.first.subjectId
        : null;

    final Set<int> classIds = {
      for (final entry in (room.allowedClasses ?? {}).values) ...entry,
    };

    setState(() {
      _editingRoomId = room.roomId;
      _nameCtrl.text = room.roomName;
      _capacityCtrl.text = room.capacity.toString();
      _allowedSubjectIds
        ..clear()
        ..addAll(room.allowedLevels);
      _selectedLevelIds
        ..clear()
        ..addAll(room.allowedLevels);
      _selectedClassIdsByLevel
        ..clear()
        ..addAll(classIds);
      _allowedLevelIds
        ..clear()
        ..addAll(room.allowedSubjects.where((id) => id != forcedSubjectId));
      _forcedSubjectId = forcedSubjectId;
      _originalForcedSubjectId = forcedSubjectId;
    });
  }

  // ── Cancel Edit Mode — restores the normal Add Room state. No provider
  // update and no persistence write happen; the selected room is untouched.
  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    _nameCtrl.clear();
    _capacityCtrl.clear();
    setState(() {
      _allowedSubjectIds.clear();
      _allowedLevelIds.clear();
      _selectedLevelIds.clear();
      _selectedClassIdsByLevel.clear();
      _forcedSubjectId = null;
      _originalForcedSubjectId = null;
      _editingRoomId = null;
    });
  }

  // ── Generate rooms dialog — ALL LOGIC PRESERVED EXACTLY ──────────────────

  void _showGenerateDialog() {
    final countCtrl = TextEditingController();
    final patternCtrl = TextEditingController(text: 'Room #');
    String? countError;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final l10n = AppLocalizations.of(ctx)!;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            title: Text(
              l10n.generateRooms,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.generateRoomsDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: countCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setDialogState(() => countError = null),
                  decoration: InputDecoration(
                    labelText: l10n.numberOfRooms,
                    hintText: l10n.numberOfRoomsHint,
                    errorText: countError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: patternCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.namePatternLabel,
                    hintText: l10n.namePatternHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: _textMuted),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final n = int.tryParse(countCtrl.text.trim()) ?? 0;
                  if (n < 1) {
                    setDialogState(() => countError = l10n.mustBePositive);
                    return;
                  }
                  ref
                      .read(roomsProvider.notifier)
                      .generateRooms(
                        n,
                        patternCtrl.text.trim().isEmpty
                            ? 'Room #'
                            : patternCtrl.text.trim(),
                      );
                  Navigator.pop(ctx);
                },
                child: Text(l10n.generate),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  // Below this width the two-panel form + list layout (see `build` below)
  // starts producing RenderFlex overflows, so the page isn't built at all.
  static const double _kMinPageWidth = 900;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidthGuard(minWidth: _kMinPageWidth, builder: _buildPage);
  }

  Widget _buildPage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rooms = ref.watch(roomsProvider.select((s) => s.rooms));
    final levelsMap = ref.watch(levelsProvider.select((s) => s.levels));
    final levelNames = levelsMap.keys.toList();
    final levelIds = ref.watch(levelsProvider.select((s) => s.levelIds));
    final subjects = ref.watch(subjectsProvider.select((s) => s.subjects));

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(l10n),
      floatingActionButton: _buildFab(l10n),
      body: FadeTransition(
        opacity: _pageFade,
        child: SlideTransition(
          position: _pageSlide,
          child: Row(
            children: [
              // ── Left panel — Form ──────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── BASIC INFORMATION ──────────────────────────
                        _sectionHeader(l10n.sectionBasicInformation),

                        // Room Name
                        _card(
                          title: l10n.cardRoomName,
                          tooltip: l10n.tooltipRoomName,
                          child: TextFormField(
                            controller: _nameCtrl,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textPrimary,
                            ),
                            decoration: _fieldDecor(
                              l10n.hintEnterRoomName,
                              Icons.meeting_room_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.validationRoomNameRequired;
                              }
                              if (v.trim().length < 2) {
                                return l10n.validationNameMinTwoChars;
                              }
                              if (ref
                                  .read(roomsProvider)
                                  .rooms
                                  .any(
                                    (r) =>
                                        r.roomName == v.trim() &&
                                        r.roomId != _editingRoomId,
                                  )) {
                                return l10n.validationRoomNameAlreadyExists;
                              }
                              return null;
                            },
                          ),
                        ),

                        _sectionHeader(l10n.sectionRestrictionsOptional),

                        // ── RESTRICTIONS ───────────────────────────────
                        _card(
                          title: l10n.cardAllowedLevels,
                          tooltip: l10n.tooltipAllowedLevels,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.allowedLevelsDescription,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              levelsMap.isEmpty
                                  ? _emptyHint(l10n.noLevelsDefinedYet)
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: levelNames.map((name) {
                                        final levelId = levelIds[name]!;
                                        return _SelectChip(
                                          label: name,
                                          selected: _allowedSubjectIds.contains(
                                            levelId,
                                          ),
                                          onToggle: () => setState(() {
                                            if (_allowedSubjectIds.contains(
                                              levelId,
                                            )) {
                                              _allowedSubjectIds.remove(
                                                levelId,
                                              );
                                              _selectedLevelIds.remove(levelId);
                                            } else {
                                              _allowedSubjectIds.add(levelId);
                                              _selectedLevelIds.add(levelId);
                                            }
                                          }),
                                        );
                                      }).toList(),
                                    ),
                              // if (_allowedSubjectIds.isNotEmpty)
                              //   Padding(
                              //     padding: const EdgeInsets.only(top: 8),
                              //     child: Text(
                              //       l10n.nLevelsSelected(
                              //         _allowedSubjectIds.length,
                              //       ),
                              //       style: const TextStyle(
                              //         fontSize: 11,
                              //         color: _blue,
                              //       ),
                              //     ),
                              //   ),
                              if (_selectedLevelIds.isNotEmpty)
                                ..._selectedLevelIds.map((levelId) {
                                  final classesForLevel = ref
                                      .read(levelsProvider)
                                      .classes
                                      .where((c) => levelId == c.levelId)
                                      .toList();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${levelIds.keys.firstWhere((k) => levelIds[k] == levelId)} : ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: _headerText,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(
                                              l10n.ifNoneSelected,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        Wrap(
                                          spacing: 3,
                                          runSpacing: 3,
                                          children: [
                                            for (var c in classesForLevel)
                                              _SelectChip(
                                                label: c.className ?? '',
                                                selected:
                                                    _selectedClassIdsByLevel
                                                        .contains(c.classId),
                                                onToggle: () => setState(() {
                                                  if (_selectedClassIdsByLevel
                                                      .contains(c.classId)) {
                                                    _selectedClassIdsByLevel
                                                        .remove(c.classId);
                                                  } else {
                                                    _selectedClassIdsByLevel
                                                        .add(c.classId ?? 0);
                                                  }
                                                }),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),

                        _card(
                          title: l10n.cardAllowedSubjects,
                          tooltip: l10n.tooltipAllowedSubjects,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.allowedSubjectsDescription,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              subjects.isEmpty
                                  ? _emptyHint(l10n.noSubjectsDefinedYet)
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: subjects
                                          .map(
                                            (s) => _SelectChip(
                                              label: s.subjectName ?? '',
                                              selected: _allowedLevelIds
                                                  .contains(s.subjectId),
                                              onToggle: () => setState(() {
                                                _forcedSubjectId = null;
                                                if (_allowedLevelIds.contains(
                                                  s.subjectId,
                                                )) {
                                                  _allowedLevelIds.remove(
                                                    s.subjectId,
                                                  );
                                                } else {
                                                  _allowedLevelIds.add(
                                                    s.subjectId,
                                                  );
                                                }
                                              }),
                                            ),
                                          )
                                          .toList(),
                                    ),
                              if (_allowedLevelIds.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    l10n.nSubjectsSelected(
                                      _allowedLevelIds.length,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _blue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ------------------------------------- Allowed Subjects
                        _card(
                          title: l10n.cardUsedOnlyFor,
                          tooltip: l10n.tooltipUsedOnlyFor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.usedOnlyForDescription,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              subjects.isEmpty
                                  ? _emptyHint(l10n.noSubjectsDefinedYet)
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: subjects
                                          .map(
                                            (s) => _SelectChip(
                                              label: s.subjectName ?? '',
                                              selected:
                                                  _forcedSubjectId ==
                                                  s.subjectId,
                                              onToggle: () => setState(() {
                                                if (_forcedSubjectId ==
                                                    s.subjectId) {
                                                  _forcedSubjectId = null;
                                                } else {
                                                  _allowedLevelIds.clear();
                                                  _forcedSubjectId =
                                                      s.subjectId;
                                                }
                                              }),
                                            ),
                                          )
                                          .toList(),
                                    ),
                            ],
                          ),
                        ),
                        _card(
                          /// ------------------------------------- Capacity
                          title: l10n.cardCapacityOptional,
                          tooltip: l10n.tooltipCapacity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.capacityDescription,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _capacityCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                                decoration: _fieldDecor(
                                  l10n.hintCapacity,
                                  Icons.people_outline,
                                ),
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1) {
                                      return l10n.validationMustBeNumberGteOne;
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Divider ─────────────────────────────────────────────
              const VerticalDivider(thickness: 1, width: 1, color: _divider),

              // ── Right panel — Room list ────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildListHeader(l10n, rooms.length),
                    // Swipe hint — only when rooms exist
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: rooms.isEmpty
                          ? const SizedBox.shrink()
                          : Container(
                              color: const Color(0xFFFFF8F0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.swipe_left_outlined,
                                    size: 12,
                                    color: Color(0xFFEA580C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    l10n.swipeLeftToDeleteRoom,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFEA580C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const Divider(height: 1, color: _divider),
                    Expanded(
                      child: rooms.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.meeting_room_outlined,
                              title: l10n.noRoomsAddedYet,
                              subtitle: l10n.noRoomsAddedYetSubtitle,
                            )
                          : _buildRoomList(rooms),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) => AppBar(
    title: Text(l10n.addRooms),
    actions: [
      // Generate — secondary action, muted styling
      TextButton.icon(
        onPressed: _showGenerateDialog,
        icon: const Icon(
          Icons.auto_fix_high_outlined,
          size: 15,
          color: _textMuted,
        ),
        label: Text(
          l10n.generate,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textMuted,
          ),
        ),
      ),
      // Guide — primary AppBar action
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: _showHelp,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _headerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lightbulb_rounded, size: 14, color: _blue),
                const SizedBox(width: 5),
                Text(
                  l10n.guide,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  // ── FAB ──────────────────────────────────────────────────────────────────

  Widget _buildFab(AppLocalizations l10n) {
    if (_editingRoomId != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            key: const ValueKey('fab_cancel_edit'),
            heroTag: 'roomsFabCancelEdit',
            onPressed: _submitting ? null : _cancelEdit,
            backgroundColor: Colors.white,
            foregroundColor: _textMuted,
            elevation: 2,
            icon: const Icon(Icons.close_rounded, size: 18, color: _textMuted),
            label: Text(
              l10n.cancel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: _submitting
                ? FloatingActionButton(
                    key: const ValueKey('fab_save_edit_loading'),
                    heroTag: 'roomsFabSaveEditLoading',
                    onPressed: null,
                    backgroundColor: _blue.withValues(alpha: 0.75),
                    elevation: 4,
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  )
                : FloatingActionButton.extended(
                    key: const ValueKey('fab_save_edit'),
                    heroTag: 'roomsFabSaveEdit',
                    onPressed: _submit,
                    backgroundColor: _blue,
                    elevation: 4,
                    icon: const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: _submitting
          ? FloatingActionButton(
              key: const ValueKey('fab_loading'),
              heroTag: 'roomsFabLoading',
              onPressed: null,
              backgroundColor: _blue.withValues(alpha: 0.75),
              elevation: 4,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            )
          : FloatingActionButton.extended(
              key: const ValueKey('fab_idle'),
              heroTag: 'roomsFabIdle',
              onPressed: _submit,
              backgroundColor: _blue,
              elevation: 4,
              icon: const Icon(
                Icons.meeting_room_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                l10n.addRoom,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
    );
  }

  // ── Right-panel header ───────────────────────────────────────────────────

  Widget _buildListHeader(AppLocalizations l10n, int count) => Container(
    color: _headerBg,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        const Icon(Icons.meeting_room_outlined, size: 16, color: _headerText),
        const SizedBox(width: 8),
        Text(
          l10n.roomsAdded,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _headerText,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: count == 0
              ? const SizedBox.shrink()
              : Container(
                  key: const ValueKey('badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ],
    ),
  );

  // ── Animated room list ────────────────────────────────────────────────────

  Widget _buildRoomList(List<RoomEncoder> rooms) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      separatorBuilder: (_, _) => const Divider(height: 1, color: _divider),
      itemCount: rooms.length,
      itemBuilder: (context, i) {
        final r = rooms[i];
        final isNew = !_seenRoomIds.contains(r.roomId);
        if (isNew) _seenRoomIds.add(r.roomId);

        return _AnimatedListItem(
          key: ValueKey(r.roomId),
          animate: isNew,
          child: Dismissible(
            key: ValueKey('dismiss_${r.roomId}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: _errorRed.withValues(alpha: 0.08),
              child: const Icon(
                Icons.delete_outline,
                color: _errorRed,
                size: 22,
              ),
            ),
            onDismissed: (_) => _deleteRoom(r),
            child: _RoomTile(
              room: r,
              onEdit: () => _enterEditMode(r),
              onDelete: () => _deleteRoom(r),
            ),
          ),
        );
      },
    );
  }

  void _deleteRoom(RoomEncoder r) {
    final l10n = AppLocalizations.of(context)!;
    _seenRoomIds.remove(r.roomId);
    ref.read(roomsProvider.notifier).removeRoom(r.roomId);
    ref.read(subjectsProvider.notifier).removeEditForcedRoom(r.roomId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.roomRemoved(r.roomName)),
        backgroundColor: _errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SelectChip — FilterChip for allowed levels / subjects
// ─────────────────────────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onToggle;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onToggle(),
      selectedColor: const Color(0xFF2A6FDB),
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFF2A6FDB) : const Color(0xFFDDE3EC),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        color: selected ? Colors.white : const Color(0xFF1A2E4A),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoomTile
// ─────────────────────────────────────────────────────────────────────────────

class _RoomTile extends ConsumerStatefulWidget {
  final RoomEncoder room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoomTile({
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<_RoomTile> createState() => _RoomTileState();
}

class _RoomTileState extends ConsumerState<_RoomTile> {
  static const _blue = Color(0xFF2A6FDB);
  static const _textPrimary = Color(0xFF1A2E4A);
  static const _textMuted = Color(0xFF5A6A85);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subjectsState = ref.watch(subjectsProvider);
    final levelsState = ref.watch(levelsProvider);

    final allowedLevels = widget.room.allowedLevels;
    final allowedClasses = widget.room.allowedClasses ?? {};
    final allowedSubjects = widget.room.allowedSubjects;

    final forcedSubjects = subjectsState.subjects
        .where((s) => s.forcedRoomsIds?.contains(widget.room.roomId) ?? false)
        .toList();

    // Group allowed classes by level ID
    final Map<int, List<ClassLevelEncoder>> classesByLevel = {};
    for (final entry in allowedClasses.entries) {
      final levelId = entry.key;
      for (final classId in entry.value) {
        final cls = levelsState.classes.firstWhere(
          (c) => c.classId == classId,
          orElse: () => ClassLevelEncoder(classId, null, null, 0),
        );
        if (cls.className != null) {
          classesByLevel.putIfAbsent(levelId, () => []).add(cls);
        }
      }
    }

    return InkWell(
      onTap: () {
        debugPrint('Tapped on room: ${widget.room.toJson()}');
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hovered ? const Color(0xFFF7F9FF) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Icon avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.meeting_room_outlined,
                  size: 18,
                  color: _blue,
                ),
              ),
              const SizedBox(width: 12),
              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.room.roomName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 11,
                          color: _textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l10n.capacityValue(widget.room.capacity),
                          style: const TextStyle(
                            fontSize: 12,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    if (allowedLevels.isNotEmpty ||
                        allowedSubjects.isNotEmpty ||
                        forcedSubjects.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      // Subjects (Allowed & Forced)
                      if (allowedSubjects.isNotEmpty ||
                          forcedSubjects.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (allowedSubjects.isNotEmpty) ...[
                                const Icon(
                                  Icons.menu_book_outlined,
                                  size: 12,
                                  color: _textMuted,
                                ),
                                ...allowedSubjects.map((subId) {
                                  final subject = subjectsState.subjects
                                      .firstWhere(
                                        (s) => s.subjectId == subId,
                                        orElse: () => SubjectEncoder(
                                          subId,
                                          'Subject $subId',
                                          null,
                                        ),
                                      );
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.green.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      subject.subjectName ?? 'Subject $subId',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              if (forcedSubjects.isNotEmpty) ...[
                                const Icon(
                                  Icons.push_pin_outlined,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                ...forcedSubjects.map((subject) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.orange.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Forced: ${subject.subjectName ?? 'Subject ${subject.subjectId}'}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      // Levels & Classes
                      if (allowedLevels.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.layers_outlined,
                              size: 12,
                              color: _textMuted,
                            ),
                            for (final levelId in allowedLevels)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _blue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _blue.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      levelsState.realID[levelId] ??
                                          'L$levelId',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    if (classesByLevel[levelId] != null &&
                                        classesByLevel[levelId]!
                                            .isNotEmpty) ...[
                                      const Text(
                                        ':',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _textMuted,
                                        ),
                                      ),
                                      ...classesByLevel[levelId]!.map((cls) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            cls.className ??
                                                'Class ${cls.classId}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: _textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              // Edit + Delete icons — fade when not hovered
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered ? 1.0 : 0.35,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: _blue,
                      ),
                      onPressed: widget.onEdit,
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.editRoom,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFFD94040),
                      ),
                      onPressed: widget.onDelete,
                      visualDensity: VisualDensity.compact,
                      tooltip: l10n.removeRoom,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedListItem — entrance animation for newly added list items
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final bool animate;

  const _AnimatedListItem({
    required super.key,
    required this.child,
    required this.animate,
  });

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.animate) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _InfoTooltip — field-level help icon using Flutter Tooltip (web-compatible)
// Tooltip uses hover on web, long-press on mobile — correct for both platforms
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTooltip extends StatelessWidget {
  final String message;

  const _InfoTooltip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 200),
      showDuration: const Duration(seconds: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E4A),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        height: 1.45,
      ),
      child: const Icon(Icons.info_outline, size: 14, color: Color(0xFF8A9BB5)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RoomHelpSheet — DraggableScrollableSheet with full field documentation
// ─────────────────────────────────────────────────────────────────────────────

class _RoomHelpSheet extends StatelessWidget {
  const _RoomHelpSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.76,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 8, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A6FDB), Color(0xFF1A4FA8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.helpSheetRoomsTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2E4A),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          l10n.helpSheetSubtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A6A85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Color(0xFF8A9BB5),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFDDE3EC)),
            // Content
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  _HelpEntry(
                    icon: Icons.meeting_room_outlined,
                    color: const Color(0xFF2A6FDB),
                    title: l10n.helpEntryRoomNameTitle,
                    isRequired: true,
                    body: l10n.helpEntryRoomNameBody,
                  ),
                  _HelpEntry(
                    icon: Icons.people_outline,
                    color: const Color(0xFF16A34A),
                    title: l10n.helpEntryCapacityTitle,
                    isRequired: false,
                    body: l10n.helpEntryCapacityBody,
                  ),
                  _HelpEntry(
                    icon: Icons.school_outlined,
                    color: const Color(0xFF9333EA),
                    title: l10n.helpEntryAllowedLevelsTitle,
                    isRequired: false,
                    body: l10n.helpEntryAllowedLevelsBody,
                  ),
                  _HelpEntry(
                    icon: Icons.menu_book_outlined,
                    color: const Color(0xFFEA580C),
                    title: l10n.helpEntryAllowedSubjectsTitle,
                    isRequired: false,
                    body: l10n.helpEntryAllowedSubjectsBody,
                  ),
                  _HelpEntry(
                    icon: Icons.auto_fix_high_outlined,
                    color: const Color(0xFF0891B2),
                    title: l10n.helpEntryGenerateRoomsTitle,
                    isRequired: false,
                    body: l10n.helpEntryGenerateRoomsBody,
                  ),
                  _HelpEntry(
                    icon: Icons.swipe_left_outlined,
                    color: const Color(0xFFD94040),
                    title: l10n.helpEntryDeletingRoomTitle,
                    isRequired: false,
                    body: l10n.helpEntryDeletingRoomBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HelpEntry — one documented field inside the help sheet
// ─────────────────────────────────────────────────────────────────────────────

class _HelpEntry extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final bool isRequired;
  final String body;

  const _HelpEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.isRequired,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2E4A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isRequired
                            ? const Color(0xFFD94040).withValues(alpha: 0.10)
                            : const Color(0xFF5A6A85).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isRequired ? l10n.fieldRequired : l10n.optional,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isRequired
                              ? const Color(0xFFD94040)
                              : const Color(0xFF5A6A85),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A6A85),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
