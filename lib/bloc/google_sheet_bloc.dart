import 'dart:async';

import '../model/user_model.dart';
import '../service/google_sheet_service.dart';
import '../service/shared_preferences_service.dart';

GoogleSheetBloc googleSheetBloc = GoogleSheetBloc(
    googleSheetService: googleSheetService,
    sharedPreferencesService: sharedPreferencesService);

/// Class for getting and deleting users in a user list
class GoogleSheetBloc {
  GoogleSheetBloc({
    required this.sharedPreferencesService,
    required this.googleSheetService,
  });

  final GoogleSheetService googleSheetService;
  final SharedPreferencesService sharedPreferencesService;
  List<String> listCoursesAdd = [];
  List<String> courseList = [];
  Map<String, dynamic> originalCheckedCourses = {};
  List<int> checkedCourses = [];
  List<int> uncheckedList = [];
  String columnLabel = '';

  final _controllerListCourse = StreamController<List<String>>.broadcast();
  Stream<List<String>> get streamListCourse => _controllerListCourse.stream;

  ///Function for getting all users
  Future<void> getAllCourses() async {
    Map<String, dynamic>? generalInfo =
        await googleSheetService.getAllCourses();

    courseList = generalInfo!['courseList'];
    checkedCourses = generalInfo['checkedCourses'];
    columnLabel = generalInfo['columnLabel'];

    _controllerListCourse.add(courseList);
  }

  ///Function for getting all users
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
    bool response = await googleSheetService.updateCellUser(
        checkedCourses, uncheckedList, columnLabel);
    if (response) {
      uncheckedList = [];
    }
  }

  void saveUserInfo(String key, String value) {
    sharedPreferencesService.setString(key, value);
  }

  bool checkCourse(int index) {
    return checkedCourses.contains(index);
  }
}
