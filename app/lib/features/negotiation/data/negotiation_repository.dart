import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/app_exception.dart';
import '../../../core/network/dio_client.dart';
import 'negotiation_dto.dart';

class NegotiationRepository {
  final Dio _dio;

  NegotiationRepository(this._dio);

  Future<NegotiationResponse> start(
      String briefingId, String chefId) async {
    try {
      final res = await _dio.post(
        '/api/briefings/$briefingId/negotiations',
        data: StartNegotiationRequest(chefId: chefId).toJson(),
      );
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao iniciar negociação.');
    }
  }

  Future<List<NegotiationListItem>> listForBriefing(String briefingId) async {
    try {
      final res =
          await _dio.get('/api/briefings/$briefingId/negotiations');
      final data = res.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(NegotiationListItem.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao listar negociações.');
    }
  }

  Future<NegotiationResponse> getById(String id) async {
    try {
      final res = await _dio.get('/api/negotiations/$id');
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao carregar negociação.');
    }
  }

  Future<NegotiationResponse> accept(String id) async {
    try {
      final res = await _dio.post('/api/negotiations/$id/proposals/accept');
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao aceitar proposta.');
    }
  }

  Future<NegotiationResponse> reject(String id) async {
    try {
      final res = await _dio.post('/api/negotiations/$id/proposals/reject');
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao rejeitar proposta.');
    }
  }

  Future<NegotiationResponse> requestRevision(String id) async {
    try {
      final res =
          await _dio.post('/api/negotiations/$id/proposals/request-revision');
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao solicitar revisão.');
    }
  }

  Future<NegotiationResponse> complete(String id) async {
    try {
      final res = await _dio.post('/api/negotiations/$id/complete');
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao concluir serviço.');
    }
  }

  Future<NegotiationResponse> cancel(String id) async {
    try {
      final res = await _dio.post('/api/negotiations/$id/cancel');
      return NegotiationResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (_) {
      throw const AppException('Erro ao cancelar negociação.');
    }
  }
}

final negotiationRepositoryProvider = Provider<NegotiationRepository>(
  (ref) => NegotiationRepository(ref.read(dioClientProvider)),
);
