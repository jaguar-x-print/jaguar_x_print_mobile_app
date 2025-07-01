import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'dart:io';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PrinterEnvironmentCard extends StatefulWidget {
  final Function(List<File?>) onImagesPicked;
  final Function(String) onCommentChanged;

  const PrinterEnvironmentCard({
    super.key,
    required this.onImagesPicked,
    required this.onCommentChanged,
  });

  @override
  State<PrinterEnvironmentCard> createState() => _PrinterEnvironmentCardState();
}

class _PrinterEnvironmentCardState extends State<PrinterEnvironmentCard> {
  final List<File?> _images = List.filled(5, null);
  int _imageCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isCompressing = false; // État pour suivre la compression

  Future<void> _pickImage() async {
    if (_imageCount >= 5 || _isCompressing) return;

    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() => _isCompressing = true);

        // Compresser l'image avant de la stocker
        final compressedFile = await _compressImage(File(pickedFile.path));

        setState(() {
          _images[_imageCount] = compressedFile;
          _imageCount++;
          _isCompressing = false;
        });
        widget.onImagesPicked(_images);
      }
    } catch (e) {
      setState(() => _isCompressing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<File> _compressImage(File original) async {
    try {
      // Créer un chemin pour l'image compressée
      final tempDir = Directory.systemTemp;
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Compresser l'image (70% de qualité)
      final result = await FlutterImageCompress.compressAndGetFile(
        original.path,
        targetPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 768,
      );

      return File(result!.path);
    } catch (e) {
      // En cas d'erreur, retourner l'original
      return original;
    }
  }

  void _showFullImage(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.1,
          maxScale: 6.0,
          child: Image.file(image),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      // Décaler les images vers la gauche
      for (int i = index; i < _images.length - 1; i++) {
        _images[i] = _images[i + 1];
      }
      _images[_images.length - 1] = null;
      _imageCount--;
    });
    widget.onImagesPicked(_images);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: Adaptive.w(4)),
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "1. Environnement de l'imprimante",
              style: TextStyle(
                fontSize: Adaptive.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Adaptive.h(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prendre une photo",
                  style: TextStyle(fontSize: Adaptive.sp(15)),
                ),
                Row(
                  children: [
                    Text(
                      "$_imageCount/5",
                      style: TextStyle(
                        fontSize: Adaptive.sp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: Adaptive.w(2)),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_a_photo_rounded),
                          onPressed: _imageCount < 5 ? _pickImage : null,
                          color: _imageCount < 5 ? null : Colors.grey,
                        ),
                        if (_isCompressing)
                          const Positioned(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (_imageCount > 0)
              SizedBox(
                height: Adaptive.h(12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageCount,
                  itemBuilder: (context, index) {
                    return _buildImageThumbnail(index);
                  },
                ),
              ),
            SizedBox(height: Adaptive.h(1)),
            InputField(
              controller: _commentController,
              minLines: 2,
              onTap: () {},
              focus: true,
              textColor: blackColor,
              backColor: whiteColor,
              hint: 'Commentaires...',
              keyboardType: TextInputType.multiline,
              onChange: (value) {
                widget.onCommentChanged(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    if (_images[index] == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(right: Adaptive.w(2)),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: () => _showFullImage(context, _images[index]!),
            child: Container(
              width: Adaptive.w(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.file(
                _images[index]!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _removeImage(index),
            ),
          ),
        ],
      ),
    );
  }
}