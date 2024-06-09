library;

import 'dart:developer';
import 'dart:io';

import 'package:code_guard/logger.dart';

bool kDebugMode = false;

class CodeGuard {
  final List<String> matches = [];
  final List<String> patterns;
  final List<String> targetFileTypes;
  final List<String> explicitIgnoreSubType;
  final List<String> explicitIgnoreFolder;

  CodeGuard({
    required this.patterns,
    required this.targetFileTypes,
    required this.explicitIgnoreSubType,
    required this.explicitIgnoreFolder,
  });

  Future<List<File>> getFilesFromDirectory({required List<FileSystemEntity> entities}) async {
    final List<File> files = [];

    for (var element in entities) {
      if (element is Directory) {
        bool ignoreFolder = false;
        for (var folder in explicitIgnoreFolder) {
          if (ignoreFolder) continue;
          ignoreFolder = element.path.contains(RegExp('.*$folder.*'));
        }
        if (ignoreFolder) {
          ignoreFolder = false;
          continue;
        }
        Logger.l(message: 'Folder included:${element.path}');
        files.addAll(await getFilesFromDirectory(entities: await element.list().toList()));
      }
      if (element is File) {
        if (isTargetFileType(file: element, targetFileTypes: targetFileTypes, explicitIgnoreSubType: explicitIgnoreSubType)) files.add(element);
      }
    }

    return files;
  }

  Future<List<String>> findMatches({required File file}) async {
    Logger.d(message: 'Check matches in: ${file.path}');

    final List<String> matches = [];
    try {
      var fileContent = file.readAsLinesSync();
      int lineCount = 1;
      for (var line in fileContent) {
        final hasMatcher = _hasMatcher(line: line, patterns: patterns);
        if (hasMatcher) {
          matches.add('File: ${file.path}:$lineCount');
          matches.add(line.trim());
          Logger.w(message: 'Found matcher in ${file.path} line: $lineCount -  ${line.trim()}');
        }
        lineCount++;
      }
    } catch (e) {
      log(e.toString());
    }
    return matches;
  }

  bool isTargetFileType({required File file, required List<String> targetFileTypes, List<String> explicitIgnoreSubType = const []}) {
    bool isTargetFileType = false;
    for (var ignoreType in explicitIgnoreSubType) {
      if (file.path.contains(ignoreType)) return false;
    }
    final path = file.path.split('.');
    if (path.isEmpty) {
      return isTargetFileType;
    } else {
      final extension = path.last;

      for (var fileType in targetFileTypes) {
        if (isTargetFileType) return isTargetFileType;
        isTargetFileType = extension.contains(fileType);
      }
      return isTargetFileType;
    }
  }

  bool _hasMatcher({required String line, required List<String> patterns}) {
    bool hasMatch = false;
    for (var pattern in patterns) {
      if (hasMatch) return hasMatch;
      hasMatch = line.toLowerCase().contains(RegExp('.*${pattern.toLowerCase()}.*'));
    }
    return hasMatch;
  }
}
