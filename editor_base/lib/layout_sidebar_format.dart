import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarFormat extends StatefulWidget {
  const LayoutSidebarFormat({super.key});

  @override
  LayoutSidebarFormatState createState() => LayoutSidebarFormatState();
}

class LayoutSidebarFormatState extends State<LayoutSidebarFormat> {
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverArrowedState> _anchorColorButton =
      GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(Color.fromARGB(128, 255, 255, 255));

  late Widget _preloadedFillColorPicker;

  final ValueNotifier<Color> _valueFillColorNotifier =
      ValueNotifier(Color.fromARGB(128, 255, 255, 255));

  final GlobalKey<CDKDialogPopoverArrowedState> _anchorFillColorButton =
      GlobalKey();

  late AppData appData;

  @override
  Widget build(BuildContext context) {
    appData = Provider.of<AppData>(context);
    _preloadedColorPicker = _buildPreloadedColorPicker();
    _preloadedFillColorPicker = _buildPreloadedFillColorPicker();

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
              Text("Stroke and fill:", style: fontBold),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: labelsWidth,
                  child: Text("Stroke width:", style: font),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CDKFieldNumeric(
                        value: appData.strokeWidth,
                        min: 1,
                        max: 100,
                        units: "px",
                        decimals: 0,
                        onValueChanged: (value) {
                          appData.setStrokeWidth(value);
                        },
                      ),
                    ],
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
                    child: Text("Stroke color:", style: font),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CDKButtonColor(
                          key: _anchorColorButton,
                          color: appData.color1,
                          onPressed: () {
                            _showPopoverColor(context, _anchorColorButton);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Enable Feature:", style: font),
                  ),
                  const SizedBox(width: 4),
                  CDKButtonCheckBox(
                    value: appData.isSwitched,
                    onChanged: (bool value) {
                      setState(() {
                        appData.setClosedSelectShape(value);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    width: labelsWidth,
                    child: Text("Fill color:", style: font),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CDKButtonColor(
                          key: _anchorFillColorButton,
                          color: appData.fillcolor,
                          onPressed: () {
                            _showPopoverFillColor(
                                context, _anchorFillColorButton);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Nueva sección para mostrar las coordenadas
              _buildCoordinatesSection(),
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
      onHide: () {
        appData.hide = true;
        appData.setSelectedColor(_valueColorNotifier.value);
      },
      child: _preloadedColorPicker,
    );
  }

  Widget _buildCoordinatesSection() {
    // Mostrar la sección solo si hay un shape seleccionado
    if (appData.selectedShapeIndex != -1) {
      Shape selectedShape = appData.shapesList[appData.selectedShapeIndex];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Coordinates:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerRight,
                width: 100, // Ancho para el label "Offset X"
                child: const Text("Offset X:", style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 4),
              Text("${selectedShape.position.dx.toStringAsFixed(2)}px",
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerRight,
                width: 100, // Ancho para el label "Offset Y"
                child: const Text("Offset Y:", style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 4),
              Text("${selectedShape.position.dy.toStringAsFixed(2)}px",
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    } else {
      // Si no hay shape seleccionado, mostrar la sección desactivada
      return Opacity(
        opacity: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Coordinates:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: 100,
                  child:
                      const Text("Offset X:", style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 4),
                const Text("N/A", style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  width: 100,
                  child:
                      const Text("Offset Y:", style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 4),
                const Text("N/A", style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }
  }

  Widget _buildPreloadedColorPicker() {
    AppData appData = Provider.of<AppData>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueColorNotifier,
        builder: (context, value, child) {
          // Inicializar el color con la opacidad máxima
          Color initialColor = Color.fromARGB(255, 255, 255, 255);
          _preloadedColorPicker = CDKPickerColor(
            color: initialColor,
            onChanged: (color) {
              setState(() {
                _valueColorNotifier.value = color;
                appData.setSelectedColor(color);
              });
            },
          );
          return _preloadedColorPicker;
        },
      ),
    );
  }

  Widget _buildPreloadedFillColorPicker() {
    AppData appData = Provider.of<AppData>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueFillColorNotifier,
        builder: (context, value, child) {
          // Inicializar el color con la opacidad máxima
          Color initialColor = Color.fromARGB(255, 255, 255, 255);
          _preloadedFillColorPicker = CDKPickerColor(
            color: initialColor,
            onChanged: (color) {
              setState(() {
                _valueFillColorNotifier.value = color;
                appData.setSelectedFillColor(color);
              });
            },
          );
          return _preloadedFillColorPicker;
        },
      ),
    );
  }

  _showPopoverFillColor(BuildContext context, GlobalKey anchorKey) {
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
      child: _preloadedFillColorPicker,
    );
  }
}
