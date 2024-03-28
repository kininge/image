import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:text_editor/text_editor.dart';

class AddTextScreen extends StatefulWidget {
  final File imageToAddText;
  final LindiController controller;

  const AddTextScreen(
      {super.key, required this.imageToAddText, required this.controller});

  @override
  State<AddTextScreen> createState() {
    return _AddTextState();
  }
}

class _AddTextState extends State<AddTextScreen> {
  bool showAddTextScreen = false;

  void saveAddText() {}

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black, // bottom navigation bar
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: [
          // main screen that have image
          Scaffold(
            backgroundColor: Colors.black,

            // header
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                onPressed: () {
                  // go back
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
              title: const Text(
                'Add Text',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // go back
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),

            body: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    // image
                    Expanded(
                      child: LindiStickerWidget(
                        controller: widget.controller,
                        child: Image.file(widget.imageToAddText),
                      ),
                    ),

                    //tools
                    if (showAddTextScreen == false)
                      SizedBox(
                        height: 76.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),

                          // add text
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.only(
                                right: 16.0,
                                left: 12.0,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                showAddTextScreen = true;
                              });
                            },
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Add Text',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // editing text screen
          if (showAddTextScreen)
            Scaffold(
              backgroundColor: const Color.fromRGBO(0, 0, 0, 0.75),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: TextEditor(
                    fonts: const ['Roboto'],
                    paletteColors: [
                      ThemeData.light().colorScheme.primary,
                      Colors.white,
                      Colors.black,
                    ],
                    text: '',
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                    textAlingment: TextAlign.center,
                    minFontSize: 14.0,
                    maxFontSize: 48.0,

                    backgroundColor: Colors.amber.withOpacity(0.4),

                    // decoration: EditorDecoration(

                    //   doneButton: const Text(
                    //     'Done',
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontFamily: 'Roboto',
                    //       fontSize: 18.0,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    //   fontFamily: const SizedBox(width: 0.0),
                    //   colorPalette: const SizedBox(width: 0.0),
                    //   alignment: AlignmentDecoration(
                    //     left: const SizedBox(width: 0.0),
                    //     center: const SizedBox(width: 0.0),
                    //     right: const SizedBox(width: 0.0),
                    //   ),
                    // ),
                    onEditCompleted: (style, align, text) {
                      setState(() {
                        if (text.isNotEmpty) {
                          widget.controller.addWidget(
                            Text(
                              text,
                              textAlign: align,
                              style: style,
                            ),
                          );
                        }
                        showAddTextScreen = false;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
