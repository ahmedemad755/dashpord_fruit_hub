import 'package:image_picker/image_picker.dart'; // استبدال dart:io بـ image_picker

abstract class StorgeService {
  // تم تغيير النوع من File إلى XFile ليدعم الرفع من المتصفح والموبايل
  Future<String?> uploadImage(XFile file, String path);
  
  Future<void> deleteFile(String path);
}