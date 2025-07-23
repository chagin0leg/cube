// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'embedded_data.dart';
import 'package:archive/archive.dart';

const String version = '0.0.0';
const String repo = 'https://github.com/chagin0leg/cube/';
const String url = '${repo}releases/latest/download/cube.exe';

void main() async {
  if (await isNewVersionAvailable()) {
    if (await waitingConfirm()) {
      print('Update confirmed! Starting update...');
      await downloadLatestVersion();
    }
    print('\nUpdate not confirmed. Continuing...');
  }

  final tar = XZDecoder().decodeBytes(base64Decode(applicationData));
  final archive = TarDecoder().decodeBytes(tar);
  final tempDir = Directory.systemTemp.createTempSync('cube_');

  for (final file in archive) {
    final filePath = '${tempDir.path}/${file.name}';
    if (file.isFile) {
      final outFile = File(filePath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    }
  }

  final batContent = '''
    @echo off
    pushd "%~dp0"
    start /B /wait cube.exe
    timeout /t 5
    popd
    rmdir /s /q "%~dp0"
  ''';

  final batFile = File('${tempDir.path}\\run.bat');
  await batFile.writeAsString(batContent);

  await Process.start('cmd', ['/c', 'start', '/B', batFile.path]);

  exit(0);
}

Future<bool> waitingConfirm({double counter = 9.9}) async {
  final c = Completer<bool>();
  final t = Timer.periodic(const Duration(milliseconds: 100), (timer) {
    stdout.write('\rUpdate is available! Update now? ');
    stdout.write('${counter.toStringAsFixed(1)}s [Y/n] ');
    if ((counter -= 0.1) < 0) c.complete(false);
  });
  final s = stdin.listen(
      (d) => c.complete(String.fromCharCodes(d).trim().toUpperCase() == 'Y'));
  return c.future.whenComplete(() => s.cancel().whenComplete(() => t.cancel()));
}

Future<void> downloadLatestVersion() async {
  final httpClient = HttpClient();

  try {
    final uri = Uri.parse(url);
    final request = await httpClient.getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final oldFile = Platform.resolvedExecutable;
      final tempDir = Directory.systemTemp.path;
      final fileName = url.split('/').last;
      final newFile = File('$tempDir\\$fileName');
      final batFile = File('$tempDir\\update_version.bat');
      final String command = '''
        @echo off
        timeout /t 5
        if exist "$oldFile" (
          del "$oldFile"
        )
        move "${newFile.path}" "$oldFile"
        start /B /wait  "" "$oldFile"
        timeout /t 5
        del "%~f0"
      ''';

      print('Save temporary application file');
      final bytes = await consolidateHttpResponse(response);
      await newFile.writeAsBytes(bytes);

      print('Create and launch update script');
      await batFile.writeAsString(command);

      print('Restart application! Goodbye.. (っ╥╯﹏╰╥c)');
      await Future.delayed(Duration(seconds: 2));
      await Process.start('cmd', ['/c', 'start', '/B', batFile.path]);
      exit(0);
    } else {
      throw Exception(
          'Не удалось скачать последнюю версию. Код ошибки: ${response.statusCode}');
    }
  } finally {
    httpClient.close();
  }
}

Future<List<int>> consolidateHttpResponse(HttpClientResponse response) {
  final completer = Completer<List<int>>();
  final contents = <int>[];

  response.listen(
    (data) => contents.addAll(data),
    onDone: () => completer.complete(contents),
    onError: (e) => completer.completeError(e),
    cancelOnError: true,
  );

  return completer.future;
}

const getTag = 'api.github.com/repos/chagin0leg/cube/releases/latest';
Future<String> getLatestVersion() async {
  print('Checking for updates...');
  final httpClient = HttpClient();

  try {
    final uri = Uri.parse('https://$getTag');
    final request = await httpClient.getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(const Utf8Decoder()).join();

      final tagRegex = RegExp(r'"tag_name"\s*:\s*"([^"]+)"');
      final match = tagRegex.firstMatch(responseBody);

      if (match != null) {
        final tagName = match.group(1) ?? '';
        final cleanVersion = tagName.replaceFirst('v', '').split('-').first;
        print("The latest Application Version is $cleanVersion");
        return cleanVersion;
      } else {
        throw Exception('Cannot find tag_name in the response.');
      }
    } else {
      throw Exception('Cannot get the last version [${response.statusCode}].');
    }
  } finally {
    httpClient.close();
  }
}

extension VersionParsing on String {
  List<int> toInt() {
    try {
      final cleaned = replaceAll(RegExp(r'[^\d.]+'), '');
      return cleaned.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    } catch (e) {
      return [0, 0, 0];
    }
  }
}

Future<bool> isNewVersionAvailable() async {
  try {
    print("Application Version is $version");
    List<int> current = version.toInt();
    final latestInfo = await getLatestReleaseInfo();

    List<int> latest = latestInfo.version.toInt();

    while (current.length < 3) current.add(0);
    while (latest.length < 3) latest.add(0);

    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) return latestInfo.hasExeAsset;
      if (current[i] > latest[i]) return false;
    }
  } catch (e) {
    print('Error checking version: $e');
  }
  return false;
}

class ReleaseInfo {
  final String version;
  final bool hasExeAsset;

  ReleaseInfo(this.version, this.hasExeAsset);
}

Future<ReleaseInfo> getLatestReleaseInfo() async {
  print('Checking for updates...');
  final httpClient = HttpClient();

  try {
    final uri = Uri.parse('https://$getTag');
    final request = await httpClient.getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(const Utf8Decoder()).join();

      final tagRegex = RegExp(r'"tag_name"\s*:\s*"([^"]+)"');
      final match = tagRegex.firstMatch(responseBody);

      if (match != null) {
        final tagName = match.group(1) ?? '';
        final cleanVersion = tagName.replaceFirst('v', '').split('-').first;

        final exeRegex = RegExp(r'"name"\s*:\s*"cube\.exe"');
        final hasExe = exeRegex.hasMatch(responseBody);

        print("Latest version: $cleanVersion, EXE available: $hasExe");
        return ReleaseInfo(cleanVersion, hasExe);
      } else {
        throw Exception('Cannot find tag_name in the response.');
      }
    } else {
      throw Exception('Cannot get the last version [${response.statusCode}].');
    }
  } finally {
    httpClient.close();
  }
}
