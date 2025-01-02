import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showCropImagePopup(
    BuildContext context, XFile imageFile, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return const Text("hello");
        }),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Update'),
            onPressed: () {
              onUpdate();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
