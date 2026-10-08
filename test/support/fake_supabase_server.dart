import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An error an RPC should answer with, as PostgREST would.
class RpcError {
  const RpcError(this.code, this.message);

  final String code;
  final String message;
}

/// A tiny in-memory stand-in for the parts of Supabase the app talks to:
/// PostgREST tables (select, insert, update, delete with simple filters),
/// RPC functions, and Storage uploads and signed links. It sits behind a real
/// [SupabaseClient], so the app's real requests are what get checked.
class FakeSupabaseServer {
  FakeSupabaseServer() {
    client = SupabaseClient(
      'http://fake.supabase.test',
      'public-key',
      httpClient: MockClient(_handle),
    );
  }

  late final SupabaseClient client;

  /// Rows by table name.
  final tables = <String, List<Map<String, dynamic>>>{};

  /// What happened, in order: `insert quests`, `upload photos/<path>`,
  /// `update memories`, `rpc create_memory_invite`, ...
  final log = <String>[];

  /// Uploaded files by `bucket/path`, with their sizes.
  final uploads = <String, int>{};

  /// What an RPC returns, by function name. An [RpcError] is answered as
  /// that error.
  final rpcResults = <String, Object?>{};

  /// Parameters each RPC was called with.
  final rpcParams = <String, Map<String, dynamic>>{};

  /// Fails any request whose log entry this accepts, with a server error.
  bool Function(String entry)? failWhen;

  /// The status [failWhen] answers with (500 by default; 403 is what Storage
  /// says when a policy refuses an upload).
  int failStatus = 500;

  /// Makes every request fail as if the phone were offline.
  bool offline = false;

  List<Map<String, dynamic>> table(String name) =>
      tables.putIfAbsent(name, () => []);

  Iterable<String> inserts(String table) =>
      log.where((entry) => entry == 'insert $table');

  /// The real client reads `response.request`, so every answer carries it.
  Future<http.Response> _handle(http.Request request) async {
    final response = await _route(request);
    return http.Response.bytes(
      response.bodyBytes,
      response.statusCode,
      request: request,
      headers: response.headers,
    );
  }

  Future<http.Response> _route(http.Request request) async {
    if (offline) throw const SocketException('offline');

    final segments = request.url.pathSegments;
    final entry = _logEntry(request, segments);
    if (entry != null) {
      final fail = failWhen;
      log.add(entry);
      if (fail != null && fail(entry)) {
        return http.Response(
          jsonEncode({
            'message': failStatus == 403
                ? 'new row violates row-level security policy'
                : 'server error',
            'error': failStatus == 403 ? 'Unauthorized' : 'Error',
            'statusCode': '$failStatus',
          }),
          failStatus,
          headers: _json,
        );
      }
    }

    if (segments.length >= 3 && segments[0] == 'rest') {
      if (segments[2] == 'rpc') return _rpc(request, segments[3]);
      return _table(request, segments[2]);
    }
    if (segments.length >= 2 && segments[0] == 'storage') {
      return _storage(request, segments);
    }
    return http.Response('{}', 404, headers: _json);
  }

  String? _logEntry(http.Request request, List<String> segments) {
    final isRest = segments.length >= 3 && segments[0] == 'rest';
    if (isRest && segments[2] == 'rpc') return 'rpc ${segments[3]}';
    if (isRest) {
      return switch (request.method) {
        'POST' => 'insert ${segments[2]}',
        'PATCH' => 'update ${segments[2]}',
        'DELETE' => 'delete ${segments[2]}',
        _ => null,
      };
    }
    if (segments.length >= 4 &&
        segments[0] == 'storage' &&
        segments[2] == 'object' &&
        segments[3] != 'sign' &&
        segments[3] != 'list') {
      return request.method == 'DELETE'
          ? 'remove ${segments[3]}'
          : 'upload ${segments.skip(3).join('/')}';
    }
    return null;
  }

  static const _json = {'content-type': 'application/json'};

  http.Response _rpc(http.Request request, String name) {
    final decoded = request.body.isEmpty ? null : jsonDecode(request.body);
    final params = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    rpcParams[name] = params;
    final result = rpcResults[name];
    if (result is RpcError) {
      return http.Response(
        jsonEncode({
          'code': result.code,
          'message': result.message,
          'details': null,
          'hint': null,
        }),
        400,
        headers: _json,
      );
    }
    return http.Response(jsonEncode(result), 200, headers: _json);
  }

  http.Response _table(http.Request request, String name) {
    final rows = table(name);
    switch (request.method) {
      case 'GET':
        var matched = _filter(rows, request.url.queryParameters);
        final order = request.url.queryParameters['order'];
        if (order != null) {
          final column = order.split('.').first;
          final descending = order.contains('.desc');
          matched = [...matched]
            ..sort((a, b) {
              final cmp = Comparable.compare(
                a[column] as Comparable,
                b[column] as Comparable,
              );
              return descending ? -cmp : cmp;
            });
        }
        return http.Response(jsonEncode(matched), 200, headers: _json);
      case 'POST':
        final body = jsonDecode(request.body);
        rows.addAll(
          body is List
              ? [
                  for (final row in body) {...row as Map<String, dynamic>},
                ]
              : [
                  {...body as Map<String, dynamic>},
                ],
        );
        return http.Response('', 201, headers: _json);
      case 'PATCH':
        final patch = jsonDecode(request.body) as Map<String, dynamic>;
        for (final row in _filter(rows, request.url.queryParameters)) {
          row.addAll(patch);
        }
        return http.Response('', 204, headers: _json);
      case 'DELETE':
        final doomed = _filter(rows, request.url.queryParameters).toSet();
        rows.removeWhere(doomed.contains);
        return http.Response('', 204, headers: _json);
    }
    return http.Response('{}', 405, headers: _json);
  }

  /// Applies `column=eq.value` and `column=in.(a,b)` filters.
  List<Map<String, dynamic>> _filter(
    List<Map<String, dynamic>> rows,
    Map<String, String> query,
  ) {
    const reserved = {'select', 'order', 'limit', 'offset', 'columns'};
    return [
      for (final row in rows)
        if (query.entries
            .where((entry) => !reserved.contains(entry.key))
            .every((entry) => _matches(row, entry.key, entry.value)))
          row,
    ];
  }

  bool _matches(Map<String, dynamic> row, String column, String filter) {
    final value = '${row[column]}';
    if (filter.startsWith('eq.')) return value == filter.substring(3);
    if (filter.startsWith('in.(')) {
      final wanted = filter
          .substring(4, filter.length - 1)
          .split(',')
          .map((v) => v.replaceAll('"', ''));
      return wanted.contains(value);
    }
    return true;
  }

  /// Lists the files and folders directly under a prefix, like Storage does.
  http.Response _list(http.Request request, String bucket) {
    final body = jsonDecode(request.body) as Map;
    final prefix = '$bucket/${body['prefix']}/';
    final offset = (body['offset'] as num?)?.toInt() ?? 0;
    final limit = (body['limit'] as num?)?.toInt() ?? 100;
    final children = <String, bool>{};
    for (final key in uploads.keys.where((k) => k.startsWith(prefix))) {
      final rest = key.substring(prefix.length);
      final slash = rest.indexOf('/');
      children[slash == -1 ? rest : rest.substring(0, slash)] = slash != -1;
    }
    final names = children.keys.toList()..sort();
    return http.Response(
      jsonEncode([
        for (final name in names.skip(offset).take(limit))
          {'name': name, 'id': children[name]! ? null : 'id-$name'},
      ]),
      200,
      headers: _json,
    );
  }

  http.Response _storage(http.Request request, List<String> segments) {
    // /storage/v1/object/sign/<bucket>  -> signed links
    if (segments.length >= 4 &&
        segments[2] == 'object' &&
        segments[3] == 'sign') {
      final bucket = segments[4];
      final paths = (jsonDecode(request.body) as Map)['paths'] as List;
      return http.Response(
        jsonEncode([
          for (final path in paths)
            {'path': path, 'signedURL': '/object/sign/$bucket/$path?token=t'},
        ]),
        200,
        headers: _json,
      );
    }
    // /storage/v1/object/list/<bucket>  -> one folder level
    if (segments.length >= 5 &&
        segments[2] == 'object' &&
        segments[3] == 'list') {
      return _list(request, segments[4]);
    }
    // DELETE /storage/v1/object/<bucket>  -> remove the listed paths
    if (segments.length == 4 &&
        segments[2] == 'object' &&
        request.method == 'DELETE') {
      final bucket = segments[3];
      final prefixes = (jsonDecode(request.body) as Map)['prefixes'] as List;
      for (final path in prefixes) {
        uploads.remove('$bucket/$path');
        log.add('removed $bucket/$path');
      }
      return http.Response(
        jsonEncode([
          for (final path in prefixes) {'name': path},
        ]),
        200,
        headers: _json,
      );
    }
    // /storage/v1/object/<bucket>/<path...>  -> upload
    if (segments.length >= 4 && segments[2] == 'object') {
      final key = segments.skip(3).join('/');
      uploads[key] = request.bodyBytes.length;
      return http.Response(
        jsonEncode({'Key': key, 'Id': 'id-$key'}),
        200,
        headers: _json,
      );
    }
    return http.Response('{}', 404, headers: _json);
  }
}
