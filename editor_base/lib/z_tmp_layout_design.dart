import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'z_tmp_util_scroll2d.dart';

class LayoutDesign extends StatefulWidget {
  final double zoom;
  const LayoutDesign({super.key, this.zoom = 100});

  @override
  LayoutDesignState createState() => LayoutDesignState();
}

class LayoutDesignState extends State<LayoutDesign> {
  final GlobalKey _key2D = GlobalKey();
  final GlobalKey _keyCanvas = GlobalKey();
  final GlobalKey _keyLimit = GlobalKey();
  List<Offset> _positions = [];
  List<Widget> _widgets = [];

  @override
  void initState() {
    super.initState();
    _widgets = [
      Container(
          key: _keyCanvas, color: CDKTheme.green, width: 200, height: 100),
      Container(key: _keyLimit, width: 10, height: 10, color: CDKTheme.red)
    ];
  }

  @override
  Widget build(BuildContext context) {
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    return LayoutBuilder(builder: (context, constraints) {
      //double canvasWidth = 500 * widget.zoom / 100;
      //double canvasHeight = 800 * widget.zoom / 100;

      double padding = 50;
      double x = padding;
      double y = padding;
      //double width = canvasWidth;
      //double height = canvasHeight;

      // _keyCanvas.currentState?.updateWidth(width);
      // _keyCanvas.currentState?.updateHeight(height);

      double limitX = 800; // width * widget.zoom + padding * 2;
      double limitY = 800; // height * widget.zoom + padding * 2;

      _positions = [
        Offset(x, y),
        Offset(limitX, limitY),
      ];

      return Container(
          color: theme.background,
          child: UtilScroll2d(
            key: _key2D,
            positions: _positions,
            children: _widgets,
          ));
    });
  }
}
