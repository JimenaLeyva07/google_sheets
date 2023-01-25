import 'package:flutter/material.dart';

import '../../model/user_model.dart';
import '../google_sheet/update_user_screen.dart';

class UserCustomItem extends StatelessWidget {
  final User user;
  final int index;
  final Function function;
  const UserCustomItem(
      {super.key,
      required this.user,
      required this.index,
      required this.function});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        user.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      subtitle: Text(
        user.email,
        style: const TextStyle(color: Colors.black),
      ),
      tileColor: index % 2 == 0 ? Colors.grey[400] : Colors.white,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 850),
                    transitionsBuilder: (_, animation, __, child) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticOut,
                        ),
                        child: child,
                      );
                    },
                    pageBuilder: (_, animation, __) {
                      return UpdateUserScreen(
                        user: user,
                      );
                    }),
              );
            },
            icon: const Icon(Icons.edit),
            color: Colors.blue,
          ),
          IconButton(
            onPressed: () => function(),
            icon: const Icon(Icons.remove_circle),
            color: Colors.red,
          )
        ],
      ),
    );
  }
}
