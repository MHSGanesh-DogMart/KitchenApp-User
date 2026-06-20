import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';
import 'api_exception.dart';
import 'connectivity_service.dart';

typedef UnauthorizedHandler = Future<void> Function();

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        responseType: ResponseType.json,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(_authInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (o) => AppLogger.d(o.toString()),
      ));
    }
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  Dio get dio => _dio;

  UnauthorizedHandler? _onUnauthorized;
  void setUnauthorizedHandler(UnauthorizedHandler handler) {
    _onUnauthorized = handler;
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.instance.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await _onUnauthorized?.call();
        }
        handler.next(e);
      },
    );
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) =>
      _wrap(() => _dio.get(path, queryParameters: query, cancelToken: cancelToken));

  Future<Response<dynamic>> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    CancelToken? cancelToken,
  }) =>
      _wrap(() => _dio.post(path, data: body, queryParameters: query, cancelToken: cancelToken));

  Future<Response<dynamic>> put(
    String path, {
    dynamic body,
    CancelToken? cancelToken,
  }) =>
      _wrap(() => _dio.put(path, data: body, cancelToken: cancelToken));

  Future<Response<dynamic>> patch(
    String path, {
    dynamic body,
    CancelToken? cancelToken,
  }) =>
      _wrap(() => _dio.patch(path, data: body, cancelToken: cancelToken));

  Future<Response<dynamic>> delete(
    String path, {
    dynamic body,
    CancelToken? cancelToken,
  }) =>
      _wrap(() => _dio.delete(path, data: body, cancelToken: cancelToken));

  Future<Response<dynamic>> _wrap(Future<Response<dynamic>> Function() fn) async {
    if (!await ConnectivityService.instance.isOnline()) {
      throw const NoInternetException();
    }
    try {
      return await fn();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on SocketException {
      throw const NoInternetException();
    } catch (e) {
      AppLogger.e('Unknown API error: $e');
      throw const UnknownApiException();
    }
  }

  ApiException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutApiException();
      case DioExceptionType.cancel:
        return const CancelledException();
      case DioExceptionType.connectionError:
        return const NoInternetException();
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        final msg = _extractMessage(e.response?.data) ??
            'Request failed ($code)';
        if (code == 401) return UnauthorizedException(msg);
        if (code == 400 || code == 422) {
          return BadRequestException(msg, raw: e.response?.data);
        }
        if (code >= 500) return ServerException(msg);
        return ApiException(msg, statusCode: code, raw: e.response?.data);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (e.error is SocketException) return const NoInternetException();
        return UnknownApiException(e.message ?? 'Something went wrong');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      return (data['message'] ?? data['msg'] ?? data['error'])?.toString();
    }
    return null;
  }

  // ---------- Multipart ----------

  Future<List<String>> uploadImages({
    required String path,
    required List<File> files,
    String folder = 'uploads',
    String fieldName = 'images',
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (files.isEmpty) return [];
    if (!await ConnectivityService.instance.isOnline()) {
      throw const NoInternetException();
    }

    final multipart = await Future.wait(files.asMap().entries.map((entry) async {
      final i = entry.key;
      final file = entry.value;
      final mime = lookupMimeType(file.path) ?? 'image/jpeg';
      final parts = mime.split('/');
      return await MultipartFile.fromFile(
        file.path,
        filename:
            'img_${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}',
        contentType: MediaType(parts[0], parts.length > 1 ? parts[1] : 'jpeg'),
      );
    }));

    final form = FormData.fromMap({
      'folder': folder,
      fieldName: multipart,
    });

    try {
      final res = await _dio.post(
        path,
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
        options: Options(sendTimeout: AppConfig.uploadTimeout),
      );
      final data = res.data;
      if (data is Map) {
        if (data['files'] is List) {
          return (data['files'] as List)
              .map((f) => (f['fileName'] ?? '').toString())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        if (data['fileName'] is List) {
          return List<String>.from(data['fileName']);
        }
      }
      return [];
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, String>?> uploadImage({
    required String path,
    required File file,
    String folder = 'uploads',
    String fieldName = 'image',
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (!await ConnectivityService.instance.isOnline()) {
      throw const NoInternetException();
    }

    final mime = lookupMimeType(file.path) ?? 'image/jpeg';
    final parts = mime.split('/');
    final form = FormData.fromMap({
      'folder': folder,
      fieldName: await MultipartFile.fromFile(
        file.path,
        filename:
            'img_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
        contentType: MediaType(parts[0], parts.length > 1 ? parts[1] : 'jpeg'),
      ),
    });

    try {
      final res = await _dio.post(
        path,
        data: form,
        cancelToken: cancelToken,
        onSendProgress: onProgress,
        options: Options(sendTimeout: AppConfig.uploadTimeout),
      );
      final data = res.data;
      if (data is Map) {
        final fileName = (data['fileName'] ?? data['data']?['fileName'])?.toString();
        final fileUrl = (data['fileUrl'] ?? data['data']?['fileUrl'])?.toString();
        if (fileName != null && fileUrl != null) {
          return {'fileName': fileName, 'fileUrl': fileUrl};
        }
      }
      return null;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<String?> downloadFile({
    required String url,
    required String fileName,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!await ConnectivityService.instance.isOnline()) {
      throw const NoInternetException();
    }
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      await _dio.download(
        url,
        filePath,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
      );
      return filePath;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }
}
