import 'package:flutter/material.dart';

import '../../bloc/update_google_sheet_bloc.dart';
import '../../main.dart';
import '../../model/user_model.dart';
import '../../service/shared_preferences_service.dart';
import '../widgets/alerts_dialog_widget.dart';
import '../widgets/custom_coment_item.dart';
import '../widgets/text_field_custome.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  late final updateGoogleSheetBloc = UpdateGoogleSheetBloc(
      googleSheetService: MyInheritedWidget.of(context).googleSheetService);

  @override
  void initState() {
    super.initState();
    sharedPreferencesService.removeKey(widget.user.id!);
    updateGoogleSheetBloc
      ..init(widget.user)
      ..user = widget.user
      ..oldUser = widget.user.tojson(widget.user.comments)
      ..userEmailController.text = widget.user.email
      ..userNameController.text = widget.user.name
      ..streamUpdateUser.listen((String event) {
        switch (event) {
          case 'update':
            showUpdateDialog();
            break;
          case 'updated':
            showUpdatedDialog();
            break;
          case 'delete':
            showDeleteDialog();
            break;
          case 'error':
            showErrorDialog();
            break;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update User'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Form(
              key: updateGoogleSheetBloc.formKey,
              child: Column(children: [
                TextFieldCustom(
                  controller: updateGoogleSheetBloc.userNameController,
                  hintText: 'Name',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Requiere el campo name';
                    }
                    if (value.trim().isEmpty) {
                      return 'No se aceptan solo espacios';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldCustom(
                  controller: updateGoogleSheetBloc.userEmailController,
                  hintText: 'Email',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Requiere el campo email';
                    }
                    if (value.trim().isEmpty) {
                      return 'No se aceptan solo espacios';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldCustom(
                    controller: updateGoogleSheetBloc.userCommentController,
                    hintText: 'Comment',
                    validator: (value) {
                      if (value!.trim().isEmpty && value.isNotEmpty) {
                        return 'No se aceptan solo espacios';
                      }

                      if ((value.trim().isEmpty || value.isEmpty) &&
                          updateGoogleSheetBloc.isEditComment) {
                        return 'La edicion de un comentario no puede quedar vacia';
                      }
                      return null;
                    }),
                const SizedBox(
                  height: 15,
                ),
                GestureDetector(
                  onTap: () {
                    updateGoogleSheetBloc.verificationUserForUpdate();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: const Center(child: Text('Update')),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: StreamBuilder(
                stream: updateGoogleSheetBloc.streamListCommentUser,
                builder: ((context, AsyncSnapshot<List<String>> snapshot) {
                  List<String>? data = snapshot.data;
                  if (data != null) {
                    if (data.isEmpty) {
                      return const Center(
                        child: Text('No tiene comentarios'),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: ((context, index) {
                        return CustomCommentItem(
                          comment: data[index],
                          editFunction: () {
                            updateGoogleSheetBloc.editComment(
                              index,
                              data[index],
                            );
                          },
                          deleteFunction: () {
                            updateGoogleSheetBloc.deleteComment(
                              index,
                            );
                          },
                        );
                      }),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                })),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    updateGoogleSheetBloc.dispose();
    super.dispose();
  }

  Future<void> showUpdatedDialog() async {
    return AlertDialogWidget.showMyDialogSuccesed(
      context: context,
      title: 'Usuario actualizado',
      description: 'El usuario fue actualizado con exito en la hoja excel',
      action: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Future<void> showUpdateDialog() async {
    return AlertDialogWidget.showMyDialogConfirmateUpdate(
        context: context,
        title: '¡Advertencia!',
        description:
            'Alguna informacion que deseas actualizar ha sido actualizada por otro usuario ¿Desea sobreescribir la informacion?',
        allowAction: () {
          updateGoogleSheetBloc
            ..updateSameInfo = true
            ..confirmateUpdated();
        },
        dismissAction: () {
          updateGoogleSheetBloc.confirmateUpdated();

          Navigator.of(context).pop();
        });
  }

  Future<void> showErrorDialog() async {
    return AlertDialogWidget.showMyDialogFailed(
      context: context,
      title: 'Error actualizando',
      description: 'Ocurrio un error al intentar actualizar el usuario',
      action: () {
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> showDeleteDialog() async {
    return AlertDialogWidget.showMyDialogConfirmateUpdate(
        context: context,
        title: '¡Advertencia!',
        description:
            'Este usuario fue eliminado por otra persona. ¿Desea guardar tu informacion?',
        allowAction: () async {
          await updateGoogleSheetBloc.recoveryUserInfo();
        },
        dismissAction: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
  }
}
