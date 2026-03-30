import 'dart:io';

void main(List<String> args) {
  final minOverall = _readMinOverall(args);
  final root = Directory.current;
  final lcovFiles = _findLcovFiles(root);

  if (lcovFiles.isEmpty) {
    stderr.writeln('No coverage/lcov.info files found. Run tests with coverage first.');
    exit(2);
  }

  var totalLf = 0;
  var totalLh = 0;
  final packageStats = <String, _Stat>{};

  for (final lcovFile in lcovFiles) {
    final records = _parseLcov(lcovFile);
    for (final record in records) {
      totalLf += record.lf;
      totalLh += record.lh;

      final packageName = _resolvePackageName(root.path, record.sf);
      final stat = packageStats.putIfAbsent(packageName, () => _Stat());
      stat.lf += record.lf;
      stat.lh += record.lh;
    }
  }

  if (totalLf == 0) {
    stderr.writeln('Coverage files were found but contain zero executable lines (LF=0).');
    exit(2);
  }

  final overall = totalLh / totalLf * 100;
  stdout.writeln('Coverage summary:');
  stdout.writeln('- Overall line coverage: ${overall.toStringAsFixed(2)}% (LH=$totalLh, LF=$totalLf)');

  final sortedPackages = packageStats.keys.toList()..sort();
  for (final pkg in sortedPackages) {
    final stat = packageStats[pkg]!;
    if (stat.lf == 0) {
      continue;
    }
    final ratio = stat.lh / stat.lf * 100;
    stdout.writeln('  - $pkg: ${ratio.toStringAsFixed(2)}% (LH=${stat.lh}, LF=${stat.lf})');
  }

  if (overall < minOverall) {
    stderr.writeln(
      'Overall line coverage ${overall.toStringAsFixed(2)}% is below threshold ${minOverall.toStringAsFixed(2)}%.',
    );
    exit(1);
  }

  stdout.writeln('Coverage baseline passed (min ${minOverall.toStringAsFixed(2)}%).');
}

double _readMinOverall(List<String> args) {
  for (final arg in args) {
    if (!arg.startsWith('--min-overall-line=')) {
      continue;
    }
    final value = arg.split('=').last;
    final parsed = double.tryParse(value);
    if (parsed == null || parsed < 0 || parsed > 100) {
      stderr.writeln('Invalid --min-overall-line value: $value');
      exit(2);
    }
    return parsed;
  }
  return 0;
}

List<File> _findLcovFiles(Directory root) {
  final result = <File>[];
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('/coverage/lcov.info')) {
      result.add(entity);
    }
  }
  return result;
}

List<_Record> _parseLcov(File file) {
  final records = <_Record>[];
  String? sf;
  int? lf;
  int? lh;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      sf = line.substring(3).trim();
    } else if (line.startsWith('LF:')) {
      lf = int.tryParse(line.substring(3).trim());
    } else if (line.startsWith('LH:')) {
      lh = int.tryParse(line.substring(3).trim());
    } else if (line == 'end_of_record') {
      if (sf != null && lf != null && lh != null) {
        records.add(_Record(sf: sf, lf: lf, lh: lh));
      }
      sf = null;
      lf = null;
      lh = null;
    }
  }

  return records;
}

String _resolvePackageName(String rootPath, String sourceFile) {
  final normalizedRoot = rootPath.endsWith('/') ? rootPath : '$rootPath/';
  final normalizedSource = sourceFile.replaceAll('\\\\', '/');

  final pkgMatch = RegExp(r'/packages/([^/]+)/').firstMatch(normalizedSource);
  if (pkgMatch != null) {
    return pkgMatch.group(1)!;
  }

  if (normalizedSource.startsWith(normalizedRoot) || normalizedSource.contains('/lib/')) {
    return 'app';
  }

  return 'unknown';
}

class _Record {
  _Record({
    required this.sf,
    required this.lf,
    required this.lh,
  });

  final String sf;
  final int lf;
  final int lh;
}

class _Stat {
  int lf = 0;
  int lh = 0;
}
