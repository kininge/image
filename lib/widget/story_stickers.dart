import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image/widget/render_sticker.dart';

typedef StoryStickersController = void Function(
  BuildContext context,
  void Function(Widget widget) addWidget,
);

class Sticker {
  final UniqueKey uniqueKey;
  final Widget stickerWidget;
  final Size? stickerWidgetSize;
  final Offset? stickerPosition;
  final double? stickerScaleReserve;
  final double? stickerScale;
  final double? stickerRotation;
  final double? scalingReference;
  final double? rotatingReference;

  const Sticker({
    required this.uniqueKey,
    required this.stickerWidget,
    this.stickerWidgetSize,
    this.stickerPosition,
    this.stickerScaleReserve,
    this.stickerScale,
    this.stickerRotation,
    this.scalingReference,
    this.rotatingReference,
  });
}

class StoryStickers extends StatefulWidget {
  final StoryStickersController controller;
  final Widget child;

  const StoryStickers({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  State<StoryStickers> createState() {
    return _StoryStickersState();
  }
}

class _StoryStickersState extends State<StoryStickers> {
  GlobalKey storyImageKey = GlobalKey();
  Size editorCanvasSize = const Size(0, 0);
  List<Sticker> stickers = [];
  bool showDeleteStickerOption = false;

  void addWdget(Widget widget) {
    Sticker sticker = Sticker(
      uniqueKey: UniqueKey(),
      stickerWidget: widget,
    );
    setState(() {
      stickers.add(sticker);
    });
  }

  void onPageLoad() {
    BuildContext? storyImageContext = storyImageKey.currentContext;

    if (storyImageContext != null) {
      setState(() {
        // on page load editor canvas si9ze fixed
        editorCanvasSize = storyImageContext.size!;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // on page load
    WidgetsBinding.instance.addPostFrameCallback((_) => onPageLoad());
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showDeleteSection() {
    if (showDeleteStickerOption == false) {
      setState(() {
        showDeleteStickerOption = true;
      });
    }
  }

  void removeDeleteSection() {
    if (showDeleteStickerOption == true) {
      setState(() {
        showDeleteStickerOption = false;
      });
    }
  }

  void onStickerDelete(Sticker sticker) {
    setState(() {
      stickers.remove(sticker);

      showDeleteStickerOption = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.call(context, addWdget); // to access from parent

    return Stack(
      children: [
        // conatiner used to get widget size
        Container(
          key: storyImageKey,
          child: widget.child,
        ),

        // delete section
        if (showDeleteStickerOption && editorCanvasSize.width > 0)
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
                width: editorCanvasSize.width - 40.0,
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

        // movable stickers
        ...stickers.map(
          (Sticker sticker) => RenderSticker(
            key: sticker.uniqueKey,
            sticker: sticker,
            editorCanvasSize: editorCanvasSize,
            whenStickerInDeleteArea: showDeleteSection,
            whenStickerOutOfDeleteArea: removeDeleteSection,
            onStickerDelete: onStickerDelete,
          ),
        ),
      ],
    );
  }
}
