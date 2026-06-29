import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'briefing_dto.dart';

class BriefingRepository {
  final Dio _dio;

  BriefingRepository(this._dio);

  Future<List<BriefingListItem>> list() async {
    try {
      final res = await _dio.get('/api/briefings');
      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(BriefingListItem.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao carregar briefings.');
    }
  }

  Future<BriefingDetailResponse> getById(String id) async {
    try {
      final res = await _dio.get('/api/briefings/$id');
      return BriefingDetailResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao carregar briefing.');
    }
  }

  Future<BriefingDetailResponse> close(String id) async {
    try {
      final res = await _dio.post('/api/briefings/$id/close');
      return BriefingDetailResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao fechar briefing.');
    }
  }

  Future<void> expressInterest(String briefingId, {String? message}) async {
    try {
      await _dio.post(
        '/api/briefings/$briefingId/interests',
        data: {'message': message},
      );
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao expressar interesse.');
    }
  }

  Future<BriefingResponse> publish(CreateBriefingRequest request) async {
    try {
      final res = await _dio.post(
        '/api/briefings',
        data: request.toJson(),
      );
      return BriefingResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao processar resposta do servidor.');
    }
  }
}

final briefingRepositoryProvider = Provider<BriefingRepository>(
  (ref) => BriefingRepository(ref.read(dioClientProvider)),
);
