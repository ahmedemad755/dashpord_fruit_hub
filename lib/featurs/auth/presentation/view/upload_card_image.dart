// import 'dart:io';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class UploadCardImageWidget extends StatefulWidget {
//   final Function(String imageUrl) onImageUploaded;

//   const UploadCardImageWidget({super.key, required this.onImageUploaded});

//   @override
//   State<UploadCardImageWidget> createState() => _UploadCardImageWidgetState();
// }

// class _UploadCardImageWidgetState extends State<UploadCardImageWidget> {
//   File? _imageFile;
//   bool _isLoading = false;
//   double _uploadProgress = 0.0;

//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     setState(() => _isLoading = true);
//     try {
//       final hasPermission = await _requestPermissions();
//       if (!hasPermission) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("يجب السماح بالوصول للكاميرا والمعرض")),
//         );
//         return;
//       }

//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 75,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _imageFile = File(pickedFile.path);
//         });
//         await _uploadImage(_imageFile!);
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _uploadImage(File file) async {
//     setState(() => _isLoading = true);

//     try {
//       final ref = FirebaseStorage.instance.ref().child(
//         'user_cards/${DateTime.now().millisecondsSinceEpoch}.jpg',
//       );

//       final uploadTask = ref.putFile(file);

//       // متابعة نسبة الرفع
//       uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//         final progress = snapshot.bytesTransferred / snapshot.totalBytes;
//         setState(() {
//           _uploadProgress = progress;
//         });
//       });

//       await uploadTask;
//       final url = await ref.getDownloadURL();
//       widget.onImageUploaded(url);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('فشل رفع الصورة: $e')));
//     } finally {
//       setState(() {
//         _isLoading = false;
//         _uploadProgress = 0.0;
//       });
//     }
//   }

//   Future<bool> _requestPermissions() async {
//     if (Platform.isIOS) {
//       final camera = await Permission.camera.request();
//       final photos = await Permission.photos.request();
//       return camera.isGranted && photos.isGranted;
//     } else {
//       int sdk = int.parse((await _getAndroidSdkInt()) ?? '0');
//       if (sdk >= 33) {
//         final camera = await Permission.camera.request();
//         final media = await Permission.photos.request();
//         return camera.isGranted && media.isGranted;
//       } else {
//         final camera = await Permission.camera.request();
//         final storage = await Permission.storage.request();
//         return camera.isGranted && storage.isGranted;
//       }
//     }
//   }

//   Future<String?> _getAndroidSdkInt() async {
//     try {
//       final result = await Process.run('getprop', ['ro.build.version.sdk']);
//       return result.stdout.toString().trim();
//     } catch (_) {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _uploadProgress > 0 && _uploadProgress < 1
//             ? LinearProgressIndicator(value: _uploadProgress)
//             : _isLoading
//             ? const CircularProgressIndicator()
//             : _imageFile != null
//             ? Image.file(
//                 _imageFile!,
//                 width: 200,
//                 height: 200,
//                 fit: BoxFit.cover,
//               )
//             : const Icon(Icons.image, size: 100, color: Colors.grey),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//           onPressed: _pickImage,
//           icon: const Icon(Icons.upload),
//           label: const Text('رفع صورة البطاقة'),
//         ),
//       ],
//     );
//   }
// }
