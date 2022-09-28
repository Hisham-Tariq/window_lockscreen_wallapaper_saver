import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    // Process.run('explorer', [_projectController.currentFolderPath!])
    _files = Directory('C:\\Users\\Hisham\\AppData\\Local\\Packages\\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\\LocalState\\Assets')
        .listSync();
    _files = _files.where((element) => (element.statSync().size ~/ 1024) > 200).toList();
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
  const CustomImageTile({super.key, required this.imageFile});
  final File imageFile;
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
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
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
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      '${widget.imageFile.statSync().size ~/ 1024} KB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
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
}
