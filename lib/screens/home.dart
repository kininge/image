import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/screens/edit_image.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  List<File> images = [];

  // ask permission to user
  void _getGalleryImages() async {
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (permission.isAuth || permission.hasAccess) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        filterOption: FilterOptionGroup(
          // condition so no audio will get picked
          audioOption: const FilterOption(
            durationConstraint: DurationConstraint(
              allowNullable: false,
              min: Duration(hours: 100),
            ),
          ),
          // condition so no audio will get picked
          videoOption: const FilterOption(
            durationConstraint: DurationConstraint(
              allowNullable: false,
              min: Duration(hours: 100),
            ),
          ),
        ),
      );

      // oth album is recent images
      await albums[0]
          .getAssetListRange(
            start: 0,
            end: 80,
          )
          .then(
            (List<AssetEntity> assets) => {
              // ignore: avoid_function_literals_in_foreach_calls
              assets.forEach(
                (AssetEntity asset) async {
                  File? image;
                  try {
                    image = await asset.file;

                    setState(() {
                      images.add(image!);
                    });
                    // ignore: empty_catches
                  } catch (e) {}
                },
              ),
            },
          );
    }
  }

  @override
  void initState() {
    super.initState();

    _getGalleryImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Select Image'),
      ),
      body: GridView(
        padding: const EdgeInsets.all(5.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 0.56,
        ),
        children: [
          ...images.map(
            (File image) => GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext nextPageContext) =>
                        EditImage(image: image),
                  ),
                );
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.all(
                    Radius.circular(4.0),
                  ),
                ),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
