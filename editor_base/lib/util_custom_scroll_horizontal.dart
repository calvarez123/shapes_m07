import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'util_custom_scroll.dart';

class UtilCustomScrollHorizontal extends BaseCustomScroll {
  const UtilCustomScrollHorizontal({
    super.key,
    required super.size,
    required super.contentSize,
    required super.onChanged,
  });

  @override
  UtilCustomScrollHorizontalState createState() =>
      UtilCustomScrollHorizontalState();
}

class UtilCustomScrollHorizontalState
    extends BaseCustomScrollState<UtilCustomScrollHorizontal> {
  @override
  void onDragUpdate(DragUpdateDetails details) {
    double oldOffset = offset;
    double newOffset = getScrollDelta(-details.delta.dx);

    GlobalKey key = widget.key as GlobalKey;
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);
    final bool isInsideHorizontally =
        (renderBox.paintBounds.left + 5) <= localPosition.dx &&
            localPosition.dx <= (renderBox.paintBounds.right - 5);

    if (isInsideHorizontally) {
      if (oldOffset != newOffset) {
        setState(() {
          offset = newOffset;
          widget.onChanged(offset);
        });
      }
    }
  }

  @override
  void setTrackpadDelta(double value) {
    super.setTrackpadDelta(-value);
  }

  @override
  double getOffset() {
    return -offset;
  }

  @override
  Widget build(BuildContext context) {
    double draggerSize = getDraggerSize();
    double relation = offset * (widget.size - draggerSize) / 2;
    double position = (widget.size / 2) - (draggerSize / 2) + relation;
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: position,
          height: 12,
          width: draggerSize,
          child: Container(
            padding: const EdgeInsets.all(2.5),
            child: GestureDetector(
                onHorizontalDragUpdate: onDragUpdate,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1,
                        color: CDKTheme.grey80.withOpacity(0.5),
                      ),
                      color: CDKTheme.grey.withOpacity(0.5)),
                )),
          ),
        ),
      ],
    );
  }
}
