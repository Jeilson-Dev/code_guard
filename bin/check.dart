import 'dart:io';

import 'package:check/code_guard.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  if (args.contains('-d')) {
    kDebugMode = true;
  }

  var checkConfig = join(Directory.current.path, 'check.yaml');
  final yaml = File(checkConfig);

  List<String> patterns = [];
  List<String> targetFileTypes = [];
  List<String> explicitIgnoreSubType = [];
  List<String> explicitIgnoreFolder = [];

  if (await yaml.exists()) {
    var fileContent = await yaml.readAsString();

    var doc = loadYaml(fileContent);

    final patternsYaml = doc['patterns'] ?? [];
    final targetFileTypesYaml = doc['targetFileTypes'] ?? [];
    final explicitIgnoreSubTypeYaml = doc['explicitIgnoreSubType'] ?? [];
    final explicitIgnoreFolderYaml = doc['explicitIgnoreFolder'] ?? [];

    patterns = (patternsYaml as List).map((item) => item.toString()).toList();
    targetFileTypes = (targetFileTypesYaml as List).map((item) => item.toString()).toList();
    explicitIgnoreSubType = (explicitIgnoreSubTypeYaml as List).map((item) => item.toString()).toList();
    explicitIgnoreFolder = (explicitIgnoreFolderYaml as List).map((item) => item.toString()).toList();
  }

  print('');
  print('💡 \u001b[36mLooking for these patterns: \u001b[33m$patterns\x1B[0m');
  if (targetFileTypes.isNotEmpty) print('💡 \u001b[36mFiltering files by filetypes: \u001b[33m$targetFileTypes\x1B[0m');
  if (explicitIgnoreSubType.isNotEmpty) print('💡 \u001b[36mIgnoring corresponding subtypes: \u001b[33m$explicitIgnoreSubType\x1B[0m');
  if (explicitIgnoreFolder.isNotEmpty) print('💡 \u001b[36mIgnoring folders: \u001b[33m$explicitIgnoreFolder\x1B[0m');
  print('');
  final codeGuard = CodeGuard(
    patterns: patterns,
    targetFileTypes: targetFileTypes,
    explicitIgnoreSubType: explicitIgnoreSubType,
    explicitIgnoreFolder: explicitIgnoreFolder,
  );
  final files = await codeGuard.getFilesFromDirectory(entities: await Directory.current.list().toList());

  for (var file in files) {
    codeGuard.matches.addAll(await codeGuard.findMatches(file: file));
  }

  if (codeGuard.matches.isNotEmpty) {
    for (var element in codeGuard.matches) {
      print('\u001b[31m$element\x1B[0m');
    }
    exitCode = 1;
  } else {
    print('\u001b[32mSuccess, no matches found!\x1B[0m');
  }
}
