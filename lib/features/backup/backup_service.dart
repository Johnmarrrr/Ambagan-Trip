import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

class BackupService {
  Future<File> _getDbFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'ambagan.sqlite'));
  }

  Future<void> backupDatabase() async {
    try {
      final dbFile = await _getDbFile();
      if (!await dbFile.exists()) {
        throw Exception('Database file not found.');
      }
      
      await Share.shareXFiles([XFile(dbFile.path)], text: 'Ambagan Trip Backup');
    } catch (e) {
      throw Exception('Failed to backup: $e');
    }
  }

  Future<void> restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final backupFile = File(result.files.single.path!);
        final dbFile = await _getDbFile();
        
        // Overwrite the current database file
        await backupFile.copy(dbFile.path);
        
      }
    } catch (e) {
      throw Exception('Failed to restore: $e');
    }
  }
}
