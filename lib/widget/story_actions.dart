import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class StoryActions extends StatefulWidget {
  final Size canvasSize;
  final Widget background;
  final Size? childSize;
  final Widget? child;
  final void Function() removeChild;

  const StoryActions({
    super.key,
    required this.background,
    required this.canvasSize,
    required this.removeChild,
    this.child,
    this.childSize,
  });

  @override
  State<StoryActions> createState() {
    return _StoryActionsState();
  }
}

class _StoryActionsState extends State<StoryActions> {
  Offset stickerPosition = const Offset(100.0, 300.0);
  double stickerScaleReserve = 0.0; // needed in delete case
  double stickerScale = 1.0;
  double stickerRotation = 0.0;

  double scalingReference = 1.0;
  double rotatingReference = 0.0;
  bool showDeleteStickerOption = false;

  void test() {
    print('============== Print from child');
  }

  void updateScaleAndRotate(ScaleUpdateDetails action) {
    double scalingAction = action.scale;
    double rotatingAction = action.rotation;

    setState(() {
      stickerScale = scalingReference * scalingAction;
      stickerRotation = rotatingReference + rotatingAction;
    });
  }

  void onScaleAndRotateEnd(ScaleEndDetails details) {
    setState(() {
      scalingReference = stickerScale;
      rotatingReference = stickerRotation;
    });
  }

  void updatePosition(Offset relativeOffset) {
    double deleteAreaHeight =
        widget.canvasSize.height - widget.childSize!.height - 45.0;
    double dx = stickerPosition.dx + relativeOffset.dx;
    double dy = stickerPosition.dy + relativeOffset.dy;

    setState(() {
      if (dy >= deleteAreaHeight && stickerScale != 0.4) {
        // delete area
        stickerScaleReserve = stickerScale;
        stickerScale = 0.4;
      } else if (dy < deleteAreaHeight && stickerScale == 0.4) {
        stickerScale = stickerScaleReserve;
        stickerScaleReserve = 0.0;
      }
      stickerPosition = Offset(dx, dy);
    });
  }

  void updatePositionStart() {
    setState(() {
      showDeleteStickerOption = true;
    });
  }

  void resetAllValuesAndDelete() {
    setState(() {
      // reset
      stickerPosition = const Offset(100.0, 300.0);
      stickerScaleReserve = 0.0;
      stickerScale = 1.0;
      stickerRotation = 0.0;
      scalingReference = 1.0;
      rotatingReference = 0.0;
      showDeleteStickerOption = false;
    });

    widget.removeChild();
  }

  void updatePositionEnd() {
    double deleteAreaHeight =
        widget.canvasSize.height - widget.childSize!.height - 45.0;

    if (stickerPosition.dy >= deleteAreaHeight) {
      resetAllValuesAndDelete();
    } else {
      setState(() {
        showDeleteStickerOption = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.background,
        if (widget.child != null)
          Positioned(
            left: stickerPosition.dx,
            top: stickerPosition.dy,
            child: GestureDetector(
              onScaleUpdate: (ScaleUpdateDetails details) {
                print('scaling ${details.scale}');
                updateScaleAndRotate(details);
              },
              onScaleEnd: (ScaleEndDetails details) {
                onScaleAndRotateEnd(details);
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Draggable(
                  maxSimultaneousDrags: 1,
                  feedback: const SizedBox(),
                  onDragUpdate: (DragUpdateDetails details) =>
                      updatePosition(details.delta),
                  onDragStarted: () {
                    updatePositionStart();
                  },
                  onDragEnd: (_) {
                    updatePositionEnd();
                  },
                  child: Transform.scale(
                    scale: stickerScale,
                    child: Transform.rotate(
                      angle: stickerRotation,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showDeleteStickerOption)
          Positioned(
            left: 20.0,
            bottom: 5.0,
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              color: Colors.white,
              strokeWidth: 2.0,
              child: SizedBox(
                height: 40.0,
                width: widget.canvasSize.width - 40.0,
                child: const Center(
                  child: Text(
                    'Drag to Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
