import 'dart:async';

import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../service/google_sheet_service.dart';

final CreateGoogleSheetBloc createGoogleSheetBloc =
    CreateGoogleSheetBloc(googleSheetService: googleSheetService);

/// Class for control the creation of users
class CreateGoogleSheetBloc {
  CreateGoogleSheetBloc({required this.googleSheetService});
  final GoogleSheetService googleSheetService;

  /// Form key for user, email, comment fields
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// TextEditingController for controller TextField of user name
  final userNameController = TextEditingController();

  /// TextEditingController for controller TextField of user email
  final userEmailController = TextEditingController();

  /// TextEditingController for controller TextField of user email
  final userCommentController = TextEditingController();

  /// Stream for know when user was created or the action failed
  final _controllerCreateUser = StreamController<bool>.broadcast();
  Stream<bool> get streamCreateUser => _controllerCreateUser.stream;

  ///Function that validates the user's data and creates a new user
  Future<void> createUser() async {
    if (!formKey.currentState!.validate()) return;

    User user = User(
        name: userNameController.value.text.trimLeft(),
        email: userEmailController.value.text.trimLeft(),
        comments: [userCommentController.value.text.trimLeft()]);
    bool wasUserCreate = await googleSheetService.createUser(user);

    _controllerCreateUser.add(wasUserCreate);
  }

  void dispose() {
    userEmailController.clear();
    userNameController.clear();
  }
}
