import 'package:editor_base/layout_design_painter.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_sidebar_tools.dart';
import 'util_tab_views.dart';

class LayoutSidebarRight extends StatelessWidget {
  const LayoutSidebarRight({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    Color backgroundColor = theme.backgroundSecondary2;
    double screenHeight = MediaQuery.of(context).size.height;

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
        color: backgroundColor,
        child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(top: 1.0),
                  height: screenHeight - 45,
                  color: backgroundColor,
                  child: UtilTabViews(
                    isAccent: true,
                    options: const [
                      Text('Document'),
                      Text('Format'),
                      Text('Shapes')
                    ],
                    views: [
                      SizedBox(
                        width:
                            double.infinity, // Estira el widget horitzontalment
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Document dimensions:", style: fontBold),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text("Width:", style: font),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                        width: 80,
                                        child: CDKFieldNumeric(
                                          value: appData.docSize.width,
                                          min: 100,
                                          max: 2500,
                                          units: "px",
                                          increment: 100,
                                          decimals: 0,
                                          onValueChanged: (value) {
                                            appData.setDocWidth(value);
                                          },
                                        )),
                                    Expanded(child: Container()),
                                    Text("Height:", style: font),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                        width: 80,
                                        child: CDKFieldNumeric(
                                          value: appData.docSize.height,
                                          min: 100,
                                          max: 2500,
                                          units: "px",
                                          increment: 100,
                                          decimals: 0,
                                          onValueChanged: (value) {
                                            appData.setDocHeight(value);
                                          },
                                        ))
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ]),
                        ),
                      ),
                      SizedBox(
                        width:
                            double.infinity, // Estira el widget horitzontalment
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const LayoutSidebarTools(),
                              Expanded(
                                child: Container(),
                              )
                            ]),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Centra horizontalmente
                            children: [
                              Text('List of shapes',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(
                                height: 700,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: appData.shapesList.length,
                                  itemBuilder: (context, index) {
                                    Shape shape = appData.shapesList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // Actualiza el shape seleccionado cuando se toca un elemento en la lista
                                        appData.selectShape(index);
                                        // Actualiza el estado para redibujar con el nuevo shape seleccionado
                                        appData.notifyListeners();
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(4.0),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  255, 90, 87, 235)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('${shape.position}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              CustomPaint(
                                painter: LayoutDesignPainter(
                                    appData: appData, theme: theme),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ))
            ]));
  }
}
