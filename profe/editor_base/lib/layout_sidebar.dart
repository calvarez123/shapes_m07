import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'layout_sidebar_document.dart';
import 'layout_sidebar_format.dart';
import 'layout_sidebar_shapes.dart';
import 'layout_sidebar_tools.dart';
import 'util_tab_views.dart';

class LayoutSidebar extends StatelessWidget {
  const LayoutSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    Color backgroundColor = theme.backgroundSecondary2;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        color: backgroundColor,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const LayoutSidebarTools(),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.only(top: 1.0),
                height: screenHeight - 45,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                        left: BorderSide(
                            color: theme.isLight
                                ? CDKTheme.grey100
                                : CDKTheme.grey700,
                            width: 1))),
                child: UtilTabViews(isAccent: true, options: const [
                  Text('Document'),
                  Text('Format'),
                  Text('Shapes')
                ], views: const [
                  LayoutSidebarDocument(),
                  LayoutSidebarFormat(),
                  LayoutSidebarShapes(),
                ]),
              ))
            ])
          ],
        ));
  }
}
