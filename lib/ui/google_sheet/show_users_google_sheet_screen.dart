

import 'package:flutter/material.dart';
import 'package:local_flutter_login_google/model/courses_model.dart';

import '../../bloc/google_sheet_bloc.dart';
import '../../main.dart';
import '../widgets/custom_course_item.dart';

class ShowUsersGoogleSheetScreen extends StatefulWidget {
  const ShowUsersGoogleSheetScreen({Key? key}) : super(key: key);

  @override
  State<ShowUsersGoogleSheetScreen> createState() =>
      _ShowUsersGoogleSheetScreenState();
}

class _ShowUsersGoogleSheetScreenState
    extends State<ShowUsersGoogleSheetScreen> {
  late final GoogleSheetBloc googleSheetBloc =
      MyInheritedWidget.of(context).googleSheetBloc;

  @override
  void initState() {
    super.initState();

    googleSheetBloc.getAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {googleSheetBloc.saveCoursesGsheets();},
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Container(
                margin: const EdgeInsets.symmetric(
                horizontal: 35.0, vertical: 10.0),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(
                  color: Colors.green,                  
                ),
                child: const Center(child: Text('Guardar')),
              ),
            ),
          ),
          StreamBuilder(
            stream: googleSheetBloc.streamListCourse,
            builder: ((context, AsyncSnapshot<List<Coursers>> snapshot) {
              if (snapshot.hasData) {
                final List<Coursers> data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Text(
                      'Actualmente no tiene datos la hoja de excel');
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return CoursesCustomItem(                            
                            course: data[index],
                            index: data[index].indexRow!,);
                      }),
                );
              }
              return const CircularProgressIndicator();
            }),
          ),
        ],
      ),
    );
  }
}
