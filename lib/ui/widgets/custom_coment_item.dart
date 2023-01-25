import 'package:flutter/material.dart';

class CustomCommentItem extends StatelessWidget {
  final String comment;
  final Function editFunction;
  final Function deleteFunction;

  const CustomCommentItem(
      {super.key,
      required this.comment,
      required this.editFunction,
      required this.deleteFunction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: ListTile(
          title: Text(
            comment,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: GestureDetector(
                      child: const Icon(Icons.edit),
                      onTap: () => editFunction()),
                ),
                Expanded(
                  child: GestureDetector(
                      child: const Icon(Icons.remove_circle),
                      onTap: () => deleteFunction()),
                ),
              ],
            ),
          )),
    );
  }
}
