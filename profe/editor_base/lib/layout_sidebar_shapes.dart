import 'package:editor_base/app_data.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme_notifier.dart';
import 'package:provider/provider.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Centra horizontalmente
          children: [
            Text('List of shapes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 700,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: appData.shapesList.length,
                itemBuilder: (context, index) {
                  Shape shape = appData.shapesList[index];
                  return GestureDetector(
                    onTap: () {
                      appData.setSelectedShapeIndex(index);
                      print("click");
                    },
                    child: Container(
                      margin: EdgeInsets.all(4.0),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color.fromARGB(255, 90, 87, 235)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${shape.position}'),
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
    ;
  }
}
