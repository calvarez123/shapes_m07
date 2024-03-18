import 'dart:convert';
import 'dart:io';

import 'package:editor_base/ShapeDrawing.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'package:file_picker/file_picker.dart';

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({super.key});

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(const Color(0x800080FF));
  @override
  Widget build(BuildContext context) {
    _preloadedColorPicker = _buildPreloadedColorPicker();
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;
    Color backgroundColor = theme.backgroundSecondary2;

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Document properties:", style: fontBold),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: labelsWidth,
                  child: Text("Width:", style: font),
                ),
                const SizedBox(width: 4),
                Container(
                  alignment: Alignment.centerLeft,
                  width: 80,
                  child: CDKFieldNumeric(
                    value: appData.docSize.width,
                    min: 1,
                    max: 2500,
                    units: "px",
                    increment: 100,
                    decimals: 0,
                    onValueChanged: (value) {
                      appData.setDocWidth(value);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Height:", style: font),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    alignment: Alignment.centerLeft,
                    width: 80,
                    child: CDKFieldNumeric(
                      value: appData.docSize.height,
                      min: 1,
                      max: 2500,
                      units: "px",
                      increment: 100,
                      decimals: 0,
                      onValueChanged: (value) {
                        appData.setDocHeight(value);
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Background color:", style: font),
                  ),
                  const SizedBox(width: 4),
                  CDKButtonColor(
                    key: _anchorColorButton,
                    color: _valueColorNotifier.value,
                    onPressed: () {
                      _showPopoverColor(context, _anchorColorButton);
                    },
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              const SizedBox(height: 16),
              Text("Document properties:", style: fontBold),
              const SizedBox(height: 8),
              // ----------------------------- Load file------------------------
              CDKButton(
                onPressed: () async {
                  FilePickerResult? filePath =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );

                  if (filePath != null) {
                    print('Carpeta seleccionada: $filePath');
                    File file = File(filePath.files.single.path!);

                    String jsonContent = await file.readAsString();
                    List<Map<String, dynamic>> shapesMapList =
                        (jsonDecode(jsonContent) as List<dynamic>)
                            .cast<Map<String, dynamic>>();

                    // Si fromMap() espera un solo mapa, selecciona uno de shapesMapList
                    if (shapesMapList.isNotEmpty) {
                      Map<String, dynamic> shapeMap = shapesMapList.first;
                      fromMap(shapeMap);
                    }
                    // Si fromMap() espera una lista de mapas, pasa shapesMapList directamente

                    // Hacer lo que necesites con las formas cargadas (por ejemplo, asignarlas a appData.shapesList)

                    appData.notifyListeners();
                    print('Formas cargadas con éxito desde: ${file.path}');
                  }
                },
                child: const Text("Load File"),
              ),
              const SizedBox(height: 2),
              // ----------------------------- save file------------------------
              CDKButton(
                onPressed: () async {
                  List<Map<String, dynamic>> shapesMapList =
                      appData.shapesList.map((shape) => shape.toMap()).toList();

                  // Convertir la lista de mapas a una cadena JSON
                  String jsonShapes = jsonEncode(shapesMapList);
                  if (appData.saveAs == true) {
                    try {
                      File file =
                          File('${appData.savedFilepath}/documento.json');
                      await file.writeAsString(jsonShapes);

                      print('Archivo guardado con éxito en: ${file.path}');
                    } catch (e) {
                      print('Error al guardar el archivo: $e');
                    }
                  } else {
                    String? filePath =
                        await FilePicker.platform.getDirectoryPath();

                    if (filePath != null) {
                      try {
                        File file = File('$filePath/documento.json');
                        await file.writeAsString(jsonShapes);

                        print('Archivo guardado con éxito en: ${file.path}');
                        appData.saveAs = true;
                        appData.setFiledPath(filePath);
                      } catch (e) {
                        print('Error al guardar el archivo: $e');
                      }
                    }
                  }
                },
                child: Text(appData.saveAs ? "Save" : "Save As"),
              ),
              const SizedBox(height: 2),
              // ----------------------------- export svg file------------------------
              CDKButton(
                onPressed: () async {
                  String? filePath =
                      await FilePicker.platform.getDirectoryPath();

                  if (filePath != null) {
                    appData.saveAsNewFile(filePath);
                    print('Carpeta seleccionada: $filePath');
                  }
                },
                child: Text("Export as SVG"),
              ),
            ],
          );
        },
      ),
    );
  }

  _showPopoverColor(BuildContext context, GlobalKey anchorKey) {
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();
    if (anchorKey.currentContext == null) {
      // ignore: avoid_print
      print("Error: anchorKey not assigned to a widget");
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
      key: key,
      context: context,
      anchorKey: anchorKey,
      isAnimated: true,
      isTranslucent: false,
      onHide: () {},
      child: _preloadedColorPicker,
    );
  }

  Widget _buildPreloadedColorPicker() {
    AppData appData = Provider.of<AppData>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueColorNotifier,
        builder: (context, value, child) {
          return CDKPickerColor(
            color: value,
            onChanged: (color) {
              setState(() {
                _valueColorNotifier.value = color;
                appData.setBackgroundColor(color);
              });
            },
          );
        },
      ),
    );
  }
}

Shape fromMap(Map<String, dynamic> map) {
  if (map['type'] != 'shape_drawing') {
    throw Exception('Type is not a shape_drawing');
  }

  var objectMap = map['object'] as Map<String, dynamic>;
  var shape = ShapeDrawing()
    ..setPosition(Offset(objectMap['position']['dx'].toDouble(),
        objectMap['position']['dy'].toDouble()))
    ..setStrokeWidth(objectMap['strokeWidth'].toDouble())
    ..setColor(Color(objectMap['strokeColor']));

  if (objectMap['vertices'] != null) {
    var verticesList = objectMap['vertices'] as List<dynamic>;
    if (verticesList.isNotEmpty) {
      shape.vertices = verticesList.map((v) {
        if (v is Map<String, dynamic> && v['dx'] != null && v['dy'] != null) {
          return Offset(v['dx'].toDouble(), v['dy'].toDouble());
        }
        return Offset.zero; // Or any default value you prefer
      }).toList();
    }
  }

  return shape;
}
