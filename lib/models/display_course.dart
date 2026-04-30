import 'course.dart';
import 'course_adjustment.dart';

/// Display model: merges a Course with its optional adjustment for a given week.
class DisplayCourse {
  final Course course;
  final int displayWeekNumber;
  final int displayDayOfWeek;
  final int displayStartSection;
  final int displaySectionCount;
  final bool isAdjusted;
  final CourseAdjustment? adjustment;

  const DisplayCourse({
    required this.course,
    required this.displayWeekNumber,
    required this.displayDayOfWeek,
    required this.displayStartSection,
    required this.displaySectionCount,
    this.isAdjusted = false,
    this.adjustment,
  });

  /// Build from a normal (non-adjusted) course occurrence.
  factory DisplayCourse.fromCourse(Course course, int weekNumber) {
    return DisplayCourse(
      course: course,
      displayWeekNumber: weekNumber,
      displayDayOfWeek: course.dayOfWeek,
      displayStartSection: course.startSection,
      displaySectionCount: course.sectionCount,
    );
  }

  /// Build from an adjustment (the course appears at a new time this week).
  factory DisplayCourse.fromAdjustment(
    Course course,
    CourseAdjustment adjustment,
  ) {
    return DisplayCourse(
      course: course,
      displayWeekNumber: adjustment.newWeekNumber ?? adjustment.originalWeekNumber,
      displayDayOfWeek: adjustment.newDayOfWeek ?? course.dayOfWeek,
      displayStartSection: adjustment.newStartSection ?? course.startSection,
      displaySectionCount: adjustment.newSectionCount ?? adjustment.originalSectionCount,
      isAdjusted: true,
      adjustment: adjustment,
    );
  }

  /// Whether this display course should show at the given week/day/section.
  bool shouldDisplayAt(int week, int day, int section) {
    return displayWeekNumber == week &&
        displayDayOfWeek == day &&
        section >= displayStartSection &&
        section < displayStartSection + displaySectionCount;
  }
}
