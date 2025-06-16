import 'dart:async';
import 'dart:io';

import 'package:flutter_hls_parser/flutter_hls_parser.dart';

import '../ext/string_ext.dart';
import '../ext/uri_ext.dart';
import 'url_parser.dart';
import 'url_parser_factory.dart';
import 'url_parser_m3u8.dart';

class VideoCaching {
  /// Parse the URL and cache the video
  static Future<void> parse(
    Socket socket,
    Uri uri,
    Map<String, String> headers,
  ) async {
    await UrlParserFactory.createParser(uri).parse(socket, uri, headers);
  }

  /// Precache the video URL
  ///
  /// [url]: The URL to be precached.<br>
  /// [cacheSegments]: The number of segments to be cached, default is 2.<br>
  /// [downloadNow]: Whether to download the segments now, default is true, false will be pushed to the queue.
  static Future<StreamController<Map>?> precache(
    String url, {
    Map<String, Object>? headers,
    int cacheSegments = 2,
    bool downloadNow = true,
    bool progressListen = false,
  }) {
    return UrlParserFactory.createParser(url.toSafeUri())
        .precache(url, headers, cacheSegments, downloadNow, progressListen);
  }

  /// Parse the HLS master playlist from the given URL.
  ///
  /// [url]: The URL of the HLS master playlist.
  ///
  /// Returns an instance of [HlsMasterPlaylist] if successful, otherwise returns null.
  static Future<HlsMasterPlaylist?> parseHlsMasterPlaylist(
    String url, {
    Map<String, Object>? headers,
  }) async {
    Uri uri = url.toSafeUri();
    UrlParser parser = UrlParserFactory.createParser(uri);
    if (parser is! UrlParserM3U8) return null;
    HlsPlaylist? playlist = await parser.parsePlaylist(uri,
        headers: headers, hlsKey: uri.generateMd5);
    return playlist is HlsMasterPlaylist ? playlist : null;
  }
}
