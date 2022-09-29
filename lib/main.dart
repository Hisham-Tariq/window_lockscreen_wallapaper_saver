import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<FileSystemEntity> _files = [];
  String pictureDirPath = '';
  String userDirPath = '';
  @override
  void initState() {
    super.initState();
    // Process.run('explorer', [_projectController.currentFolderPath!])
    getDownloadsDirectory().then((value) {
      userDirPath = value!.path.replaceFirst("Downloads", "");
      pictureDirPath = "${userDirPath}Pictures\\";
      _files =
          Directory('${userDirPath}AppData\\Local\\Packages\\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\\LocalState\\Assets').listSync();
      _files = _files.where((element) => (element.statSync().size ~/ 1024) > 200).toList();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GridView
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    return CustomImageTile(
                      imageFile: _files[index] as File,
                      pictureDirPath: pictureDirPath,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomImageTile extends StatefulWidget {
  const CustomImageTile({super.key, required this.imageFile, required this.pictureDirPath});
  final File imageFile;
  final String pictureDirPath;
  @override
  State<CustomImageTile> createState() => _CustomImageTileState();
}

class _CustomImageTileState extends State<CustomImageTile> {
  bool isHovering = false;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              fullscreenDialog: true,
              pageBuilder: (context, animation, secondaryAnimation) {
                return Material(
                  child: SizedBox(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Hero(
                            tag: widget.imageFile.path,
                            child: Image.file(
                              widget.imageFile,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          left: 0,
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: savePictureToGallery,
                                  icon: const Icon(Icons.save),
                                  label: const Text("Save to Pictures"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        child: MouseRegion(
          onEnter: (e) {
            setState(() {
              isHovering = true;
            });
          },
          onExit: (e) {
            setState(() {
              isHovering = false;
            });
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: widget.imageFile.path,
                  child: Image.file(
                    widget.imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                bottom: isHovering ? 0 : -100,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  color: Colors.black.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Size",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                '${widget.imageFile.statSync().size ~/ 1024} KB',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // save button
                        Material(
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: TextButton.icon(
                            onPressed: savePictureToGallery,
                            icon: const Icon(Icons.save),
                            label: const Text("Save to Pictures"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  savePictureToGallery() async {
    // random String of 5 Alphabets characters
    final randomString = String.fromCharCodes(
      List.generate(
        5,
        (index) => Random().nextInt(26) + 65,
      ),
    );
    await widget.imageFile.copy(
      '${widget.pictureDirPath}$randomString.png',
    );
    // show banner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Saved to Pictures"),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
