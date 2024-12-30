import 'package:flutter/material.dart';

Future<void> showSavingPopup(BuildContext context, String initialFileName, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      bool saveACopy = false;
      TextEditingController fileNameController = TextEditingController(text: initialFileName);

      return AlertDialog(
        title: const Text('Save File'),
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: ListBody(children: <Widget>[
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                direction: Axis.horizontal,
                children: [
                  TextField(
                    controller: fileNameController,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'File Name',
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    dense: true,
                    title: const Text("Save a copy?"),
                    value: saveACopy,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          saveACopy = value;
                        }
                      });
                    },
                  )
                ],
              )
            ]),
          );
        }),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Save file'),
            onPressed: () {
              onUpdate(saveACopy, fileNameController.text);
            },
          ),
        ],
      );
    },
  );
}
