import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:path/path.dart' as b;

class FireStorge implements StorgeService {
  final storgerefrance = FirebaseStorage.instance.ref();

  @override
  Future<String?> uploadImage(File file, String path) async {
    // إضافة uniqueId لاسم الملف لمنع التكرار
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = b.basename(file.path);
    String filePath = '$path/${uniqueId}_$fileName';

    var imagereference = storgerefrance.child(filePath);
    return await imagereference.putFile(file).then((value) async {
      var downloadimageUrl = await value.ref.getDownloadURL();
      return downloadimageUrl;
    });
  }

  @override
  Future<void> deleteFile(String path) async {
    await storgerefrance.child(path).delete();
  }
}
