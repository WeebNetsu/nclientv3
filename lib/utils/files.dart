import 'dart:io';

import 'package:archive/archive.dart';

/// Zips a list of files into a single zip file.
///
/// Takes in a list of [files] and the [zipFilePath] where the resulting zip file will be saved.
void zipFiles(List<File> files, String zipFilePath) {
  // Create a new archive to store the files
  final archive = Archive();

  for (final file in files) {
    // Read the file content as bytes
    final fileContent = file.readAsBytesSync();

    // Get the file name from the file path
    final fileName = file.path.split('/').last;

    // Create a new archive file with the file name, length, and content
    final archiveFile = ArchiveFile(fileName, fileContent.length, fileContent);

    // Add the file to the archive
    archive.addFile(archiveFile);
  }

  // Create a new zip file
  final zipFile = File(zipFilePath);

  // Encode the archive into zip file content
  final zipFileContent = ZipEncoder().encode(archive);

  // Write the zip file content to the zip file
  if (zipFileContent != null) {
    zipFile.writeAsBytesSync(zipFileContent);
  }
}

/// Unzips a zip file into a directory.
///
/// Takes in the [zipFilePath] of the zip file and the [destinationDirectoryPath] where the unzipped files will be saved.
void unzipFile(String zipFilePath, String destinationDirectoryPath) {
  // Read the zip file as bytes
  final zipFileContent = File(zipFilePath).readAsBytesSync();

  // Create a new archive from the zip file content
  final archive = ZipDecoder().decodeBytes(zipFileContent);

  // Extract each file from the archive
  for (final file in archive) {
    // Get the file path relative to the destination directory
    final filePath = '$destinationDirectoryPath/${file.name}';

    // Create the directory structure for the file
    File(filePath).createSync(recursive: true);

    // Write the file content to the disk
    File(filePath).writeAsBytesSync(file.content);
  }
}
