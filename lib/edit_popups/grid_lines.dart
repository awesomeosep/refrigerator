import 'package:drawing_app/utils/edited_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<void> showGridLinesPopup(
    BuildContext context, GridOptions initialGridOptions, Function onUpdate) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      Color gridColor = initialGridOptions.gridColor;
      bool showGrid = initialGridOptions.gridShowing;
      TextEditingController gridRowsController = TextEditingController(text: initialGridOptions.rows.toString());
      TextEditingController gridColumnsController = TextEditingController(text: initialGridOptions.columns.toString());
      TextEditingController gridLineWidthController = TextEditingController(text: initialGridOptions.gridLineWidth.toString());

      return AlertDialog(
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Wrap(spacing: 8.0, runSpacing: 8.0, direction: Axis.horizontal, children: [
                  CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    dense: true,
                    title: const Text('Show grid'),
                    value: showGrid,
                    onChanged: (bool? value) {
                      setState(() {
                        showGrid = !showGrid;
                      });
                    },
                  ),
                  if (showGrid)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: gridRowsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '# Rows',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: gridColumnsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '# Columns',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: gridLineWidthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Line Thickness',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                                width: 24,
                                height: 24,
                                child: Stack(children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: ExactAssetImage('assets/checkered_transparent_2.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(100)),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: gridColor,
                                      borderRadius: const BorderRadius.all(Radius.circular(100)),
                                    ),
                                  ),
                                ])),
                            const SizedBox(width: 8),
                            TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Choose a color'),
                                        content: SingleChildScrollView(
                                          child: ColorPicker(
                                              pickerColor: gridColor,
                                              onColorChanged: (color) {
                                                setState(() {
                                                  gridColor = color;
                                                  // print(popupCurrentColor2);
                                                });
                                              }),
                                        ),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: const Text('Save'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text("Change line color"))
                          ],
                        ),
                      ],
                    )
                ])
              ],
            ),
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
              int rowsParsed = int.tryParse(gridRowsController.text) ?? 1;
              int columnsParsed = int.tryParse(gridColumnsController.text) ?? 1;
              double lineWidthParsed = double.tryParse(gridLineWidthController.text) ?? 1;
              if (rowsParsed < 1) {
                rowsParsed = 1;
              }
              if (columnsParsed < 1) {
                columnsParsed = 1;
              }
              if (lineWidthParsed <= 0) {
                lineWidthParsed = 0.1;
              }
              onUpdate(rowsParsed, columnsParsed, lineWidthParsed, gridColor, showGrid);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
