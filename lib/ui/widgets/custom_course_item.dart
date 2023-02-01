import 'package:flutter/material.dart';

import '../../bloc/google_sheet_bloc.dart';
import '../../main.dart';

class CoursesCustomItem extends StatefulWidget {
  final String course;
  final int index;

  CoursesCustomItem({super.key, required this.index, required this.course});

  @override
  State<CoursesCustomItem> createState() => _CoursesCustomItemState();
}

class _CoursesCustomItemState extends State<CoursesCustomItem> {
  bool isChecked = false;
  late final GoogleSheetBloc googleSheetBloc =
      MyInheritedWidget.of(context).googleSheetBloc;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.course,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        widget.course,
        style: const TextStyle(color: Colors.black),
      ),
      tileColor: widget.index % 2 == 0 ? Colors.grey[400] : Colors.white,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Checkbox(
              value: googleSheetBloc.checkCourse(widget.index),
              onChanged: (bool? value) {
                isChecked = value!;
                googleSheetBloc.saveListCourses(widget.index);
                setState(() {});
              })
        ],
      ),
    );
  }
}
