import 'dart:io';

import '../ext/log_ext.dart';
import '../ext/string_ext.dart';
import '../global/config.dart';
import 'download_status.dart';

class DownloadTask {
  /// Unique ID for the task
  final String id;

  /// The URI of the file to be downloaded
  final Uri uri;

  /// The priority of the task (default is 1)
  int priority;

  /// The directory where the file will be cached
  String cacheDir;

  /// The name of the file to be saved
  String saveFile;

  /// The progress of the download (0.0 to 1.0)
  double progress;

  /// The number of bytes downloaded
  int downloadedBytes;

  /// The total number of bytes to be downloaded
  int totalBytes;

  /// The status of the download (IDLE, DOWNLOADING, PAUSED, COMPLETED, CANCELLED)
  DownloadStatus status;

  /// The start range for the download request (for partial downloads)
  int startRange;

  /// The end range for the download request (for partial downloads)
  int? endRange;

  /// The headers for the download request
  Map<String, Object>? headers;

  /// The HLS key for the download (if applicable)
  String? hlsKey;

  /// The list of data chunks downloaded
  List<int> data = [];

  /// The file where the downloaded data will be saved
  File? file;

  /// Task create time
  int createAt = DateTime.now().millisecondsSinceEpoch;

  DownloadTask({
    required this.uri,
    this.priority = 1,
    String? fileName,
    this.cacheDir = "",
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.status = DownloadStatus.IDLE,
    this.startRange = 0,
    this.endRange,
    this.headers,
    this.hlsKey,
  })  : id = _autoId.toString(),
        saveFile = fileName ?? uri.toString() {
    _autoId++;
  }

  String get url => uri.toString();

  String get matchUrl {
    StringBuffer sb = StringBuffer();
    String cacheKey = Config.customCacheId.toLowerCase();
    headers = headers?.map((key, value) => MapEntry(key.toLowerCase(), value));
    if (headers != null && headers!.containsKey(cacheKey)) {
      sb.write(headers![cacheKey]);
      String path = "";
      try {
        Uri uri = saveFile.toSafeUri();
        path = uri.path;
      } catch (e) {
        path = saveFile;
      }
      sb.write(path);
    } else {
      sb.write(saveFile);
    }
    if (startRange > 0) {
      sb.write("?startRange=$startRange");
    }
    if (endRange != null) {
      sb.write("&endRange=$endRange");
    }
    return sb.toString().generateMd5;
  }

  String get saveFileName {
    String? extensionName = saveFile.split(".").lastOrNull;
    try {
      Uri uri = saveFile.toSafeUri();
      if (uri.pathSegments.isNotEmpty) {
        extensionName = uri.pathSegments.last.split(".").lastOrNull;
      }
    } catch (e) {
      logD("Uri parse error: $saveFile");
    }
    return '${matchUrl}.$extensionName';
  }

  static int _autoId = 1;

  static void resetId() {
    _autoId = 1;
  }

  void reset() {
    downloadedBytes = 0;
    totalBytes = 0;
    progress = 0.0;
    startRange = 0;
    endRange = null;
    data.clear();
  }

  @override
  String toString() {
    return 'Task [ '
        'ID: $id, '
        'URL: $uri, '
        'Status: $status, '
        'StartRange: $startRange, '
        'EndRange: $endRange, '
        'Priority: $priority, '
        'Progress: $progress, '
        'DownloadedBytes: $downloadedBytes, '
        'TotalBytes: $totalBytes, '
        'CacheDir: $cacheDir, '
        'SaveFile: $saveFile, '
        'HLSKey: $hlsKey, '
        ' ]';
  }
}
