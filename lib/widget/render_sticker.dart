import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/widget/story_stickers.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';

double OneDegree = pi / 180;

class RenderSticker extends StatefulWidget {
  final Sticker sticker;
  final Size editorCanvasSize;
  final void Function() whenStickerInDeleteArea;
  final void Function() whenStickerOutOfDeleteArea;
  final void Function(Sticker sticker) onStickerDelete;

  const RenderSticker({
    super.key,
    required this.sticker,
    required this.editorCanvasSize,
    required this.whenStickerInDeleteArea,
    required this.whenStickerOutOfDeleteArea,
    required this.onStickerDelete,
  });

  @override
  State<RenderSticker> createState() {
    return _RenderStickerState();
  }
}

class _RenderStickerState extends State<RenderSticker> {
  GlobalKey stickerKey = GlobalKey();
  double deleteAreaHeight = 0.0;
  Size stickerSize = const Size(0, 0);

  Offset stickerPosition = const Offset(0, 0);
  double stickerScaleReserve = 0.0;
  double stickerScale = 1.0;
  double stickerRotation = 0.0;

  Matrix4 translationDeltaMatrix = Matrix4.identity();
  Matrix4 scaleDeltaMatrix = Matrix4.identity();
  Matrix4 rotationDeltaMatrix = Matrix4.identity();
  Matrix4 matrix = Matrix4.identity();
  double scalingReference = 1.0;
  double rotatingReference = 0.0;

  void onPageLoad() {
    BuildContext? stickerContext = stickerKey.currentContext;

    if (stickerContext != null) {
      setState(() {
        if (widget.sticker.stickerPosition == null) {
          double dx =
              (widget.editorCanvasSize.width - stickerContext.size!.width) / 2;
          double dy =
              (widget.editorCanvasSize.height - stickerContext.size!.height) /
                  2;

          stickerPosition = Offset(dx, dy);
        }

        // on page load sticker size set
        deleteAreaHeight =
            widget.editorCanvasSize.height - stickerContext.size!.height - 45;
        stickerSize = stickerContext.size!;

        print('---> stickerPosition $stickerPosition ');
        print('---> deleteAreaHeight $deleteAreaHeight ');
        print('---> stickerSize $stickerSize ');
      });
    }
  }

  @override
  void initState() {
    super.initState();

    print('******** Initiate **********');
    print('-----> deleteAreaHeight $deleteAreaHeight');
    print('-----> stickerSize $stickerSize');
    print('-----> stickerPosition $stickerPosition');
    print('-------------------------------');

    if (stickerPosition.dx == 0) {
      stickerScaleReserve = widget.sticker.stickerScaleReserve ?? 0.0;
      stickerScale = widget.sticker.stickerScale ?? 1.0;
      stickerRotation = widget.sticker.stickerScale ?? 0.0;
      scalingReference = widget.sticker.scalingReference ?? 1.0;
      rotatingReference = widget.sticker.rotatingReference ?? 1.0;

      // on page load
      WidgetsBinding.instance.addPostFrameCallback((_) => onPageLoad());
    }
  }

  void updatePositionStart() {
    widget.whenStickerInDeleteArea();
  }

  Offset _solveVector(double vectorR, double angle) {
    double calculationAngle = angle % 360; // multiple rotations handle
    double xProduct = 0.0;
    double yProduct = 0.0;

    print('------> vector ${vectorR}  angle $angle');

    // 1st quadrant
    if (calculationAngle >= 0 && calculationAngle < 90) {
      print('quadrant 1');
      xProduct += vectorR * cos(calculationAngle);
      yProduct += vectorR * sin(calculationAngle);
    }
    // 2nd quadrant
    else if (calculationAngle >= 90 && calculationAngle < 180) {
      print('quadrant 2');
      calculationAngle -= 90;

      yProduct += vectorR * cos(calculationAngle);
      xProduct += vectorR * sin(calculationAngle);
    }
    // 3rd quadrant
    else if (calculationAngle >= 180 && calculationAngle < 270) {
      print('quadrant 3');
      calculationAngle -= 180;

      xProduct += vectorR * cos(calculationAngle);
      yProduct += vectorR * sin(calculationAngle);
    }
    // 4th quadrant
    else {
      print('quadrant 4');
      calculationAngle -= 270;

      yProduct += vectorR * cos(calculationAngle);
      xProduct += vectorR * sin(calculationAngle);
    }

    print('calculationAngle $calculationAngle');
    print('Product  $xProduct, $yProduct');

    return Offset(xProduct, yProduct);
  }

  Offset getVectorProduct(Offset relativeVector) {
    double angle =
        (stickerRotation / OneDegree).abs(); // -ve angle for easy calculation
    // Offset vectorProduct1 = _solveVector(relativeVector.dx, angle);
    // Offset vectorProduct2 = _solveVector(relativeVector.dy, angle + 90);
    print('angle $angle');
    angle = angle % 180; // handle to 180 degree
    print('angle 180 $angle');
    double calculateAngle = angle % 90;
    print('calculateAngle $calculateAngle');

    double xProduct = 0.0;
    double yProduct = 0.0;

    if (angle < 90) {
      print('1 or 3 quadrant');

      xProduct += relativeVector.dx * cos(calculateAngle);
      yProduct += relativeVector.dy * cos(calculateAngle);
      yProduct += relativeVector.dx * sin(calculateAngle);
      xProduct += relativeVector.dy * sin(calculateAngle);
    } else {
      print('2 or 4 quadrant');
      yProduct += -1 * relativeVector.dx * cos(calculateAngle);
      xProduct += -1 * relativeVector.dy * cos(calculateAngle);
      xProduct += -1 * relativeVector.dx * sin(calculateAngle);
      yProduct += -1 * relativeVector.dy * sin(calculateAngle);
    }

    return Offset(xProduct, yProduct);
  }

  void updatePosition(Offset relativeOffset) {
    // handle angled widget movement
    print('********* $relativeOffset');
    // Offset achualMovement = getVectorProduct(relativeOffset);
    // print('total $achualMovement');
    // print('------------');

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

  void updatePositionEnd() {
    if (stickerPosition.dy >= deleteAreaHeight) {
      widget.onStickerDelete(widget.sticker);
    } else {
      widget.whenStickerOutOfDeleteArea();
    }
  }

  void updateScaleAndRotate(ScaleUpdateDetails action) {
    Offset dragingAction = action.focalPointDelta;
    double scalingAction = action.scale;
    double rotatingAction = action.rotation;

    if (scalingAction == 1.0 && rotatingAction == 0.0) {
      // dragging action
      widget.whenStickerInDeleteArea();
      updatePosition(dragingAction);
    } else {
      // scaling or rotating action
      setState(() {
        stickerScale = scalingReference * scalingAction;
        stickerRotation = rotatingReference + rotatingAction;

        // print('90 degree ${pi / 2}');
        // print('---------> rotation $stickerRotation');
      });
    }

    // setState(() {
    //   stickerScale = scalingReference * scalingAction;
    //   stickerRotation = rotatingReference + rotatingAction;
    // });
  }

  void onScaleAndRotateEnd(ScaleEndDetails details) {
    updatePositionEnd();
    setState(() {
      scalingReference = stickerScale;
      rotatingReference = stickerRotation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: stickerPosition,
      child: Transform.scale(
        scale: stickerScale,
        child: Transform.rotate(
          angle: stickerRotation,
          child: Container(
            key: stickerKey,
            color: stickerPosition.dy == 0 ? Colors.black.withOpacity(0) : null,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () {
                print('----- taped ------');
              },
              onScaleUpdate: (ScaleUpdateDetails details) =>
                  updateScaleAndRotate(details),
              onScaleEnd: (ScaleEndDetails details) =>
                  onScaleAndRotateEnd(details),
              child: widget.sticker.stickerWidget,
            ),
          ),
        ),
      ),
    );
  }
}

// return Transform.translate(
//       offset: stickerPosition,
//       child: Transform.scale(
//         scale: stickerScale,
//         child: Transform.rotate(
//           angle: stickerRotation,
//           child: Draggable(
//             maxSimultaneousDrags: 1,
//             feedback: const SizedBox(),
            // onDragUpdate: (DragUpdateDetails details) =>
            //     updatePosition(details.delta),
            // onDragStarted: () {
            //   updatePositionStart();
            // },
            // onDragEnd: (_) {
            //   updatePositionEnd();
            // },
//             child: Container(
//               key: stickerKey,
//               color:
//                   stickerPosition.dy == 0 ? Colors.black.withOpacity(0) : null,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.deferToChild,
//                 onTap: () {
//                   print('----- taped ------');
//                 },
//                 onScaleStart: (ScaleStartDetails details) {
//                   print('---- start scale ${details.localFocalPoint}');
//                 },
//                 onScaleUpdate: (ScaleUpdateDetails details) =>
//                     updateScaleAndRotate(details),
//                 onScaleEnd: (ScaleEndDetails details) =>
//                     onScaleAndRotateEnd(details),
//                 child: widget.sticker.stickerWidget,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
