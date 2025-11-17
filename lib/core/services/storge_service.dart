import 'dart:io';

abstract class StorgeService {
  Future<String?> uploadImage(File file, String path);
}
