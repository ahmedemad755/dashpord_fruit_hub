import 'dart:io';

import 'package:fruitesdashboard/core/services/storge_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as b;

class FireStorge implements StorgeService {
  final storgerefrance = FirebaseStorage.instance.ref();
  @override
  Future<String?> uploadImage(File file, String path) async {
    String fileName = b.basename(file.path);
    // String extension = b.extension(file.path);
    String filePath = '$path/$fileName';
    var imagereference = storgerefrance.child(filePath);
    return await imagereference.putFile(file).then((value) async {
      var downloadimageUrl = await value.ref.getDownloadURL();
      return downloadimageUrl;
    });
  }
}
