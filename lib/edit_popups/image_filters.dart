import 'package:drawing_app/utils/default_color_filters.dart';
import 'package:flutter/material.dart';

Future<void> showImageFiltersPopup(BuildContext context, String? initialFilter, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      String? popupSelectedFilter = initialFilter;

      return AlertDialog(
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: ListBody(
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
                    .toList()),
          );
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
              onUpdate(popupSelectedFilter);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
