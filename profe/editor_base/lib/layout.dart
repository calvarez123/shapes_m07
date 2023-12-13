import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_design.dart';
import 'layout_sidebar.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  GlobalKey<CDKAppSidebarsState> keyAppStructure = GlobalKey();

  void toggleRightSidebar() {
    final CDKAppSidebarsState? state = keyAppStructure.currentState;
    if (state != null) {
      state.setSidebarRightVisibility(!state.isSidebarRightVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    double zoomSlider = appData.getZoomNormalized();

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: theme.backgroundSecondary0,
          middle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 75,
                      child: CDKPickerSlider(
                          value: zoomSlider,
                          onChanged: (value) {
                            zoomSlider = value;
                            appData.setZoomNormalized(value);
                          })),
                  const SizedBox(width: 8),
                  Text("${appData.zoom.toStringAsFixed(0)}%",
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w400)),
                ]),
                CDKButtonIcon(
                  icon: CupertinoIcons.sidebar_right,
                  onPressed: () {
                    toggleRightSidebar();
                  },
                ),
              ]),
        ),
        child: CDKAppSidebars(
          key: keyAppStructure,
          sidebarLeftIsResizable: true,
          sidebarLeftDefaultsVisible: false,
          sidebarRightDefaultsVisible: true,
          sidebarLeft: Container(),
          sidebarRight: const LayoutSidebar(),
          sidebarRightWidth: 275,
          central: const LayoutDesign(),
        ));
  }
}
