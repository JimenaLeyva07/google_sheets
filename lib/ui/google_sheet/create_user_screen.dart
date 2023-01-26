import 'package:flutter/material.dart';

import '../../main.dart';
import '../widgets/alerts_dialog_widget.dart';
import '../widgets/text_field_custome.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  late final bloc = MyInheritedWidget.of(context).createGoogleSheetBloc;

  @override
  void initState() {
    super.initState();
    bloc.streamCreateUser.listen((wasCreate) {
      if (wasCreate) {
        _showSuccessDialog();
      } else {
        _showFailureDialog();
      }
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Cursos'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Form(
          key: bloc.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFieldCustom(
                key: const Key('test1'),
                controller: bloc.userNameController,
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
                controller: bloc.userEmailController,
                hintText: 'Email',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Requiere el campo email';
                  }
                  if (value.trim().isEmpty) {
                    return 'No se aceptan solo espacios';
                  }

                  if (!value.contains('@') || !value.contains('.com')) {
                    return 'Correo no valido';
                  }

                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFieldCustom(
                controller: bloc.userCommentController,
                hintText: 'Comment',
                validator: (value) {
                  if (value!.trim().isEmpty && value.isNotEmpty) {
                    return 'No se aceptan solo espacios';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  bloc.createUser();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: const Center(child: Text('Save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSuccessDialog() async {
    return AlertDialogWidget.showMyDialogSuccesed(
      context: context,
      title: 'Usuario creado',
      description: 'El usuario fue creado con exito en la hoja excel',
      action: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Future<void> _showFailureDialog() async {
    return AlertDialogWidget.showMyDialogFailed(
      context: context,
      title: 'Error creando',
      description: 'Ocurrio un error al intentar crear el usuario',
      action: () {
        Navigator.of(context).pop();
      },
    );
  }
}
