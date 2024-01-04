import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:editor_base/SidebarShapePainter.dart';
import 'package:flutter/material.dart';
import 'package:editor_base/app_data.dart';
import 'package:editor_base/util_shape.dart';
import 'package:provider/provider.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({Key? key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, _) {
        Color customAccentColor = Color.fromARGB(255, 183, 182, 182);
        double itemHeight =
            100.0; // Ajusta la altura de cada elemento de la lista según tus necesidades

        return SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'List of shapes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: appData.shapesList.length * itemHeight,
                  child: ListView.separated(
                    itemCount: appData.shapesList.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      Shape shape = appData.shapesList[index];
                      bool isSelected = index == appData.selectedShapeIndex;

                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            appData.selectedShapeIndex = -1;
                          } else {
                            appData.selectShape(index);
                          }
                          appData.notifyListeners();
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? customAccentColor
                                : Colors.transparent,
                            border: Border.all(
                              color: customAccentColor,
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Miniatura del shape
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .white, // Color de fondo de la miniatura
                                ),
                                child: CustomPaint(
                                  painter: SidebarShapePainter(shape),
                                ),
                              ),
                              // Información del shape
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Shape ${index + 1}', // Puedes personalizar el contenido aquí
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
