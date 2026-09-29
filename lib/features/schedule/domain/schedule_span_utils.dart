/// Returns how many consecutive slots starting at [index] should be
/// merged into a single lesson cell.
///
/// [length] is the total number of slots to consider (e.g. timeslots
/// per day). [matchesAnchor] should return true if the slot at
/// [index] and the slot at the given candidate index are the "same"
/// lesson (same subjectId, teacherId and roomId) and should therefore
/// be merged together.
///
/// Used by all schedule grids (on-screen tables and the PDF export)
/// so that consecutive identical lessons render as a single
/// horizontally merged cell instead of repeating the lesson in every
/// timeslot it occupies.
int mergedLessonSpan({
  required int index,
  required int length,
  required bool Function(int candidateIndex) matchesAnchor,
}) {
  var span = 1;
  while (index + span < length && matchesAnchor(index + span)) {
    span++;
  }
  return span;
}