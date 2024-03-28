import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/widget/story_stickers.dart';

class EditImage extends StatefulWidget {
  final File image;
  const EditImage({super.key, required this.image});

  @override
  State<EditImage> createState() => _EditImageState();
}

class _EditImageState extends State<EditImage> {
  Widget? childWidget;
  Size? childWidgetSize;

  void addWidget() {
    String word = 'Hello World';

    setState(() {
      childWidgetSize = Size(12 * 2 + word.length * 36, 8 * 2 + 36 + 8);
      childWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        child: Text(
          word,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 36.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }

  void removeWidget() {
    setState(() {
      childWidget = null;
      childWidgetSize = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    EdgeInsets screenUnsafeArea = MediaQuery.of(context).padding;
    Size editorCanvasSize = Size(
      screenSize.width,
      screenSize.height - 141 - screenUnsafeArea.top - screenUnsafeArea.bottom,
    );

    late void Function(Widget widget) addWidget;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 64.0,
        leading: const SizedBox(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // image
            StoryStickers(
              controller: (
                BuildContext context,
                void Function(Widget widget) childFunction,
              ) {
                addWidget = childFunction;
              },
              child: SizedBox(
                height: editorCanvasSize.height,
                width: editorCanvasSize.width,

                // main image background
                child: Image.file(
                  widget.image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            //tools
            SizedBox(
              height: 76.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // tools
                    Container(
                      height: 48.0,
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child: Row(
                        children: [
                          // add text
                          Container(
                            width: 48,
                            decoration: const BoxDecoration(
                              border: Border(
                                right:
                                    BorderSide(color: Colors.grey, width: 1.5),
                              ),
                            ),
                            child: Center(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  var widgetKey = GlobalKey();
                                  String word = 'Hello World';
                                  Widget widget = Container(
                                    key: widgetKey,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 8.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      word,
                                      style: const TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize: 36.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );

                                  addWidget.call(widget);
                                },
                                child: const Text(
                                  'Aa',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromRGBO(114, 114, 114, 1.0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Center(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  // storyActionController.currentState.test();
                                  // storyActionController.currentContext.
                                },
                                child: const Text(
                                  'Dr',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromRGBO(114, 114, 114, 1.0),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
