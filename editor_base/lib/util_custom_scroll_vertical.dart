import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'util_custom_scroll.dart';

class UtilCustomScrollVertical extends BaseCustomScroll {
  const UtilCustomScrollVertical({
    super.key,
    required super.size,
    required super.contentSize,
    required super.onChanged,
  });

  @override
  UtilCustomScrollVerticalState createState() =>
      UtilCustomScrollVerticalState();
}

class UtilCustomScrollVerticalState
    extends BaseCustomScrollState<UtilCustomScrollVertical> {
  @override
  void onDragUpdate(DragUpdateDetails details) {
    double oldOffset = offset;
    double newOffset = getScrollDelta(details.delta.dy);

    GlobalKey key = widget.key as GlobalKey;
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);
    final bool isInsideVertically =
        (renderBox.paintBounds.top + 5) <= localPosition.dy &&
            localPosition.dy <= (renderBox.paintBounds.bottom - 5);

    if (isInsideVertically) {
      if (oldOffset != newOffset) {
        setState(() {
          offset = newOffset;
          widget.onChanged(offset);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double draggerSize = getDraggerSize();
    double relation = offset * (widget.size - draggerSize) / 2;
    double position = (widget.size / 2) - (draggerSize / 2) + relation;
    return Stack(
      children: [
        Positioned(
          top: position,
          right: 0,
          height: draggerSize,
          width: 12,
          child: Container(
            padding: const EdgeInsets.all(2.5),
            child: GestureDetector(
                onVerticalDragUpdate: onDragUpdate,
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
