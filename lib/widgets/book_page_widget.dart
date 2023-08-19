import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:nclientv3/utils/utils.dart';
import 'package:nclientv3/widgets/widgets.dart';
import 'package:nhentai/nhentai.dart' as nh;
import 'package:widget_visibility_detector/widget_visibility_detector.dart';

class BookPageWidget extends StatefulWidget {
  /// needs to be of type File or of type nh.Image
  final dynamic _page;
  final nh.API? _api;
  final String? _bookName;

  const BookPageWidget({
    super.key,

    /// needs to be of type File or of type nh.Image
    required dynamic page,
    String? bookName,
    nh.API? api,
    bool? offline,
  })  : _page = page,
        _api = api,
        _bookName = bookName;

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  bool _loading = true;
  File? _image;
  bool _hideImage = false;
  String? _errorMessage;
  bool _offline = false;
  int? _imageHeight;

  Future<void> fetchData() async {
    if (widget._api == null) {
      setState(() {
        _errorMessage = "Did not get API... Coding bug, gomen!";
        _loading = false;
      });
      return;
    }

    if (widget._bookName == null) {
      setState(() {
        _errorMessage = "Did not get book title... Coding bug, gomen!";
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    final img = await downloadImage(widget._api!, widget._page, widget._bookName!);

    setState(() {
      _image = img;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget._page is nh.Image) {
      fetchData();
    } else if (widget._page is File) {
      _loading = false;
      _offline = true;
      _image = widget._page;
      if (_image != null) {
        final size = ImageSizeGetter.getSize(FileInput(_image!));
        // set initial height
        _imageHeight = size.height;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          // -14 because of the padding
          double screenWidth = MediaQuery.of(context).size.width - 14;
          final imageAspectRatio = size.width / size.height;
          setState(() {
            _imageHeight = screenWidth ~/ imageAspectRatio;
          });
        });
      }
    } else {
      _loading = false;
      _errorMessage = "Damn! A coding bug has prevented me from getting this image!";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return MessagePageWidget(text: _errorMessage!);
    }

    if (_loading) {
      return const SizedBox(
        height: 500,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_image == null) {
      return const Text("Oh no! Could not get this image!");
    }

    // Display the widget once the async operation is completed
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                insetPadding: EdgeInsets.zero,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: InteractiveViewer(
                    boundaryMargin: const EdgeInsets.all(20),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(_image!),
                  ),
                ),
              );
            },
          );
        },
        child: WidgetVisibilityDetector(
          onAppear: () {
            if (!_offline) return;

            setState(() {
              _hideImage = false;
            });
          },
          onDisappear: () {
            if (!_offline) return;

            setState(() {
              _hideImage = true;
            });
          },
          child: _hideImage
              ? Column(
                  children: [
                    Container(
                      // should never result to 0, but you never know
                      height: (_imageHeight ?? 0).toDouble(),
                    ),
                    Container(),
                  ],
                )
              : Image.file(_image!),
        ),
      ),
    );
  }
}
