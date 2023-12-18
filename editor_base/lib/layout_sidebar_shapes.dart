import 'package:editor_base/app_data.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme_notifier.dart';
import 'package:provider/provider.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({Key? key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('List of shapes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 500,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: appData.shapesList.length,
                itemBuilder: (context, index) {
                  Shape shape = appData.shapesList[index];
                  return GestureDetector(
                    onTap: () {
                      if (index == appData.selectedShapeIndex) {
                        appData.selectedShapeIndex = -1;
                      } else {
                        appData.selectShape(index);
                      }
                      appData.notifyListeners();
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightBlueAccent),
                        color: index == appData.selectedShapeIndex
                            ? Colors.lightBlueAccent
                            : Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4.0,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${shape.position}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
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
  }
}
