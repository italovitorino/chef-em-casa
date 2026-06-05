import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'briefing_dto.dart';

class BriefingRepository {
  final Dio _dio;

  BriefingRepository(this._dio);

  Future<BriefingResponse> publish(CreateBriefingRequest request) async {
    try {
      final res = await _dio.post(
        '/api/briefings',
        data: request.toJson(),
      );
      return BriefingResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }
}

final briefingRepositoryProvider = Provider<BriefingRepository>(
  (ref) => BriefingRepository(ref.read(dioClientProvider)),
);
