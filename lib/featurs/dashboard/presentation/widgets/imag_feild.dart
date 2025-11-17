import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImagFeild extends StatefulWidget {
  final ValueChanged<File?> onImagePicked;
  const ImagFeild({super.key, required this.onImagePicked});

  @override
  State<ImagFeild> createState() => _ImagFeildState();
}

class _ImagFeildState extends State<ImagFeild> {
  bool isLoading = false;
  File? filImage;
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () async {
          isLoading = true;
          setState(() {});
          try {
            await pickImage();
          } on Exception {
            isLoading = false;
            setState(() {});
          }
          isLoading = false;
          setState(() {});
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: filImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(filImage!),
                    )
                  : Icon(Icons.image_outlined, size: 180),
            ),
            Visibility(
              visible: filImage != null,
              child: IconButton(
                onPressed: () {
                  filImage = null;
                  // widget.onImagePicked(null);
                  setState(() {});
                },
                icon: Icon(Icons.delete),
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    filImage = File(image!.path);
    widget.onImagePicked(filImage);
  }
}
