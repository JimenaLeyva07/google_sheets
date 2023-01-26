import 'dart:async';

import 'package:local_flutter_login_google/model/courses_model.dart';

import '../model/user_model.dart';
import '../service/google_sheet_service.dart';
import '../service/shared_preferences_service.dart';

GoogleSheetBloc googleSheetBloc = GoogleSheetBloc(
    googleSheetService: googleSheetService,
    sharedPreferencesService: sharedPreferencesService);

/// Class for getting and deleting users in a user list
class GoogleSheetBloc {
  GoogleSheetBloc(
      {required this.sharedPreferencesService,
      required this.googleSheetService,});

  final GoogleSheetService googleSheetService;
  final SharedPreferencesService sharedPreferencesService;
  List<String> listCoursesAdd=[]; 

  final _controllerListCourse = StreamController<List<Coursers>>.broadcast();
  Stream<List<Coursers>> get streamListCourse => _controllerListCourse.stream;


  ///Function for getting all users
  Future<void> getAllCourses() async {
    List<Coursers>? listCourses = await googleSheetService.getAllCourses();
    _controllerListCourse.add(listCourses!);    
  }

  ///Function for getting all users
  Future<void> saveListCourses(String course) async {

    if(listCoursesAdd.contains(course)){
       listCoursesAdd.remove(course);
    }else{
      listCoursesAdd.add(course);
    }
  }


  void saveCoursesGsheets() {
    print(listCoursesAdd);
  }

  void saveUserInfo(String key, String value) {
    sharedPreferencesService.setString(key, value);
  }
}
