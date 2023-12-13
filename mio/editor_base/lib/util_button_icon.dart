import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';

// Copyright © 2023 Albert Palacios. All Rights Reserved.
// Licensed under the BSD 3-clause license, see LICENSE file for details.

class UtilButtonIcon extends StatefulWidget {
  final VoidCallback? onPressed;
  final double size;
  final bool isSelected;
  final Widget child;

  const UtilButtonIcon({
    super.key,
    this.onPressed,
    this.size = 24.0,
    this.isSelected = false,
    required this.child,
  });

  @override
  UtilButtonIconState createState() => UtilButtonIconState();
}

class UtilButtonIconState extends State<UtilButtonIcon> {
  bool _isPressed = false;
  bool _isHovering = false;
  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _onMouseEnter(PointerEvent details) {
    setState(() => _isHovering = true);
  }

  void _onMouseExit(PointerEvent details) {
    setState(() => _isHovering = false);
  }

  @override
  Widget build(BuildContext context) {
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    final Color backgroundColor = theme.isLight
        ? _isPressed
            ? CDKTheme.grey70
            : _isHovering
                ? CDKTheme.grey50
                : widget.isSelected
                    ? theme.backgroundSecondary1
                    : CDKTheme.transparent
        : _isPressed
            ? CDKTheme.grey
            : _isHovering
                ? CDKTheme.grey600
                : widget.isSelected
                    ? theme.backgroundSecondary1
                    : CDKTheme.transparent;

    return MouseRegion(
      onEnter: _onMouseEnter,
      onExit: _onMouseExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: backgroundColor, borderRadius: BorderRadius.circular(8)),
          child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              child: widget.child),
        ),
      ),
    );
  }
}
