import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/features/schedule/data/schedule_api.dart';
import 'package:segdude_app/features/schedule/presentation/pages/schedule_create/schedule_generator.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

const _blue = Color(0xFF2A6FDB);
const _divider = Color(0xFFDDE3EC);
const _textPrimary = Color(0xFF1A2E4A);
const _textSecondary = Color(0xFF5A6A85);
const _errorRed = Color(0xFFD94040);
const _progressBackground = Color(0xFFE8EEF8);

/// How long each status message is shown before rotating to the next one.
const _messageRotationInterval = Duration(seconds: 3);

/// Progress bar ticks — smoother animation at 60 ms intervals.
const _progressTickInterval = Duration(milliseconds: 60);

/// The progress bar stops advancing at this fraction and waits for the server.
const double _progressCap = 0.95;

class WhileGenerating extends ConsumerStatefulWidget {
  const WhileGenerating({super.key});

  @override
  ConsumerState<WhileGenerating> createState() => _WhileGeneratingState();
}

class _WhileGeneratingState extends ConsumerState<WhileGenerating> {
  double _progress = 0.0;
  int _messageIndex = 0;

  Timer? _progressTimer;
  Timer? _messageTimer;

  /// The estimated duration that was active when the timers were last started.
  /// Used to detect when the provider changes so we can restart with fresh
  /// values (e.g. a new generation is kicked off while the widget is mounted).
  int _timerEstimate = -1;

  @override
  void initState() {
    super.initState();
    _timerEstimate = ref.read(estimatedSecondsProvider);
    _resetAndStart(_timerEstimate);
  }

  void _resetAndStart(int estimatedSeconds) {
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    setState(() {
      _progress = 0.0;
      _messageIndex = 0;
    });

    // -----------------------------------------------------------------------
    // Progress timer
    //
    // Each tick advances the bar by a fraction proportional to the estimated
    // duration. The bar slows as it approaches _progressCap and never exceeds
    // it — it simply waits there until the server call resolves and the widget
    // is removed from the tree.
    // -----------------------------------------------------------------------
    if (estimatedSeconds > 0) {
      final double ticksTotal =
          estimatedSeconds * 1000 / _progressTickInterval.inMilliseconds;
      final double incrementPerTick = _progressCap / ticksTotal;
      _progressTimer = Timer.periodic(_progressTickInterval, (_) {
        if (!mounted) return;
        setState(() {
          _progress = (_progress + incrementPerTick).clamp(0.0, _progressCap);
        });
      });
    }

    // -----------------------------------------------------------------------
    // Message rotation timer — independent of progress.
    // -----------------------------------------------------------------------
    _messageTimer = Timer.periodic(_messageRotationInterval, (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final messages = _statusMessages(l10n);
      setState(() {
        _messageIndex = (_messageIndex + 1) % messages.length;
      });
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _messageTimer?.cancel();
    super.dispose();
  }

  /// Returns the localised list of rotating status messages.
  List<String> _statusMessages(AppLocalizations l10n) => [
    l10n.generatingStatusInitializing,
    l10n.generatingStatusEvaluating,
    l10n.generatingStatusSearching,
    l10n.generatingStatusOptimizing,
    l10n.generatingStatusFinalizing,
  ];

  /// Formats a duration in seconds as "X min Y sec" or just "Y sec".
  String _formatSeconds(int seconds, AppLocalizations l10n) {
    if (seconds <= 0) return '';
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    if (minutes > 0) {
      return l10n.estimatedTimeMinSec(minutes, secs);
    }
    return l10n.estimatedTimeSec(secs);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(estimatedSecondsProvider, (previous, next) {
      if (next != _timerEstimate) {
        _timerEstimate = next;
        _resetAndStart(next);
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final estimatedSeconds = ref.watch(estimatedSecondsProvider);
    final messages = _statusMessages(l10n);
    final currentMessage = messages[_messageIndex % messages.length];
    final hasEstimate = estimatedSeconds > 0;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -----------------------------------------------------------------
              // Title
              // -----------------------------------------------------------------
              Text(
                l10n.whileGeneratingTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),

              // -----------------------------------------------------------------
              // Estimated time — prominent badge, shown right under the title so
              // it's the first thing the user notices.
              // -----------------------------------------------------------------
              if (hasEstimate) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _blue.withAlpha(8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: _blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.estimatedTime(
                          _formatSeconds(estimatedSeconds, l10n),
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // -----------------------------------------------------------------
              // Progress bar
              // -----------------------------------------------------------------
              _ProgressSection(progress: _progress, hasEstimate: hasEstimate),
              const SizedBox(height: 16),

              // -----------------------------------------------------------------
              // Rotating status message
              // -----------------------------------------------------------------
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  currentMessage,
                  key: ValueKey<int>(_messageIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _blue,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // -----------------------------------------------------------------
              // Static description
              // -----------------------------------------------------------------
              Text(
                l10n.whileGeneratingDescription,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // -----------------------------------------------------------------
              // Warning
              // -----------------------------------------------------------------
              const SizedBox(height: 24),

              // -----------------------------------------------------------------
              // Cancel button — unchanged behaviour
              // -----------------------------------------------------------------
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(isGeneratingProvider.notifier).state = false;
                  ref.read(estimatedSecondsProvider.notifier).state = 0;
                  ScheduleApi().dispose();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _errorRed,
                  side: const BorderSide(color: _errorRed),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  l10n.cancel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar widget
// ---------------------------------------------------------------------------

/// Renders either a determinate progress bar (when an estimate is available)
/// or a linear indeterminate indicator as a graceful fallback.
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress, required this.hasEstimate});

  final double progress;
  final bool hasEstimate;

  @override
  Widget build(BuildContext context) {
    if (!hasEstimate) {
      // Fallback: indeterminate bar, same look as the original spinner.
      return const LinearProgressIndicator(
        color: _blue,
        backgroundColor: _progressBackground,
        minHeight: 6,
        borderRadius: BorderRadius.all(Radius.circular(3)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            color: _blue,
            backgroundColor: _progressBackground,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            color: _textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
