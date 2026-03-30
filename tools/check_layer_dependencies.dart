import 'dart:io';

void main() {
  final root = Directory.current;
  final packagesDir = Directory('${root.path}/packages');

  if (!packagesDir.existsSync()) {
    stderr.writeln('packages directory not found: ${packagesDir.path}');
    exit(2);
  }

  final packageDirs = packagesDir
      .listSync()
      .whereType<Directory>()
      .where((dir) => File('${dir.path}/pubspec.yaml').existsSync())
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final packageToDir = <String, Directory>{};
  final packageDeps = <String, Set<String>>{};
  final violations = <String>[];

  for (final dir in packageDirs) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    final name = _readPackageName(pubspec);
    if (name == null) {
      violations.add('Unable to parse package name in ${_rel(root.path, pubspec.path)}');
      continue;
    }
    packageToDir[name] = dir;
  }

  for (final entry in packageToDir.entries) {
    final pubspec = File('${entry.value.path}/pubspec.yaml');
    packageDeps[entry.key] = _readInternalDeps(
      pubspec: pubspec,
      internalNames: packageToDir.keys.toSet(),
    );
  }

  final featurePackages = packageToDir.keys.where((e) => e.startsWith('feature_')).toSet();
  const basePackages = {'foundation', 'networking', 'design_system'};

  for (final entry in packageDeps.entries) {
    final packageName = entry.key;
    final deps = entry.value;

    if (basePackages.contains(packageName)) {
      final forbidden = deps.where((dep) => dep == 'app_shell' || featurePackages.contains(dep)).toList();
      if (forbidden.isNotEmpty) {
        violations.add(
          '$packageName must not depend on app_shell/feature packages, found: ${forbidden.join(', ')}',
        );
      }
    }

    if (featurePackages.contains(packageName) && deps.contains('app_shell')) {
      violations.add('$packageName must not depend on app_shell directly.');
    }
  }

  for (final entry in packageToDir.entries) {
    final packageName = entry.key;
    final dartFiles = _findDartFiles(entry.value);
    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final match = RegExp("package:([a-zA-Z0-9_]+)/src/").firstMatch(line);
        if (match == null) {
          continue;
        }
        final targetPackage = match.group(1)!;
        final isWorkspacePackage = packageToDir.containsKey(targetPackage);
        final isSamePackage = targetPackage == packageName;
        if (isWorkspacePackage && !isSamePackage) {
          violations.add(
            'Cross-package src import is forbidden: ${_rel(root.path, file.path)}:${i + 1} -> $line',
          );
        }
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Dependency boundary check failed (${violations.length}):');
    for (final violation in violations) {
      stderr.writeln('- $violation');
    }
    exit(1);
  }

  stdout.writeln('Dependency boundary check passed for ${packageToDir.length} packages.');
}

String? _readPackageName(File pubspec) {
  final content = pubspec.readAsStringSync();
  final match = RegExp(r'^name:\s*([a-zA-Z0-9_]+)\s*$', multiLine: true).firstMatch(content);
  return match?.group(1);
}

Set<String> _readInternalDeps({
  required File pubspec,
  required Set<String> internalNames,
}) {
  final deps = <String>{};
  final lines = pubspec.readAsLinesSync();

  var inSection = false;
  for (final rawLine in lines) {
    final line = rawLine.replaceAll('\t', '    ');

    if (RegExp(r'^(dependencies|dev_dependencies|dependency_overrides):\s*$').hasMatch(line)) {
      inSection = true;
      continue;
    }

    if (inSection && RegExp(r'^[a-zA-Z_]').hasMatch(line)) {
      inSection = false;
    }

    if (!inSection) {
      continue;
    }

    final match = RegExp(r'^\s{2}([a-zA-Z0-9_]+):\s*$').firstMatch(line);
    if (match == null) {
      continue;
    }

    final depName = match.group(1)!;
    if (internalNames.contains(depName)) {
      deps.add(depName);
    }
  }

  return deps;
}

List<File> _findDartFiles(Directory packageDir) {
  final result = <File>[];
  for (final entity in packageDir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    if (entity.path.contains('/build/')) {
      continue;
    }
    result.add(entity);
  }
  return result;
}

String _rel(String root, String fullPath) {
  final prefix = '$root/';
  return fullPath.startsWith(prefix) ? fullPath.substring(prefix.length) : fullPath;
}
