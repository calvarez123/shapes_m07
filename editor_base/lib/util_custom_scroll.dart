import 'package:flutter/cupertino.dart';

abstract class BaseCustomScroll extends StatefulWidget {
  final double size;
  final double contentSize;
  final Function(double) onChanged;

  const BaseCustomScroll({
    super.key,
    required this.size,
    required this.contentSize,
    required this.onChanged,
  });

  @override
  BaseCustomScrollState createState();
}

abstract class BaseCustomScrollState<T extends BaseCustomScroll>
    extends State<T> with SingleTickerProviderStateMixin {
  double offset = 0;
  AnimationController? _inertiaAnimationController;
  Animation<double>? _inertiaAnimation;
  final List<double> _recentVelocities = [];

  @override
  void initState() {
    super.initState();
    _inertiaAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _inertiaAnimationController!.addListener(() {
      setOffset(_inertiaAnimation!.value);
    });
  }

  @override
  void dispose() {
    _inertiaAnimationController!.dispose();
    super.dispose();
  }

  double getDraggerSize() {
    if (widget.contentSize <= widget.size) {
      return 0;
    }
    double relation = widget.size / widget.contentSize;
    return widget.size * relation;
  }

  double getScrollDelta(delta) {
    double draggerSize = getDraggerSize();
    double relation = 2 / (widget.size - draggerSize);
    double normalizedDelta = delta * relation;
    double newOffset = offset + normalizedDelta;
    newOffset = newOffset.clamp(-1.0, 1.0);

    return newOffset;
  }

  double getContentDelta(double delta) {
    double draggerSize = getDraggerSize();
    double relationScroll = 2 / (widget.size - draggerSize);
    double relationContent = widget.size / widget.contentSize;
    double normalizedDelta = delta * relationScroll * relationContent;
    double newOffset = offset + normalizedDelta;
    newOffset = newOffset.clamp(-1.0, 1.0);

    return newOffset;
  }

  void onDragUpdate(DragUpdateDetails details);

  void setTrackpadDelta(double value) {
    _inertiaAnimationController!.stop();

    double oldOffset = offset;
    double newOffset = getContentDelta(-value);

    double deltaTime = _inertiaAnimationController!
            .lastElapsedDuration?.inMilliseconds
            .toDouble() ??
        16.0; // ~60 FPS com a referència
    double currentVelocity = (newOffset - oldOffset) / deltaTime;

    // Actualitzar la llista de velocitats recents
    _recentVelocities.add(currentVelocity);
    if (_recentVelocities.length > 5) {
      // Manté només els últims 5 valors
      _recentVelocities.removeAt(0);
    }

    if (oldOffset != newOffset) {
      setState(() {
        offset = newOffset;
        widget.onChanged(offset);
      });
    }
  }

  double _smoothVelocity(double currentVelocity) {
    if (_recentVelocities.isEmpty) return currentVelocity;
    double lastAverage =
        _recentVelocities.reduce((a, b) => a + b) / _recentVelocities.length;
    return (currentVelocity + lastAverage) / 2;
  }

  void startInertiaAnimation() {
    double averageVelocity = _recentVelocities.isEmpty
        ? 0
        : _recentVelocities.reduce((a, b) => a + b) / _recentVelocities.length;
    averageVelocity = _smoothVelocity(averageVelocity);
    if (averageVelocity.abs() < 0.001) return;

    double startValue = offset;
    double endValue = startValue + averageVelocity * 750;
    endValue = endValue.clamp(-1.0, 1.0);
    int durationMillis = (1000 / averageVelocity.abs()).clamp(10, 1000).toInt();
    _recentVelocities.clear();
    _inertiaAnimationController!.duration =
        Duration(milliseconds: durationMillis);
    _inertiaAnimation = Tween(begin: startValue, end: endValue).animate(
      CurvedAnimation(
        parent: _inertiaAnimationController!,
        curve: Curves.decelerate,
      ),
    );
    _inertiaAnimationController!.addListener(() {
      setOffset(_inertiaAnimation!.value);
      widget.onChanged(_inertiaAnimation!.value);
    });
    _inertiaAnimationController!.forward(from: 0);
  }

  void setWheelDelta(double value) {
    double oldOffset = offset;
    double newOffset = getScrollDelta(value);
    if (oldOffset != newOffset) {
      setState(() {
        offset = newOffset;
        widget.onChanged(offset);
      });
    }
  }

  void setOffset(double value) {
    assert(value >= -1.0 && value <= 1.0, 'El valor ha de ser entre -1 i 1.');
    setState(() {
      offset = value;
    });
  }

  double getOffset() {
    return offset;
  }
}
