import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaguar_x_print/constant/colors.dart';
import 'dart:io';
import 'package:jaguar_x_print/widgets/fields/text_input_field.dart';

class NiveauEncreCard extends StatefulWidget {
  final Function(List<File?>) onImagesPicked;
  final Function(String) onCommentChanged;
  final Function(String) onNiveauChanged;

  const NiveauEncreCard({
    super.key,
    required this.onImagesPicked,
    required this.onCommentChanged,
    required this.onNiveauChanged,
  });

  @override
  State<NiveauEncreCard> createState() => _NiveauEncreCardState();
}

class _NiveauEncreCardState extends State<NiveauEncreCard> {
  String? _niveauEncre;
  final List<File?> _images = List.filled(5, null);
  int _imageCount = 0;
  final TextEditingController _commentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_imageCount >= 5) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images[_imageCount] = File(pickedFile.path);
        _imageCount++;
      });
      widget.onImagesPicked(_images);
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
      color: color3,
      margin: EdgeInsets.symmetric(horizontal: Adaptive.w(4)),
      child: Padding(
        padding: EdgeInsets.all(Adaptive.w(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "3. Niveau d'encre",
              style: TextStyle(
                fontSize: Adaptive.sp(18),
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
            SizedBox(height: Adaptive.h(1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      "Correct",
                      style: TextStyle(
                        fontSize: Adaptive.sp(14),
                        color: whiteColor,
                      ),
                    ),
                    value: "Correct",
                    groupValue: _niveauEncre,
                    activeColor: whiteColor,
                    onChanged: (value) {
                      setState(() {
                        _niveauEncre = value;
                      });
                      widget.onNiveauChanged(value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(
                      "Trop bas",
                      style: TextStyle(
                        fontSize: Adaptive.sp(14),
                        color: whiteColor,
                      ),
                    ),
                    value: "Trop bas",
                    groupValue: _niveauEncre,
                    activeColor: whiteColor,
                    onChanged: (value) {
                      setState(() {
                        _niveauEncre = value;
                      });
                      widget.onNiveauChanged(value!);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Prendre une photo",
                  style: TextStyle(
                    fontSize: Adaptive.sp(15),
                    color: whiteColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "$_imageCount/5",
                      style: TextStyle(
                        fontSize: Adaptive.sp(14),
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                    SizedBox(width: Adaptive.w(2)),
                    IconButton(
                      color: whiteColor,
                      icon: Icon(
                        Icons.add_a_photo_rounded,
                        color: _imageCount < 5 ? null : greyColor,
                      ),
                      onPressed: _imageCount < 5 ? _pickImage : null,
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
              backColor: whiteColor,
              textColor: blackColor,
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
