import 'package:flutter/material.dart';

Future<void> showSavingPopup(BuildContext context, String initialFileName, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      bool saveACopy = false;
      TextEditingController fileNameController = TextEditingController(text: initialFileName);
      bool isLoading = false;
      final colorScheme = Theme.of(context).colorScheme;

      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: const Text('Save File'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              const Text("Save the image and edits to the app."),
              const SizedBox(height: 16),
              TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'File Name',
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                contentPadding: const EdgeInsets.all(0),
                dense: true,
                title: const Text("Save as a copy?"),
                value: saveACopy,
                onChanged: (bool? value) {
                  setState(() {
                    if (value != null) {
                      saveACopy = value;
                    }
                  });
                },
              )
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: colorScheme.inversePrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Container(),
                  isLoading ? const SizedBox(width: 16) : Container(),
                  const Text('Save'),
                ],
              ),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                onUpdate(saveACopy, fileNameController.text);
                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        );
      });
    },
  );
}
