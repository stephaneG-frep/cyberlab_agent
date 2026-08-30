import '../models/course.dart';
import 'course_content.dart';
import 'course_bash.dart';
import 'course_linux.dart';
import 'course_networking.dart';
import 'course_python.dart';
import 'course_web.dart';

/// Static library of all courses.
class CourseLibrary {
  static final List<Course> all = _buildAll();

  static List<Course> _buildAll() {
    final list = <Course>[
      ...fundamentalsCourses(),
      ...linuxCourses(),
      ...networkingCourses(),
      ...bashCourses(),
      ...pythonCourses(),
      ...webSecurityCourses(),
    ];
    return list;
  }

  static List<Course> byCategory(String category) =>
      all.where((c) => c.category == category).toList();
}
