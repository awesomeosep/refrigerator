import 'package:refrigerator/utils/default_color_filters.dart';
import 'package:flutter/material.dart';

Future<void> showImageFiltersPopup(BuildContext context, String? initialFilter, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      String? popupSelectedFilter = initialFilter;
      bool isLoading = false;
      final colorScheme = Theme.of(context).colorScheme;

      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(children: [
              const Text("Use one of the following filters for this image:"),
              const SizedBox(height: 16),
              Column(
                  children: defaultColorFilters
                      .map((item) => CheckboxListTile(
                            contentPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                            dense: true,
                            title: Text(item.name),
                            value: popupSelectedFilter == item.id,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  popupSelectedFilter = item.id;
                                } else {
                                  popupSelectedFilter = null;
                                }
                              });
                            },
                          ))
                      .toList())
            ]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
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
                  const Text('Update'),
                ],
              ),
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                onUpdate(popupSelectedFilter);
                setState(() {
                  isLoading = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
    },
  );
}
