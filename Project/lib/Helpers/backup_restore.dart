
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:hive/hive.dart';
import 'package:incognito_music/Helpers/picker.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../CustomWidgets/snack_bar.dart';

Future<void> restore(
  BuildContext context,
) async {
  final String savePath = await Picker.selectFile(
    context: context,
    // ext: ['zip'],
    message: AppLocalizations.of(context)!.selectBackFile,
  );
  final File zipFile = File(savePath);
  final Directory tempDir = await getTemporaryDirectory();
  final Directory destinationDir = Directory('${tempDir.path}/restore');

  try {
    await ZipFile.extractToDirectory(
      zipFile: zipFile,
      destinationDir: destinationDir,
    );
    final List<FileSystemEntity> files = await destinationDir.list().toList();

    for (int i = 0; i < files.length; i++) {
      final String backupPath = files[i].path;
      final String boxName = backupPath.split('/').last.replaceAll('.hive', '');
      final Box box = await Hive.openBox(boxName);
      final String boxPath = box.path!;
      await box.close();

      try {
        await File(backupPath).copy(boxPath);
      } finally {
        await Hive.openBox(boxName);
      }
    }
    destinationDir.delete(recursive: true);
    ShowSnackBar()
        .showSnackBar(context, AppLocalizations.of(context)!.importSuccess);
  } catch (e) {
    Logger.root.severe('Error in restoring backup', e);
    ShowSnackBar().showSnackBar(
      context,
      '${AppLocalizations.of(context)!.failedImport}\nError: $e',
    );
  }
}