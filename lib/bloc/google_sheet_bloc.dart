import 'dart:async';

import '../service/google_sheet_service.dart';

GoogleSheetBloc googleSheetBloc =
    GoogleSheetBloc(googleSheetService: googleSheetService);

class GoogleSheetBloc {
  GoogleSheetBloc({
    required this.googleSheetService,
  });

  final GoogleSheetService googleSheetService;
  List<String> listCoursesAdd = [];
  List<String> courseList = [];
  Map<String, dynamic> originalCheckedCourses = {};
  List<int> checkedCourses = [];
  List<int> uncheckedList = [];
  String columnLabel = '';

  final _controllerListCourse = StreamController<List<String>>.broadcast();
  Stream<List<String>> get streamListCourse => _controllerListCourse.stream;

  Future<void> getAllCourses() async {
    Map<String, dynamic>? generalInfo =
        await googleSheetService.getAllSheetData();

    courseList = generalInfo!['courseList'];
    checkedCourses = generalInfo['checkedCourses'];
    columnLabel = generalInfo['columnLabel'];

    _controllerListCourse.add(courseList);
  }

  Future<void> saveListCourses(int index) async {
    if (checkedCourses.contains(index)) {
      checkedCourses.remove(index);
      uncheckedList.add(index);
    } else {
      checkedCourses.add(index);
      if (uncheckedList.contains(index)) {
        uncheckedList.remove(index);
      }
    }
  }

  Future<void> saveCoursesGsheets() async {
    bool response = await googleSheetService.updateCoursesbyUser(
        checkedCourses, uncheckedList, columnLabel);
    if (response) {
      uncheckedList = [];
    }
  }

  bool checkCourse(int index) {
    return checkedCourses.contains(index);
  }
}
