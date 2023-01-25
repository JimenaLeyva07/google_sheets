import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/google_sheet_service.dart';
import '../service/shared_preferences_service.dart';

final UpdateGoogleSheetBloc updateGoogleSheetBloc =
    UpdateGoogleSheetBloc(googleSheetService: googleSheetService);

///Class to control all information on the user's update screen
class UpdateGoogleSheetBloc {
  UpdateGoogleSheetBloc({required this.googleSheetService});
  final IGoogleSheetService googleSheetService;

  /// Form key for user, email, comment fields
  final GlobalKey<FormState>? formKey = GlobalKey<FormState>();

  ///List to save the name of the modified field
  List<String> infoKeyChanged = [];

  ///List to save the values of the modified fields
  List<String> infoValueChanged = [];

  ///List to save the data that another user changed, to find out if he changed the same fields
  List<String> infoChanged = [];

  ///Object to store user inforation to be update
  User user = User(name: '', email: '', comments: []);

  ///Map to store the user's old information, this information is obtained when you enter the screen
  Map oldUser = {};

  /// isEditComent is used to know when the user selects to modify a comment
  bool isEditComment = false;

  /// wasChangedSameInfo is used to know when another user updated the same information as us
  bool wasChangedSameInfo = false;

  /// updateSameInfo is used to know if the user choose overwrite the information when another user updated the same information as us
  bool updateSameInfo = false;

  bool isFirstInitScreenUpdate = true;

  /// indexCommentToUpdate is used to know the index comment when the user selects to modify a comment
  int? indexCommentToUpdate;

  /// TextEditingController for controller TextField of user name
  final userNameController = TextEditingController();

  /// TextEditingController for controller TextField of user email
  final userEmailController = TextEditingController();

  /// TextEditingController for controller TextField of user comment
  final userCommentController = TextEditingController();

  /// Stream for know when user was created or the action failed
  final _controllerUpdateUser = StreamController<String>.broadcast();
  Stream<String> get streamUpdateUser => _controllerUpdateUser.stream;

  /// Stream to control the comment list, for when any comment is deleted
  final _controllerListCommentUser = StreamController<List<String>>();
  Stream<List<String>> get streamListCommentUser =>
      _controllerListCommentUser.stream;

  ///Funtion to initilizate the streams
  Future<void> init(User user) async {
    _controllerListCommentUser.add(user.comments);
    // if (isFirstInitScreenUpdate) {
    streamUpdateUser.listen((event) async {
      if (event == "confirmated") {
        await updateUser();
      }
    });
    //   isFirstInitScreenUpdate = false;
    // }
  }

  ///Funtion to changed the state to stream update user
  confirmateUpdated() {
    _controllerUpdateUser.add('confirmated');
  }

  ///Function to check if all information has changed correctly. And change the status of the stream user update with the processed information.
  Future<void> verificationUserForUpdate() async {
    if (!formKey!.currentState!.validate()) return;

    user.email = userEmailController.value.text.trimLeft();
    user.name = userNameController.value.text.trimLeft();

    if (isEditComment) {
      user.comments[indexCommentToUpdate!] =
          userCommentController.value.text.trimLeft();
    } else if (userCommentController.value.text != "") {
      user.comments.add(userCommentController.value.text.trimLeft());
    }

    Map mapNewUser = user.tojson(user.comments);

    mapNewUser.forEach((key, value) {
      if (value != oldUser[key]) {
        infoKeyChanged.add(key);
        infoValueChanged.add(value);
      }
    });

    Map validation = {"id": user.id, "index": user.indexRow};
    String userPreferences = sharedPreferencesService.getString(user.id);
    Map allInfoUserModifed = {};

    if (userPreferences.isNotEmpty) {
      allInfoUserModifed = jsonDecode(userPreferences);
      for (String info in allInfoUserModifed['columnsChanged']) {
        if (infoKeyChanged.contains(info)) {
          wasChangedSameInfo = true;
          infoChanged.add(info);
        }
      }
    }

    if (userPreferences.isNotEmpty &&
        mapEquals(validation, allInfoUserModifed["user"]) &&
        allInfoUserModifed['action'] == 'delete') {
      _controllerUpdateUser.add('delete');
    } else if (userPreferences.isNotEmpty &&
        mapEquals(validation, allInfoUserModifed["user"]) &&
        allInfoUserModifed['action'] == 'update' &&
        wasChangedSameInfo) {
      _controllerUpdateUser.add('update');
    } else if (infoKeyChanged.isEmpty) {
    } else {
      _controllerUpdateUser.add('confirmated');
    }
  }

  ///Funtion to be called when all information is correct to save
  Future<void> updateUser() async {
    bool wasUserCreate = false;
    if (wasChangedSameInfo && updateSameInfo) {
      wasUserCreate = await googleSheetService.updateCellUser(
          user.id!, infoKeyChanged, infoValueChanged, user.indexRow!);
    } else {
      for (String element in infoChanged) {
        int indexInfo = infoKeyChanged.indexOf(element);

        infoKeyChanged.removeAt(indexInfo);
        infoValueChanged.removeAt(indexInfo);
      }

      wasUserCreate = await googleSheetService.updateCellUser(
          user.id!, infoKeyChanged, infoValueChanged, user.indexRow!);
    }

    if (wasUserCreate) {
      _controllerUpdateUser.add('updated');
    } else {
      _controllerUpdateUser.add('error');
    }
  }

  ///Function for notify that the user wants changed a comment
  editComment(int index, String comment) {
    isEditComment = true;
    indexCommentToUpdate = index;
    userCommentController.text = comment;
  }

  ///Function to delete a comment of list
  deleteComment(int index) {
    user.comments.removeAt(index);
    _controllerListCommentUser.add(user.comments);
  }

  ///Function to recovery the information when the user was delete
  Future<void> recoveryUserInfo() async {
    bool wasUserCreate = await googleSheetService.createUser(user);
    if (wasUserCreate) {
      _controllerUpdateUser.add('updated');
    } else {
      _controllerUpdateUser.add('error');
    }
  }

  void dispose() {
    userEmailController.clear();
    userNameController.clear();
    _controllerListCommentUser.close();
    // _controllerUpdateUser.close();
  }
}
