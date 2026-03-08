import 'dart:io';
import 'package:flutter/foundation.dart'; // ضروري للتعرف على الويب kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ImagFeild extends StatefulWidget {
  // التغيير هنا: نستخدم XFile بدلاً من File
  final ValueChanged<XFile?> onImagePicked;
  const ImagFeild({super.key, required this.onImagePicked});

  @override
  State<ImagFeild> createState() => _ImagFeildState();
}

class _ImagFeildState extends State<ImagFeild> {
  bool isLoading = false;
  XFile? selectedImage; // التغيير هنا ليكون XFile

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: isLoading,
      child: GestureDetector(
        onTap: () async {
          setState(() => isLoading = true);
          try {
            await pickImage();
          } catch (e) {
            debugPrint("Error picking image: $e");
          } finally {
            setState(() => isLoading = false);
          }
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 200, // حددنا الارتفاع لتجنب مشاكل التصميم
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
              ),
              child: selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                    )
                  : const Icon(Icons.image_outlined, size: 100),
            ),
            if (selectedImage != null)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        selectedImage = null;
                      });
                      widget.onImagePicked(null);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
      widget.onImagePicked(selectedImage);
    }
  }
}