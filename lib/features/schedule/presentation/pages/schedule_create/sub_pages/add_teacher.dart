import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/responsive_width_guard.dart';

class AddTeacher extends ConsumerStatefulWidget {
  const AddTeacher({super.key});

  @override
  ConsumerState<AddTeacher> createState() => _AddTeacherState();
}

class _AddTeacherState extends ConsumerState<AddTeacher>
    with SingleTickerProviderStateMixin {
  // ── Design tokens — final, scoped to State ─────────────────────────
  final _blue = Color(0xFF2A6FDB);
  final _headerBg = Color(0xFFEEF3FB);
  final _headerText = Color(0xFF2A4A7F);
  final _divider = Color(0xFFDDE3EC);
  final _pageBg = Color(0xFFF4F7FB);
  final _textPrimary = Color(0xFF1A2E4A);
  final _textMuted = Color(0xFF5A6A85);
  final _errorRed = Color(0xFFD94040);
  final _successGreen = Color(0xFF16A34A);

  // ── Form state — all existing logic preserved exactly ─────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _maxHoursCtrl = TextEditingController();
  int? _selectedSubjectId;
  final Set<int> _selectedLevelIds = {};
  final Map<int, Set<int>> _selectedClassIdsByLevel = {};
  bool _submitting = false;
  bool _showLevelError = false; // Dedicated flag, survives the frame
  bool _requireConsecutiveHours = true;
  // null = Add mode, non-null = Edit mode (holds the teacher being edited)
  int? _editingTeacherId;

  // ── Tracks which teacher IDs have animated in — prevents re-animation ─────
  final Set<int> _seenTeacherIds = {};

  // ── Page-load animation ───────────────────────────────────────────────────
  late final AnimationController _pageAnimCtrl;
  late final Animation<double> _pageFade;
  late final Animation<Offset> _pageSlide;

  @override
  void initState() {
    super.initState();
    // Pre-seed with already-existing teachers so only newly added ones animate
    final existing = ref.read(teachersProvider).teachers;
    _seenTeacherIds.addAll(existing.map((t) => t.teacherId));

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
    _maxHoursCtrl.dispose();
    _pageAnimCtrl.dispose();
    super.dispose();
  }

  // ── Static UI helpers — no `this` access, safe in static methods ──────────

  InputDecoration _fieldDecor(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
    prefixIcon: Icon(icon, size: 18, color: Color(0xFF90A4AE)),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _blue, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _errorRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: _errorRed, width: 1.5),
    ),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
  );

  /// Card wrapper — optional [tooltip] shows an info icon next to the title
  Widget _card({
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
        // Card header: label + optional info icon
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
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

  /// Section divider with title — groups related cards
  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 14),
    child: Row(
      children: [
        Text(
          title,
          style: TextStyle(
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

  // ── Help bottom sheet ─────────────────────────────────────────────────────

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const _TeacherHelpSheet(),
    );
  }

  // ── Form submission — ALL EXISTING LOGIC PRESERVED EXACTLY ───────────────

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final qualifiedLevels = _selectedLevelIds.toList()..sort();
    final maxHours = _maxHoursCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_maxHoursCtrl.text.trim());
    final qualifiedClasses = <int, List<int>>{};
    for (final levelId in qualifiedLevels) {
      final classIds = _selectedClassIdsByLevel[levelId]?.toList()?..sort();
      if (classIds != null && classIds.isNotEmpty) {
        qualifiedClasses[levelId] = classIds;
      }
    }

    final name = _nameCtrl.text.trim();
    final editingId = _editingTeacherId;

    if (editingId != null) {
      ref
          .read(teachersProvider.notifier)
          .editTeacher(
            editingId,
            name,
            subjectId: _selectedSubjectId!,
            qualifiedLevels: qualifiedLevels,
            maxHoursPerWeek: maxHours,
            isbackToback: _requireConsecutiveHours,
            qualifiedClasses: qualifiedClasses.isEmpty
                ? null
                : qualifiedClasses,
          );
    } else {
      ref
          .read(teachersProvider.notifier)
          .addTeacher(
            name,
            subjectId: _selectedSubjectId!,
            qualifiedLevels: qualifiedLevels,
            maxHoursPerWeek: maxHours,
            isbackToback: _requireConsecutiveHours,
            qualifiedClasses: qualifiedClasses.isEmpty
                ? null
                : qualifiedClasses,
          );
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
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
              editingId != null
                  ? l10n.teacherUpdatedSuccessfully(name)
                  : l10n.teacherAddedSuccessfully(name),
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
    _maxHoursCtrl.clear();
    setState(() {
      _editingTeacherId = null;
      _selectedSubjectId = null;
      _selectedLevelIds.clear();
      _selectedClassIdsByLevel.clear();
      _showLevelError = false;
      _submitting = false;
      _requireConsecutiveHours = true;
    });
  }

  // ── Enter Edit Mode — pre-fill the existing form with the teacher's data ──

  void _startEdit(TeacherEncoder teacher) {
    FocusScope.of(context).unfocus();
    _nameCtrl.text = teacher.teacherName ?? '';
    _maxHoursCtrl.text = teacher.maxHoursPerWeek?.toString() ?? '';
    setState(() {
      _editingTeacherId = teacher.teacherId;
      _selectedSubjectId = teacher.subjectId;
      _selectedLevelIds
        ..clear()
        ..addAll(teacher.qualifiedLevels ?? const <int>[]);
      _selectedClassIdsByLevel.clear();
      for (final levelId in teacher.qualifiedLevels ?? const <int>[]) {
        _selectedClassIdsByLevel[levelId] = Set<int>.from(
          (teacher.qualifiedClasses ?? const {})[levelId] ?? const <int>[],
        );
      }
      _requireConsecutiveHours = teacher.requireConsecutiveHours ?? true;
      _showLevelError = false;
    });
  }

  // ── Cancel Edit Mode — discard changes, restore the normal Add form ───────

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    _nameCtrl.clear();
    _maxHoursCtrl.clear();
    setState(() {
      _editingTeacherId = null;
      _selectedSubjectId = null;
      _selectedLevelIds.clear();
      _selectedClassIdsByLevel.clear();
      _showLevelError = false;
      _requireConsecutiveHours = true;
    });
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
    final subjects = ref.watch(subjectsProvider.select((s) => s.subjects));
    final teachers = ref.watch(teachersProvider.select((s) => s.teachers));
    final levelsList = ref.watch(
      levelsProvider.select((s) => s.levels.keys.toList()),
    );
    final levelIds = ref.watch(levelsProvider.select((s) => s.levelIds));

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
              // ── Left panel — Form ────────────────────────────────────
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── BASIC INFORMATION ─────────────────────────
                        _sectionHeader(l10n.sectionBasicInformation),

                        // Teacher Name
                        _card(
                          title: l10n.cardTeacherName,
                          tooltip: l10n.tooltipTeacherName,
                          child: TextFormField(
                            controller: _nameCtrl,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(fontSize: 14, color: _textPrimary),
                            decoration: _fieldDecor(
                              l10n.hintEnterTeacherName,
                              Icons.person_outline,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.validationTeacherNameRequired;
                              }
                              if (v.trim().length < 2) {
                                return l10n.validationNameMinTwoChars;
                              }
                              if (ref
                                  .read(teachersProvider)
                                  .teachers
                                  .any(
                                    (t) =>
                                        t.teacherName == v.trim() &&
                                        t.teacherId != _editingTeacherId,
                                  )) {
                                return l10n.validationTeacherNameAlreadyExists;
                              }
                              return null;
                            },
                          ),
                        ),

                        // Subject
                        _card(
                          title: l10n.cardSubject,
                          tooltip: l10n.tooltipTeacherSubject,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<int>(
                                initialValue: _selectedSubjectId,
                                decoration: _fieldDecor(
                                  l10n.hintSelectSubject,
                                  Icons.menu_book_outlined,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                items: subjects
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s.subjectId,
                                        child: Text(s.subjectName ?? ''),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _selectedSubjectId = v),
                                validator: (v) => v == null
                                    ? l10n.validationSelectSubjectOrCreate
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              // Create new subject shortcut — InkWell (not GestureDetector)
                              InkWell(
                                onTap: () => context.go(
                                  '/create/schedule_second_page/create_subject',
                                ),
                                borderRadius: BorderRadius.circular(6),
                                splashColor: _blue.withValues(alpha: 0.08),
                                highlightColor: _blue.withValues(alpha: 0.05),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        size: 14,
                                        color: _blue,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        l10n.createNewSubject,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _blue,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: _blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── CONSTRAINTS ───────────────────────────────
                        _sectionHeader(l10n.sectionConstraints),

                        // Qualified Levels
                        _card(
                          title: l10n.cardQualifiedLevels,
                          tooltip: l10n.tooltipQualifiedLevels,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.qualifiedLevelsDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (levelsList.isEmpty)
                                _emptyHint(l10n.noLevelsDefinedYet)
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (int i = 0; i < levelsList.length; i++)
                                      _LevelChip(
                                        label: levelsList[i],
                                        selected: _selectedLevelIds.contains(
                                          levelIds[levelsList[i]]!,
                                        ),
                                        onToggle: () => setState(() {
                                          final levelId =
                                              levelIds[levelsList[i]]!;
                                          if (_selectedLevelIds.contains(
                                            levelId,
                                          )) {
                                            _selectedLevelIds.remove(levelId);
                                            _selectedClassIdsByLevel.remove(
                                              levelId,
                                            );
                                          } else {
                                            _selectedLevelIds.add(levelId);
                                            _selectedClassIdsByLevel
                                                .putIfAbsent(
                                                  levelId,
                                                  () => <int>{},
                                                );
                                            _showLevelError = false;
                                          }
                                        }),
                                      ),
                                  ],
                                ),
                              if (_selectedLevelIds.isNotEmpty)
                                ..._selectedLevelIds.map((levelId) {
                                  final classesForLevel = ref
                                      .read(levelsProvider)
                                      .classes
                                      .where((c) => c.levelId == levelId)
                                      .toList();
                                  if (classesForLevel.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${ref.read(levelsProvider).realID[levelId] ?? levelId} : ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: _headerText,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            Text(
                                              l10n.ifNoneSelected,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: _textMuted,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            for (final cls in classesForLevel)
                                              FilterChip(
                                                label: Text(
                                                  cls.className ?? '',
                                                ),
                                                selected:
                                                    _selectedClassIdsByLevel[levelId]
                                                        ?.contains(
                                                          cls.classId,
                                                        ) ??
                                                    false,
                                                onSelected: (_) {
                                                  setState(() {
                                                    final classSet =
                                                        _selectedClassIdsByLevel
                                                            .putIfAbsent(
                                                              levelId,
                                                              () => <int>{},
                                                            );
                                                    if (classSet.contains(
                                                      cls.classId,
                                                    )) {
                                                      classSet.remove(
                                                        cls.classId,
                                                      );
                                                    } else {
                                                      classSet.add(
                                                        cls.classId!,
                                                      );
                                                    }
                                                  });
                                                },
                                                selectedColor: _blue,
                                                backgroundColor: Colors.white,
                                                checkmarkColor: Colors.white,
                                                side: BorderSide(
                                                  color:
                                                      (_selectedClassIdsByLevel[levelId]
                                                              ?.contains(
                                                                cls.classId,
                                                              ) ??
                                                          false)
                                                      ? _blue
                                                      : _divider,
                                                ),
                                                labelStyle: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      (_selectedClassIdsByLevel[levelId]
                                                              ?.contains(
                                                                cls.classId,
                                                              ) ??
                                                          false)
                                                      ? Colors.white
                                                      : _textPrimary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              // Animated level error — gated on _showLevelError
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                child:
                                    _showLevelError && _selectedLevelIds.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              l10n.validationSelectAtLeastOneLevel,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        // Max Hours / Week
                        _card(
                          title: l10n.cardMaxHoursWeekOptional,
                          tooltip: l10n.tooltipMaxHoursWeek,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.maxHoursWeekDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _maxHoursCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                                decoration: _fieldDecor(
                                  l10n.hintMaxHours,
                                  Icons.schedule_outlined,
                                ),
                                validator: (v) {
                                  if (v != null && v.isNotEmpty) {
                                    final n = int.tryParse(v);
                                    if (n == null || n < 1) {
                                      return l10n.mustBePositive;
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        // Consecutive Hours
                        _card(
                          title: l10n.cardConsecutiveHours,
                          tooltip: l10n.tooltipConsecutiveHours,
                          child: Material(
                            type: MaterialType.transparency,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: _blue,
                              title: Text(
                                l10n.requireConsecutiveHours,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                l10n.consecutiveHoursDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                  height: 1.4,
                                ),
                              ),
                              value: _requireConsecutiveHours,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(
                                    () => _requireConsecutiveHours = val,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Divider ─────────────────────────────────────────────
              VerticalDivider(thickness: 1, width: 1, color: _divider),

              // ── Right panel — Teacher list ───────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildListHeader(l10n, teachers.length),
                    Divider(height: 1, color: _divider),
                    Expanded(
                      child: teachers.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.person_outline,
                              title: l10n.noTeachersAddedYet,
                              subtitle: l10n.noTeachersAddedYetSubtitle,
                            )
                          : _buildTeacherList(teachers, subjects),
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
    title: Text(l10n.addTeacher),
    actions: [
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
                Icon(Icons.lightbulb_rounded, size: 14, color: _blue),
                SizedBox(width: 5),
                Text(
                  l10n.guide,
                  style: TextStyle(
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
    if (_editingTeacherId != null) {
      return _buildEditActions(l10n);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: _submitting
          ? FloatingActionButton(
              key: const ValueKey('fab_loading'),
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
              onPressed: () {
                if (_selectedLevelIds.isEmpty) {
                  setState(() => _showLevelError = true);
                  _formKey.currentState!.validate();
                  return;
                }
                _submit();
              },
              backgroundColor: _blue,
              elevation: 4,
              icon: const Icon(
                Icons.person_add_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                l10n.addTeacher,
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

  // ── Edit-mode bottom actions: Cancel / Save ─────────────────────────────

  Widget _buildEditActions(AppLocalizations l10n) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      OutlinedButton(
        onPressed: _submitting ? null : _cancelEdit,
        style: OutlinedButton.styleFrom(
          foregroundColor: _textMuted,
          backgroundColor: Colors.white,
          side: BorderSide(color: _divider),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          l10n.cancel,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(width: 10),
      FloatingActionButton.extended(
        key: const ValueKey('fab_save'),
        onPressed: _submitting
            ? null
            : () {
                if (_selectedLevelIds.isEmpty) {
                  setState(() => _showLevelError = true);
                  _formKey.currentState!.validate();
                  return;
                }
                _submit();
              },
        backgroundColor: _submitting ? _blue.withValues(alpha: 0.75) : _blue,
        elevation: 4,
        icon: _submitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check, size: 18, color: Colors.white),
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
    ],
  );

  // ── Right-panel header ───────────────────────────────────────────────────

  Widget _buildListHeader(AppLocalizations l10n, int count) => Container(
    color: _headerBg,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      children: [
        Icon(Icons.people_outline, size: 16, color: _headerText),
        const SizedBox(width: 8),
        Text(
          l10n.teachersAdded,
          style: TextStyle(
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

  // ── Animated teacher list ─────────────────────────────────────────────────

  Widget _buildTeacherList(List<TeacherEncoder> teachers, List subjects) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      separatorBuilder: (_, _) => Divider(height: 1, color: _divider),
      itemCount: teachers.length,
      itemBuilder: (context, i) {
        final t = teachers[i];
        final id = t.teacherId;
        final isNew = !_seenTeacherIds.contains(id);
        if (isNew) _seenTeacherIds.add(id);
        final levelIds = ref.watch(levelsProvider.select((s) => s.levelIds));
        final classes = ref.watch(levelsProvider.select((s) => s.classes));
        final l10n = AppLocalizations.of(context)!;
        final subjectName =
            (subjects)
                .where((s) => s.subjectId == t.subjectId)
                .map((s) => (s.subjectName ?? '') as String)
                .firstOrNull ??
            l10n.unknownSubject;

        return _AnimatedListItem(
          key: ValueKey(id),
          animate: isNew,
          child: _TeacherTile(
            teacher: t,
            subjectName: subjectName,
            levelsIds: levelIds,
            classes: classes,
            onEdit: () => _startEdit(t),
            onDelete: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.teacherRemoved(t.teacherName ?? l10n.teacher),
                  ),
                  backgroundColor: _errorRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
              _seenTeacherIds.remove(id);
              ref.read(teachersProvider.notifier).removeTeacher(t.teacherId);
            },
          ),
        );
      },
    );
  }

  // ── Shared empty state ────────────────────────────────────────────────────

  Widget _buildEmptyState({
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
          decoration: BoxDecoration(color: _headerBg, shape: BoxShape.circle),
          child: Icon(icon, size: 28, color: _headerText),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: TextStyle(
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

  /// Reusable empty-data hint banner
  Widget _emptyHint(String message) => Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _headerBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, size: 14, color: _headerText),
        const SizedBox(width: 6),
        Text(message, style: TextStyle(fontSize: 12, color: _headerText)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LevelChip — FilterChip with keyboard/ARIA semantics (from previous fix)
// ─────────────────────────────────────────────────────────────────────────────

class _LevelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onToggle;

  const _LevelChip({
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
// _TeacherTile
// ─────────────────────────────────────────────────────────────────────────────

class _TeacherTile extends StatefulWidget {
  final TeacherEncoder teacher;
  final String subjectName;
  final Map<String, int> levelsIds;
  final List<ClassLevelEncoder> classes;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeacherTile({
    required this.teacher,
    required this.subjectName,
    required this.onEdit,
    required this.onDelete,
    required this.levelsIds,
    required this.classes,
  });

  @override
  State<_TeacherTile> createState() => _TeacherTileState();
}

class _TeacherTileState extends State<_TeacherTile> {
  final _blue = Color(0xFF2A6FDB);
  final _textPrimary = Color(0xFF1A2E4A);
  final _textMuted = Color(0xFF5A6A85);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () {
        debugPrint("teacher is ${widget.teacher.toJson()}");
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
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  (widget.teacher.teacherName ?? '?')[0].toUpperCase(),
                  style: TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.teacher.teacherName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 11,
                              color: _textMuted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              widget.subjectName,
                              style: TextStyle(fontSize: 12, color: _textMuted),
                            ),
                            if (widget.teacher.maxHoursPerWeek != null) ...[
                              Text(
                                '  ·  ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                ),
                              ),
                              Icon(
                                Icons.schedule_outlined,
                                size: 11,
                                color: _textMuted,
                              ),
                              SizedBox(width: 3),
                              Text(
                                l10n.maxHoursPerWeekValue(
                                  widget.teacher.maxHoursPerWeek!,
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.teacher.requireConsecutiveHours == true) ...[
                          const SizedBox(height: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 96),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final levelId
                                      in widget.teacher.qualifiedLevels ??
                                          const <int>[])
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _blue.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _blue.withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 3,
                                        children: [
                                          Text(
                                            widget.levelsIds.entries
                                                    .where(
                                                      (entry) =>
                                                          entry.value ==
                                                          levelId,
                                                    )
                                                    .firstOrNull
                                                    ?.key ??
                                                'L$levelId',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: _textPrimary,
                                            ),
                                          ),
                                          ...((widget
                                                          .teacher
                                                          .qualifiedClasses ??
                                                      {})[levelId] ??
                                                  [])
                                              .map((classId) {
                                                final className =
                                                    widget.classes
                                                        .firstWhere(
                                                          (cls) =>
                                                              cls.classId ==
                                                              classId,
                                                          orElse: () =>
                                                              ClassLevelEncoder(
                                                                classId,

                                                                levelId,

                                                                'Class $classId',
                                                                40,
                                                              ),
                                                        )
                                                        .className ??
                                                    'Class $classId';
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    className,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: _textMuted,
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Edit icon — fades when not hovered
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered ? 1.0 : 0.35,
                child: IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: _blue),
                  onPressed: widget.onEdit,
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.editTeacher,
                ),
              ),
              // Delete icon — fades when not hovered
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered ? 1.0 : 0.35,
                child: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFD94040),
                  ),
                  onPressed: widget.onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.removeTeacher,
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
    // Skip animation for items that were already in the list on page open
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
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTooltip extends StatelessWidget {
  final String message;

  const _InfoTooltip({required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      // Tooltip uses hover on web, long-press on mobile — no OverlayPortal needed
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
// _TeacherHelpSheet — DraggableScrollableSheet with full field documentation
// ─────────────────────────────────────────────────────────────────────────────

class _TeacherHelpSheet extends StatelessWidget {
  const _TeacherHelpSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.74,
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
                          l10n.helpSheetTeachersTitle,
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
                    icon: Icons.person_outline,
                    color: const Color(0xFF2A6FDB),
                    title: l10n.helpEntryTeacherNameTitle,
                    isRequired: true,
                    body: l10n.helpEntryTeacherNameBody,
                  ),
                  _HelpEntry(
                    icon: Icons.menu_book_outlined,
                    color: const Color(0xFF16A34A),
                    title: l10n.helpEntryTeacherSubjectTitle,
                    isRequired: true,
                    body: l10n.helpEntryTeacherSubjectBody,
                  ),
                  _HelpEntry(
                    icon: Icons.school_outlined,
                    color: const Color(0xFF9333EA),
                    title: l10n.helpEntryQualifiedLevelsTitle,
                    isRequired: true,
                    body: l10n.helpEntryQualifiedLevelsBody,
                  ),
                  _HelpEntry(
                    icon: Icons.schedule_outlined,
                    color: const Color(0xFFEA580C),
                    title: l10n.helpEntryMaxHoursTitle,
                    isRequired: false,
                    body: l10n.helpEntryMaxHoursBody,
                  ),
                  _HelpEntry(
                    icon: Icons.view_agenda_outlined,
                    color: const Color(0xFF0891B2),
                    title: l10n.helpEntryConsecutiveHoursTitle,
                    isRequired: false,
                    body: l10n.helpEntryConsecutiveHoursBody,
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
