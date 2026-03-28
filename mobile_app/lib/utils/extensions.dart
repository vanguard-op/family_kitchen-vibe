import 'package:dio/dio.dart';
import 'package:family_kitchen/utils/exceptions.dart';

extension DioExceptionExtension on DioException {
  AppException toAppException() {
    return AppException(
      response?.data['detail'] ?? 'An error occurred',
      code: response?.statusCode,
      details: toString(),
    );
  }
}
