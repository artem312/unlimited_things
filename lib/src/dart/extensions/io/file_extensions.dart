import 'dart:io';

import 'package:unlimited_things/src/dart/extensions/strings_extensions.dart';

extension DirectoryExtension on Directory {
  Directory getFolderFromList(List<String> subFolders) =>
      getFolder(subFolders.join(Platform.pathSeparator));

  Directory getFolder(String subfolder) {
    var formattedSubfolder = subfolder.pathEncoded;
    if (formattedSubfolder.startsWith(Platform.pathSeparator)) {
      formattedSubfolder = formattedSubfolder.substring(1);
    }
    return Directory('$path${Platform.pathSeparator}$subfolder');
  }

  File getFile(String filename) {
    var formattedFilename = filename.pathEncoded;
    if (formattedFilename.startsWith(Platform.pathSeparator)) {
      formattedFilename = formattedFilename.substring(1);
    }
    return File('$path${Platform.pathSeparator}$formattedFilename');
  }

  static Directory fromUrlEncoded(String path) =>
      Directory(path.replaceAll('/', Platform.pathSeparator));
}

extension FileEntityParams on FileSystemEntity {
  String get name => path.split(Platform.pathSeparator).last;

  String get pathUrlEncoded => path.replaceAll(Platform.pathSeparator, '/');

  String getSubPath(FileSystemEntity parent) {
    final parentPath = parent.path;
    if (path.startsWith(parentPath)) {
      return path.substring(parentPath.length + 1);
    }
    return path;
  }

  String getSubPathUrlEncoded(FileSystemEntity parent) =>
      getSubPath(parent).urlEncoded;
}

extension FileExtension on File {
  String get extension => name.split('.').last;

  String get nameWithoutExtension => name.substring(0, name.lastIndexOf('.'));

  static File fromUrlEncoded(String path) =>
      File(path.replaceAll('/', Platform.pathSeparator));
}
