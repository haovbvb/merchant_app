import 'dart:io';

Future<void> main(List<String> args) async {
  final changedFiles = await _resolveChangedFiles(args);
  if (changedFiles.isEmpty) {
    stdout.writeln('Impact policy skipped: no changed files detected.');
    return;
  }

  final coreTouched = changedFiles.any(
    (file) => file.startsWith('packages/foundation/') ||
        file.startsWith('packages/networking/') ||
        file.startsWith('packages/app_shell/'),
  );

  if (!coreTouched) {
    stdout.writeln('Impact policy passed: no core package changes.');
    return;
  }

  final hasTests = changedFiles.any(
    (file) => file.contains('/test/') && file.endsWith('.dart'),
  );

  if (!hasTests) {
    stderr.writeln(
      'Impact policy failed: core package changed but no test file was updated. '
      'Please include related tests under test/ directories.',
    );
    stderr.writeln('Changed files:');
    for (final file in changedFiles) {
      stderr.writeln('- $file');
    }
    exit(1);
  }

  stdout.writeln('Impact policy passed: core package change includes test updates.');
}

Future<List<String>> _resolveChangedFiles(List<String> args) async {
  final explicitBase = _readArg(args, '--base');
  final explicitHead = _readArg(args, '--head');

  final bases = <String>{
    if (explicitBase != null && explicitBase.isNotEmpty) explicitBase,
    if (_env('GITHUB_BASE_REF') != null) _env('GITHUB_BASE_REF')!,
    'main',
    'dev',
    'master',
  }.toList(growable: false);
  final head = explicitHead ?? 'HEAD';

  for (final base in bases) {
    final fetchResult = await Process.run(
      'git',
      ['fetch', '--no-tags', '--depth=1', 'origin', base],
      runInShell: true,
    );
    if (fetchResult.exitCode != 0) {
      continue;
    }

    final diffResult = await Process.run(
      'git',
      ['diff', '--name-only', 'origin/$base...$head'],
      runInShell: true,
    );

    if (diffResult.exitCode == 0) {
      return (diffResult.stdout as String)
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    }
  }

  stderr.writeln('Unable to compute changed files against known base branches.');
  return const [];
}

String? _readArg(List<String> args, String key) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == key && i + 1 < args.length) {
      return args[i + 1];
    }
    if (args[i].startsWith('$key=')) {
      return args[i].substring(key.length + 1);
    }
  }
  return null;
}

String? _env(String key) {
  final value = Platform.environment[key];
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return value.trim();
}
