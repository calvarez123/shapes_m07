import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class UtilScroll2d extends StatefulWidget {
  final List<Widget> children;
  final List<Offset> positions;

  const UtilScroll2d(
      {super.key, required this.children, required this.positions});

  @override
  UtilScroll2dState createState() => UtilScroll2dState();
}

class UtilScroll2dState extends State<UtilScroll2d> {
  final ScrollController _scrollControllerH = ScrollController();
  final ScrollController _scrollControllerV = ScrollController();

  bool _sizesAreReady = false;
  final List<Size> _sizes = [];

  void _calculateSizes() {
    _sizes.clear();
    for (int cnt = 0; cnt < widget.children.length; cnt = cnt + 1) {
      Widget item = widget.children[cnt];
      GlobalKey key = item.key as GlobalKey;
      final RenderBox renderBox =
          key.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      _sizes.add(size);
    }
    _sizesAreReady = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_sizesAreReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculateSizes());

      // First frame set sizes
      return Offstage(
          child: Stack(
              children: widget.children.map((item) {
        return Positioned(
          left: 0,
          top: 0,
          child: item,
        );
      }).toList()));
    }

    return CupertinoScrollbar(
      controller: _scrollControllerV,
      child: CupertinoScrollbar(
        controller: _scrollControllerH,
        child: TwoDimensionalView(
          positions: widget.positions,
          sizes: _sizes,
          verticalDetails: ScrollableDetails.vertical(
            controller: _scrollControllerV,
          ),
          horizontalDetails: ScrollableDetails.horizontal(
            controller: _scrollControllerH,
          ),
          diagonalDragBehavior: DiagonalDragBehavior.free,
          delegate: TwoDimensionalChildBuilderDelegate(
            maxXIndex: 0,
            maxYIndex: widget.children.length - 1,
            builder: (BuildContext context, ChildVicinity vicinity) {
              return widget.children[vicinity.yIndex];
            },
          ),
          children: widget.children,
        ),
      ),
    );
  }
}

class TwoDimensionalView extends TwoDimensionalScrollView {
  final List<Widget> children;
  final List<Offset> positions;
  final List<Size> sizes;

  const TwoDimensionalView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails,
    super.horizontalDetails,
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
    required this.children,
    required this.positions,
    required this.sizes,
  }) : super(delegate: delegate);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      positions: positions,
      sizes: sizes,
      children: children,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  final List<Widget> children;
  final List<Offset> positions;
  final List<Size> sizes;

  const TwoDimensionalGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    required this.children,
    required this.positions,
    required this.sizes,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
        horizontalOffset: horizontalOffset,
        horizontalAxisDirection: horizontalAxisDirection,
        verticalOffset: verticalOffset,
        verticalAxisDirection: verticalAxisDirection,
        mainAxis: mainAxis,
        delegate: delegate as TwoDimensionalChildBuilderDelegate,
        childManager: context as TwoDimensionalChildManager,
        cacheExtent: cacheExtent,
        clipBehavior: clipBehavior,
        children: children,
        positions: positions,
        sizes: sizes);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  List<Widget> children;
  List<Offset> positions;
  List<Size> sizes;

  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    required this.children,
    required this.positions,
    required this.sizes,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels - cacheExtent;
    final double verticalPixels = verticalOffset.pixels - cacheExtent;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    double maxX = 0;
    double maxY = 0;
    double limitX = (horizontalPixels + viewportWidth);
    double limitY = (verticalPixels + viewportHeight);
    for (int column = 0; column <= maxColumnIndex; column++) {
      for (int row = 0; row <= maxRowIndex; row++) {
        // Run code inside if only if widget is visible
        bool widgetIsVisible = false;
        Offset widgetPosition = positions[row];
        Size widgetSize = sizes[row];

        widgetIsVisible =
            (widgetPosition.dx + widgetSize.width) >= horizontalPixels &&
                (widgetPosition.dy + widgetSize.height) >= verticalPixels &&
                widgetPosition.dx <= limitX &&
                widgetPosition.dy <= limitY;

        if (widgetIsVisible) {
          final ChildVicinity vicinity =
              ChildVicinity(xIndex: column, yIndex: row);
          final RenderBox child = buildOrObtainChildFor(vicinity)!;
          child.layout(constraints.loosen());

          // Set widgets at scroll position
          Offset drawingPosition = Offset(
              widgetPosition.dx - horizontalOffset.pixels,
              widgetPosition.dy - verticalOffset.pixels);
          parentDataOf(child).layoutOffset = drawingPosition;
        }

        double tmpX = widgetPosition.dx + widgetSize.width;
        double tmpY = widgetPosition.dy + widgetSize.height;
        if (maxX < tmpX) maxX = tmpX;
        if (maxY < tmpY) maxY = tmpY;
      }
    }

    // Set the min and max scroll extents for each axis.
    final double horizontalExtent = maxX;
    horizontalOffset.applyContentDimensions(
      0,
      clampDouble(
          horizontalExtent - viewportDimension.width, 0.0, double.infinity),
    );
    final double verticalExtent = maxY;
    verticalOffset.applyContentDimensions(
      0,
      clampDouble(
          verticalExtent - viewportDimension.height, 0.0, double.infinity),
    );
    // Super class handles garbage collection too!
  }
  //per class handles garbage collection too!
}
