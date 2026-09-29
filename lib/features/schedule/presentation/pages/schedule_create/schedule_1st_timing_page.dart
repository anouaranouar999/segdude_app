import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/auth/data/auth_repository.dart';
import 'package:segdude_app/shared/widgets/cta_button.dart';
import 'package:segdude_app/shared/widgets/navigation_guard.dart';
import 'package:segdude_app/features/schedule/data/load_saved_data.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/widgets/days_portaloverlay.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/app_confirmation_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/groups_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/levels_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/manual_overrides_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/rooms_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_result_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/schedule_serialization.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/subjects_provider.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/teachers_provider.dart';

// ── File-level pure functions — stateless helpers, no memory concern ──────────

/// Asks the user to confirm before signing them out, then delegates to the
/// existing [authRepositoryProvider]'s `signOut()` flow. Navigation/redirect
/// after logout is already handled by [AppRouter]'s `refreshListenable`,
/// which reacts to the Supabase auth state change — nothing else to trigger
/// here.
Future<void> _handleLogout(
  BuildContext context,
  AppLocalizations l10n,
  WidgetRef ref,
) async {
  final confirmed = await AppConfirmationDialog.show(
    context,
    title: l10n.confirmLogoutTitle,
    message: l10n.confirmLogoutMessage,
    cancelLabel: l10n.cancel,
    confirmLabel: l10n.signOut,
  );
  if (confirmed) {
    ref.read(authRepositoryProvider).signOut();
  }
}

Widget _sectionCard({required String title, required Widget child}) =>
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDE3EC)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF3FB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A4A7F),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );

Widget _summaryRow(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5A6A85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A2E4A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// FIX: was ConsumerWidget — TextEditingControllers had no dispose(), causing
//      memory leaks. Converted to ConsumerStatefulWidget so State.dispose()
//      can release all controllers when the widget is removed from the tree.
// ─────────────────────────────────────────────────────────────────────────────

/// add days maxHours slotsPerday and breaks dialog
class TimingConstraintsPage extends ConsumerStatefulWidget {
  const TimingConstraintsPage({this.from, super.key});
  final String? from;
  @override
  ConsumerState<TimingConstraintsPage> createState() =>
      _TimingConstraintsPageState();
}

class _TimingConstraintsPageState extends ConsumerState<TimingConstraintsPage> {
  // ── Moved from ConsumerWidget fields → State so dispose() is called ────────
  final _formKey = GlobalKey<FormState>();
  final _startHourKey = GlobalKey<FormFieldState>();
  final _endHourKey = GlobalKey<FormFieldState>();
  final _maxHoursKey = GlobalKey<FormFieldState>();
  final _startHourController = TextEditingController();
  final _endHourController = TextEditingController();
  final _maxHoursController = TextEditingController();
  final OverlayPortalController overlayController = OverlayPortalController();
  final prefs = SharedPreferencesService();

  // Pure data — not disposable, but correctly scoped to State

  final _hours = List.generate(24, (i) => i + 1);
  final _breakHours = List.generate(24, (i) => i + 1);

  final AuthRepository authRepository = AuthRepository(
    Supabase.instance.client,
  );
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userLicenseProvider.notifier).checkLicense();
    });
    if (widget.from == '/') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _initialDialog(context, ref, prefs);
      });
    }
    intiFields();
  }

  void intiFields() async {
    _startHourController.text =
        (await prefs.getInt('startTime'))?.toString() ?? "";
    _endHourController.text = (await prefs.getInt('endTime'))?.toString() ?? "";
  }

  @override
  void dispose() {
    // Controllers are now properly released when the widget leaves the tree
    _startHourController.dispose();
    _endHourController.dispose();
    _maxHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final daysMap = <String, String>{
      l10n.dayMonday: '1',
      l10n.dayTuesday: '2',
      l10n.dayWednesday: '3',
      l10n.dayThursday: '4',
      l10n.dayFriday: '5',
      l10n.daySaturday: '6',
      l10n.daySunday: '7',
    };

    final days = <String>[...daysMap.keys];
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      //----------------------------------------------------- AppBar
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.timingConstraints),
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.startFreshTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2A4A7F),
                    ),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.startFreshContent,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () async {
                        await SharedPreferencesService().clear();
                        if (context.mounted) {
                          Navigator.pop(context);
                          // Clear all text controllers
                          _startHourController.clear();
                          _endHourController.clear();
                          _maxHoursController.clear();
                          // Reset all provider states
                          ref.read(settingsProvider.notifier).reset();
                          ref.invalidate(levelsProvider);
                          ref.invalidate(subjectsProvider);
                          ref.invalidate(roomsProvider);
                          ref.invalidate(teachersProvider);
                          ref.invalidate(manualOverridesProvider);
                          ref.invalidate(currentScheduleProvider);
                          ref.invalidate(groupsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.allDataCleared,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.deleteAll,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete_forever, color: Colors.red),
            label: Text(
              AppLocalizations.of(context)!.startFresh,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              context.go('/');
            },
          ),
          PopupMenuButton(
            itemBuilder: (menuContext) => [
              PopupMenuItem(
                child: Text(l10n.creationOptions),
                onTap: () async {
                  await _initialDialog(context, ref, prefs);
                },
              ),
              PopupMenuItem(
                child: user == null ? Text(l10n.login) : Text(l10n.logout),
                onTap: () async {
                  if (user == null) {
                    context.push('/login?from=/create');
                  } else {
                    _handleLogout(context, l10n, ref);
                  }
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          // Create an OverlayPortal to Edit Slots Per Day
          // with form as a child
          OverlayPortal(
            controller: overlayController,
            overlayChildBuilder: (context) => DaysPortalOverlay(
              days: days,
              overlayController: overlayController,
            ),
            // ────────────────────────────────────────────────────────────────Show Form Uderlay
            child: RepaintBoundary(
              child: Form(
                key: _formKey,
                child: SizedBox.expand(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Left Column ──────────────────────────────────────────
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 80),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Days ──────────────────────────────────────────
                                _sectionCard(
                                  title: AppLocalizations.of(
                                    context,
                                  )!.selectWorkingDays,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final selectedDays = ref.watch(
                                        settingsProvider.select(
                                          (s) => s.selectedDays,
                                        ),
                                      );
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (selectedDays.isEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 8,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.warning_amber_rounded,
                                                    size: 16,
                                                    color: Color(0xFFD94040),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    AppLocalizations.of(
                                                      context,
                                                    )!.pleaseSelectOneDayOrderMatters,

                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFFD94040),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: [
                                              for (var day in days)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Checkbox(
                                                      value: selectedDays
                                                          .contains(
                                                            daysMap[day]!,
                                                          ),
                                                      activeColor: const Color(
                                                        0xFF2A6FDB,
                                                      ),
                                                      onChanged: (_) {
                                                        ref
                                                            .read(
                                                              settingsProvider
                                                                  .notifier,
                                                            )
                                                            .toggleDay(
                                                              daysMap[day]!,
                                                            );
                                                      },
                                                    ),

                                                    Text(
                                                      day,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Color(
                                                          0xFF1A2E4A,
                                                        ),
                                                      ),
                                                    ),

                                                    SizedBox(width: 8),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                // ── Time Slots ────────────────────────────────────
                                _sectionCard(
                                  title: AppLocalizations.of(
                                    context,
                                  )!.workingHoursTitle,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.workingHoursHint,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF5A6A85),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          // Start hour — original logic preserved
                                          Expanded(
                                            child: TextFormField(
                                              key: _startHourKey,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return AppLocalizations.of(
                                                    context,
                                                  )!.startHourRequired;
                                                }
                                                final n = int.tryParse(value);
                                                if (n == null) {
                                                  return AppLocalizations.of(
                                                    context,
                                                  )!.endHourRequired;
                                                }
                                                if (n < 1 || n > 22) {
                                                  return l10n
                                                      .mustBeBetween1And22;
                                                }
                                                return null;
                                              },

                                              controller: _startHourController,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: AppLocalizations.of(
                                                  context,
                                                )!.startHourLabel,
                                                hintText: l10n.hintStartHour,
                                                isDense: true,
                                              ),
                                              onChanged: (value) {
                                                if (_startHourController
                                                        .text
                                                        .isNotEmpty &&
                                                    int.parse(
                                                          _startHourController
                                                              .text,
                                                        ) >
                                                        22) {
                                                  _startHourController.clear();
                                                }
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // End hour — original logic preserved
                                          Expanded(
                                            child: TextFormField(
                                              key: _endHourKey,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return AppLocalizations.of(
                                                    context,
                                                  )!.endHourRequired;
                                                }
                                                final n = int.tryParse(value);
                                                if (n == null) {
                                                  return l10n.enterWholeNumber;
                                                }
                                                if (n > 23) {
                                                  return l10n.cannotExceed23;
                                                }
                                                if (_startHourController
                                                        .text
                                                        .isNotEmpty &&
                                                    n <=
                                                        int.parse(
                                                          _startHourController
                                                              .text,
                                                        )) {
                                                  return l10n
                                                      .mustBeAfterStartHour;
                                                }
                                                return null;
                                              },
                                              controller: _endHourController,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: l10n.endHourLabel,
                                                hintText: l10n.hintEndHour,
                                                isDense: true,
                                              ),
                                              onChanged: (value) {
                                                if (_endHourController
                                                        .text
                                                        .isNotEmpty &&
                                                    int.parse(
                                                          _endHourController
                                                              .text,
                                                        ) >
                                                        23) {
                                                  _endHourController.clear();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.timeslotsFormula,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8A9BB5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Max Hours ─────────────────────────────────────
                                _sectionCard(
                                  title: l10n.maxHoursPerStudentPerDay,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.maxHoursPerDayHint,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF5A6A85),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          return DropdownMenuFormField(
                                            key: _maxHoursKey,
                                            controller: _maxHoursController,
                                            validator: (value) {
                                              if (value == null || value <= 0) {
                                                return l10n
                                                    .pleaseSelectValidValue;
                                              }
                                              return null;
                                            },
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],

                                            dropdownMenuEntries: _hours.map((
                                              hour,
                                            ) {
                                              return DropdownMenuEntry(
                                                label: '$hour',
                                                value: hour,
                                              );
                                            }).toList(),
                                            onSelected: (value) {
                                              ref
                                                  .read(
                                                    settingsProvider.notifier,
                                                  )
                                                  .setMaxHoursPerDay(
                                                    value ?? 0,
                                                  );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Break Hours ───────────────────────────────────
                                _sectionCard(
                                  title: l10n.breakHoursTitle,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.breakHoursHint,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF5A6A85),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      DropdownButton(
                                        hint: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.addABreakHour,
                                        ),
                                        underline: Container(
                                          height: 1,
                                          color: const Color(0xFFDDE3EC),
                                        ),
                                        items: _breakHours.map((hour) {
                                          return DropdownMenuItem(
                                            value: hour,
                                            child: Text(hour.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value == null) return;
                                          //------------------------------- Check if start and end hours are selected
                                          if (_startHourController
                                                  .text
                                                  .isEmpty ||
                                              _endHourController.text.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.pleaseSelectStartAndEndHoursFirst,
                                                ),
                                              ),
                                            );

                                            return;
                                          }
                                          //------------------------------- Check if break hour is after start hour
                                          if (value <
                                              int.parse(
                                                _startHourController.text,
                                              )) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.breakHourMustBeAfterStartHour,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          //------------------------------- Check if break hour is before end hour
                                          if (value >
                                              (int.parse(
                                                    _endHourController.text,
                                                  ) -
                                                  1)) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10n.breakHourMustBeBeforeEndHour,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          ref
                                              .read(settingsProvider.notifier)
                                              .addBreakHour(value);
                                        },
                                      ),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final breakHoursPerDay = ref.watch(
                                            settingsProvider.select(
                                              (s) => s.breakHoursPerDay,
                                            ),
                                          );
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (breakHoursPerDay.isNotEmpty)
                                                Wrap(
                                                  spacing: 6,
                                                  runSpacing: 4,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    Text(
                                                      l10n.breakSlots,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Color(
                                                          0xFF5A6A85,
                                                        ),
                                                      ),
                                                    ),
                                                    for (var breakHour
                                                        in breakHoursPerDay)
                                                      Chip(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFFE8F0FE,
                                                            ),
                                                        side: const BorderSide(
                                                          color: Color(
                                                            0xFFADC8FF,
                                                          ),
                                                        ),
                                                        label: Text(
                                                          '$breakHour:00',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                  0xFF1A2E4A,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                        onDeleted: () {
                                                          ref
                                                              .read(
                                                                settingsProvider
                                                                    .notifier,
                                                              )
                                                              .removeBreakHour(
                                                                breakHour,
                                                              );
                                                        },
                                                        deleteIconColor:
                                                            const Color(
                                                              0xFF1A2E4A,
                                                            ),
                                                      ),
                                                  ],
                                                )
                                              else
                                                Text(
                                                  l10n.noBreakHoursSelected,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF8A9BB5),
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Edit Specific Day Slots ───────────────────────
                                _sectionCard(
                                  title: l10n.editSpecificDaySlots,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.clickDayToManageSlots,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF5A6A85),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final selectedDays = ref.watch(
                                            settingsProvider.select(
                                              (s) => s.selectedDays,
                                            ),
                                          );
                                          if (selectedDays.isEmpty) {
                                            return Text(
                                              l10n.noDaysSelected,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF8A9BB5),
                                              ),
                                            );
                                          }
                                          return Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: selectedDays.map((day) {
                                              return InkWell(
                                                onTap: () {
                                                  if (_startHourController
                                                          .text
                                                          .isEmpty ||
                                                      _endHourController
                                                          .text
                                                          .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          l10n.pleaseSelectStartAndEndHoursFirst,
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    final startTime = int.parse(
                                                      _startHourController.text,
                                                    );
                                                    final endTime = int.parse(
                                                      _endHourController.text,
                                                    );
                                                    ref
                                                        .read(
                                                          settingsProvider
                                                              .notifier,
                                                        )
                                                        .updateDaySettings(
                                                          startTime: startTime,
                                                          timeslotsPerDay:
                                                              (endTime + 1) -
                                                              startTime,
                                                          selectedDayId:
                                                              int.parse(day) -
                                                              1,
                                                        );
                                                    if (!overlayController
                                                        .isShowing) {
                                                      overlayController
                                                          .toggle();
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFADC8FF,
                                                      ),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color(
                                                          0x0A000000,
                                                        ),
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    '${days[int.parse(day) - 1]} ',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF2A6FDB),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // ── RadioGroup for small screens (width < 1000) ──────────────────
                                Visibility(
                                  visible:
                                      MediaQuery.of(context).size.width < 1000,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      right: 20,
                                      left: 24,
                                    ),
                                    child: PrioritizeStudentTeacher(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Right Column — Summary ────────────────────────────────
                      Visibility(
                        visible: MediaQuery.of(context).size.width >= 1000,
                        child: Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(5, 16, 24, 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFDDE3EC),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEEF3FB),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.scheduleSummary,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2A4A7F),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: _ScheduleSummary(
                                        startHourController:
                                            _startHourController,
                                        endHourController: _endHourController,
                                        daysMap: daysMap,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PrioritizeStudentTeacher(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: AppLocalizations.of(context)?.nextStageTooltip ?? 'Next stage',
        elevation: 4,
        backgroundColor: const Color(0xFF2A6FDB),
        foregroundColor: Colors.white,
        onPressed: () {
          final selectedDays = ref.read(settingsProvider).selectedDays;
          if (selectedDays.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.pleaseSelectAtLeastOneWorkingD,
                ),
                backgroundColor: Color(0xFFD94040),
              ),
            );
            return;
          }
          if (_formKey.currentState!.validate()) {
            // ── update timeslots — original logic unchanged ──
            if (_startHourController.text.isNotEmpty &&
                _endHourController.text.isNotEmpty) {
              ref
                  .read(settingsProvider.notifier)
                  .setTimeslotsPerDay(
                    (int.parse(_endHourController.text) + 1) -
                        int.parse(_startHourController.text),
                  );
              ref
                  .read(settingsProvider.notifier)
                  .setStartTime(int.parse(_startHourController.text));
              ref
                  .read(settingsProvider.notifier)
                  .setMinutesList(
                    (int.parse(_endHourController.text) + 1) -
                        int.parse(_startHourController.text),
                  );
            }
            //------------------------------------------------- Save in Shared Prefs
            prefs.setInt('startTime', int.parse(_startHourController.text));
            prefs.setInt('endTime', int.parse(_endHourController.text));
            prefs.setInt('maxHours', int.parse(_maxHoursController.text));
            prefs.setStringList('selectedDays', selectedDays);

            context.go('/create/schedule_second_page');
          } else {
            if (_startHourKey.currentState?.hasError == true) {
              Scrollable.ensureVisible(
                _startHourKey.currentContext!,
                alignment: 0.1,
                duration: const Duration(milliseconds: 300),
              );
            } else if (_endHourKey.currentState?.hasError == true) {
              Scrollable.ensureVisible(
                _endHourKey.currentContext!,
                alignment: 0.1,
                duration: const Duration(milliseconds: 300),
              );
            } else if (_maxHoursKey.currentState?.hasError == true) {
              Scrollable.ensureVisible(
                _maxHoursKey.currentContext!,
                alignment: 0.1,
                duration: const Duration(milliseconds: 300),
              );
            }
          }
        },
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          AppLocalizations.of(context)?.nextLabel ?? 'Next',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ScheduleSummary extends ConsumerWidget {
  const _ScheduleSummary({
    required this.startHourController,

    required this.daysMap,
    required this.endHourController,
  });
  final TextEditingController startHourController;
  final TextEditingController endHourController;
  final Map<String, String> daysMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch specific fields to avoid unnecessary rebuilds of the summary
    final daysPerWeek = ref.watch(
      settingsProvider.select((s) => s.daysPerWeek),
    );
    final maxHours = ref.watch(
      settingsProvider.select((s) => s.maxHoursPerDay),
    );
    final breakHours = ref.watch(
      settingsProvider.select((s) => s.breakHoursPerDay),
    );
    final selectedDays = ref.watch(
      settingsProvider.select((s) => s.selectedDays),
    );

    return Column(
      children: [
        _summaryRow(
          AppLocalizations.of(context)?.summaryDaysPerWeek ?? 'Days per week',
          '$daysPerWeek',
        ),
        const Divider(height: 12),
        _summaryRow(
          AppLocalizations.of(context)?.summaryTimeslotsPerDay ??
              'Timeslots / day',
          endHourController.text.isNotEmpty &&
                  startHourController.text.isNotEmpty
              ? '${int.parse(endHourController.text) - int.parse(startHourController.text)}'
              : '0',
        ),
        const Divider(height: 12),
        _summaryRow(
          AppLocalizations.of(context)?.summaryMaxHoursPerDay ??
              'Max hours / day',
          '$maxHours',
        ),
        const Divider(height: 12),
        _summaryRow(
          AppLocalizations.of(context)?.summaryBreakHours ?? 'Break hours',
          breakHours.isEmpty ? '—' : breakHours.map((h) => '$h:00').join(', '),
        ),
        const Divider(height: 12),
        _summaryRow(
          AppLocalizations.of(context)?.summarySelectedDays ?? 'Selected days',
          selectedDays.isEmpty
              ? '—'
              : daysMap.entries
                    .where((entry) => selectedDays.contains(entry.value))
                    .map((entry) => entry.key)
                    .join(', '),
        ),
      ],
    );
  }
}

Future<void> _initialDialog(
  BuildContext context,
  WidgetRef ref,
  SharedPreferencesService prefs,
) {
  final isTimingConstraintsPage =
      context.widget is TimingConstraintsPage ||
      context.findAncestorWidgetOfExactType<TimingConstraintsPage>() != null;
  if (!isTimingConstraintsPage) {
    return Future.value();
  }

  showDialog(
    context: context,
    builder: (_) {
      final l10n = AppLocalizations.of(context)!;
      return AlertDialog(
        backgroundColor: const Color(0xFFF4F7FB),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 22, 12, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF2A6FDB),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.creationOptions,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2E4A),
                ),
              ),
            ),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              color: const Color(0xFF5A6A85),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chooseHowCreate,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF5A6A85),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: CtaButton(
                    label: l10n.createSchedule,
                    icon: Icons.edit_calendar_rounded,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CtaButton(
                    label: l10n.loadLastCreatedSchedule,
                    icon: Icons.history_rounded,
                    onPressed: () async {
                      final data = await prefs.getString(
                        'last_generated_schedule',
                      );
                      if (data != null && data.isNotEmpty) {
                        // Navigate to the schedule result page with the loaded data
                        if (context.mounted) {
                          NavigationGuard.run(context, () async {
                            loadSavedScheduleAndNavigate(context, prefs);
                          });
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.noSavedScheduleFound)),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CtaButton(
                    label: l10n.loadFromFile,
                    icon: Icons.file_upload_outlined,
                    onPressed: () {
                      NavigationGuard.run(context, () async {
                        await ScheduleSerialization.importSchedule(
                          ref,
                          context,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return Future.value();
}

class PrioritizeStudentTeacher extends ConsumerWidget {
  const PrioritizeStudentTeacher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentFirst = ref.watch(
      settingsProvider.select((s) => s.prioritizeStudentTeacher),
    );
    final isLicensed = ref.watch(
      userLicenseProvider.select((state) => state.isPremium),
    );
    final user = ref.watch(userProvider);
    return RadioGroup<bool>(
      groupValue: studentFirst,
      onChanged: (bool? value) {
        if (value == null || (!isLicensed && !value)) {
          ref.read(settingsProvider.notifier).setPrioritizeStudentTeacher(true);
          return;
        }
        ref.read(settingsProvider.notifier).setPrioritizeStudentTeacher(value);
      },
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 200,

              decoration: BoxDecoration(
                color: studentFirst
                    ? Colors.blue.withAlpha(30)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey),
              ),
              child: Stack(
                children: [
                  Material(
                    type: MaterialType.transparency,
                    child: RadioListTile<bool>(
                      titleAlignment: .center,
                      title: Text(
                        AppLocalizations.of(context)?.studFirst ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(context)?.noGaps ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.teachersCoexist ??
                                        '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      value: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Stack(
              alignment: .center,
              children: [
                Container(
                  height: 200,

                  decoration: BoxDecoration(
                    color: studentFirst
                        ? Colors.grey[200]
                        : Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Stack(
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: RadioListTile<bool>(
                          enabled: isLicensed,
                          titleAlignment: .center,
                          title: Text(
                            AppLocalizations.of(context)?.teacherFirst ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.teacherBias ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.ifSubjetMultiTeachers ??
                                            '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: false,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLicensed)
                  Center(
                    child: IconButton(
                      iconSize: 100,
                      onPressed: () {
                        if (user == null) {
                          context.push('/login?from=/create');
                        } else {
                          context.push(
                            '/create/schedule_second_page/result/buy_page',
                          );
                        }
                      },
                      tooltip:
                          AppLocalizations.of(context)?.upgradeToPremium ?? '',
                      icon: Icon(Icons.lock, color: Colors.red.withAlpha(150)),
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
