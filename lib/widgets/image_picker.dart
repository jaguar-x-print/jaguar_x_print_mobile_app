import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaguar_x_print/constant/colors.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? initialImagePath;
  final Function(String? imagePath) onImageSelected;

  const ImagePickerWidget({
    super.key,
    this.initialImagePath,
    required this.onImageSelected,
  });

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: () {
            if (_imagePath != null) {
              _showFullScreenImage(context);
            }
          },
          child: CircleAvatar(
            radius: Adaptive.w(20),
            backgroundColor: transparentColor,
            backgroundImage: _imagePath != null
                ? _imagePath!.startsWith("assets/")
                ? AssetImage(_imagePath!) as ImageProvider
                : FileImage(File(_imagePath!))
                : null,
            child: _imagePath == null
                ? Icon(
              Icons.camera_enhance_rounded,
              size: Adaptive.sp(40),
              color: whiteColor,
            )
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showBottomSheet(context),
            child: CircleAvatar(
              radius: Adaptive.w(5),
              backgroundColor: firstColor,
              child: Icon(
                Icons.camera_enhance_rounded,
                color: whiteColor,
                size: Adaptive.sp(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context) {
    if (_imagePath != null) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 8,
                child: _imagePath!.startsWith("assets/")
                    ? Image.asset(_imagePath!, fit: BoxFit.contain)
                    : Image.file(
                  File(_imagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(Adaptive.w(4)),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(Adaptive.w(2)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Adaptive.w(7)),
                      color: firstColor,
                    ),
                    height: Adaptive.h(0.6),
                    width: Adaptive.w(25),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Ajouter une image",
                  style: TextStyle(fontSize: Adaptive.sp(17), fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: Adaptive.h(3)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery, context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor,
                      backgroundColor: firstColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: Adaptive.w(6), vertical: Adaptive.h(1.5)),
                    ),
                    icon: Icon(Icons.photo_library_rounded, size: Adaptive.sp(16)),
                    label: Text('Galerie', style: TextStyle(fontSize: Adaptive.sp(14))),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera, context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: whiteColor,
                      backgroundColor: firstColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: Adaptive.w(6), vertical: Adaptive.h(1.5)),
                    ),
                    icon: Icon(Icons.camera_alt_rounded, size: Adaptive.sp(16)),
                    label: Text('Caméra', style: TextStyle(fontSize: Adaptive.sp(14))),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Compresser l'image (optionnel)
      final compressedFile = await _compressImage(File(pickedFile.path));

      if (compressedFile != null) {
        setState(() {
          _imagePath = compressedFile.path;
        });
        widget.onImageSelected(_imagePath);

        // Fermer le BottomSheet après la sélection de l'image
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "${file.absolute.path}_compressed.jpg",
      quality: 50,
    );

    if (result != null) {
      return File(result.path);
    } else {
      return null;
    }
  }
}