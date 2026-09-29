import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/domain/models_encoder.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/providers/settings_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

class DaysPortalOverlay extends ConsumerWidget {
  const DaysPortalOverlay({
    super.key,
    required this.days,
    required this.overlayController,
  });
  final OverlayPortalController overlayController;
  final List<String> days;
  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDayId = ref.watch(
      settingsProvider.select((s) => s.selectedDayId),
    );
    final selectedDays = ref.watch(
      settingsProvider.select((s) => s.selectedDays),
    );
    final startHour = ref.watch(settingsProvider.select((s) => s.startTime));

    final slotsPerDay = ref.watch(
      settingsProvider.select((s) => s.timeslotsPerDay),
    );

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Positioned(
      right: isArabic ? null : 12,
      left: isArabic ? 12 : null,
      top: 65,
      bottom: 77,
      child: RepaintBoundary(
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDDE3EC)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: 380,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        days[selectedDayId ?? 0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2E4A),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => overlayController.hide(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: selectedDays.contains('${(selectedDayId ?? 0) + 1}')
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: slotsPerDay,
                          itemExtent: 56,
                          itemBuilder: (context, index) {
                            return _TimeSlotTile(
                              hour: startHour + index,
                              dayId: selectedDayId ?? 0,
                              slotId: index + 1,
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.isNotScheduled,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSlotTile extends ConsumerWidget {
  const _TimeSlotTile({
    required this.hour,
    required this.dayId,
    required this.slotId,
  });
  final int hour;
  final int dayId;
  final int slotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      settingsProvider.select((s) {
        final override = s.dayOverrides?.firstWhere(
          (o) => o.dayId == (dayId + 1),
          orElse: () => DayOverrideEncoder(dayId + 1, [], []),
        );
        return override?.timeslots?.contains(slotId) ?? false;
      }),
    );

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        visualDensity: VisualDensity.compact,
        onTap: () {
          ref.read(settingsProvider.notifier).toggleSlot(dayId, slotId);
        },
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF3FB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$hour:00',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A4A7F),
            ),
          ),
        ),
        title: Text('$hour:00 - ${hour + 1}:00'),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (val) {
            ref.read(settingsProvider.notifier).toggleSlot(dayId, slotId);
          },
          activeColor: const Color(0xFF2A6FDB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
