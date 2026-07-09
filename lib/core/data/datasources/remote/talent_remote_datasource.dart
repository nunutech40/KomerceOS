import 'package:komtim_partner/core/data/models/talents_response.dart';

import '../../../domain/entities/talents_model.dart';
import '../../apiservice/constat_endpoint.dart';
import '../../apiservice/dio_client.dart';
import '../../apiservice/dio_response_parser.dart';

abstract class TalentRemoteDataSource {
  Future<TalentsResponse> getDataTalents();
  Future<bool> setRateTalents(List<TalentsDataModel> talents,
      List<TalentLeaderModel> leaders, int invoiceId, int amount);
  Future<bool> unhireTalents(List<TalentsUnhireDataModel> talents);
  Future<TalentsResponse> getDataEvaluationTalents({required int invoiceId});
}

class TalentRemoteDataSourceImpl implements TalentRemoteDataSource {
  final DioClient client;
  final DioResponseParser responseParser;

  TalentRemoteDataSourceImpl(
      {required this.client, required this.responseParser});

  @override
  Future<TalentsResponse> getDataTalents() async {
    final response = await client.get(Endpoints.talents);

    return responseParser.parseResponse<TalentsResponse>(
        response, (json) => TalentsResponse.fromJson(json));
  }

  @override
  Future<bool> setRateTalents(List<TalentsDataModel> talents,
      List<TalentLeaderModel> leaders, int invoiceId, int amount) async {
    List<Map<String, dynamic>> jsonTalents = talents.map((talent) {
      return {
        'job_assignee_id': talent.jobAssigneeId,
        'talent_id': talent.talentId,
        'staff_id': null, // set to null for talents
        'rating': talent.rating,
        'evaluation': talent.evaluation // set to null for talents
      };
    }).toList();

    // Map leaders to a list of Map objects, with talent_id set to null
    List<Map<String, dynamic>> jsonLeaders = leaders.map((leader) {
      return {
        'job_assignee_id':
            null, // Assuming leaders have jobAssigneeId, please replace it with the actual property if it's different
        'talent_id': null, // set to null for leaders
        'staff_id': leader
            .staffId, // Assuming leaders have staffId, please replace it with the actual property if it's different
        'rating': leader
            .rating, // Assuming leaders have rating, please replace it with the actual property if it's different
        'evaluation': leader
            .evaluation // Assuming leaders have evaluation, please replace it with the actual property if it's different
      };
    }).toList();

    // Concatenate jsonTalents and jsonLeaders to form the final list
    jsonTalents.addAll(jsonLeaders);

    // Convert the concatenated list of Maps to a JSON string
    final data = {
      'evaluations': jsonTalents,
      'invoice_id': invoiceId,
      'amount': amount
    };

    final response = await client.post(
      Endpoints.setRating,
      data: data,
    );

    return responseParser.parseResponseMeta<bool>(response, (_) => true);
  }

  @override
  Future<bool> unhireTalents(List<TalentsUnhireDataModel> talents) async {
    List<Map<String, dynamic>> jsonTalents = talents.map((talents) {
      return {
        'job_assignee_id': talents.jobAssigneeId,
        'talent_id': talents.talentId,
        'reason_quit': talents.reasonQuit,
      };
    }).toList();

    final data = {'talents': jsonTalents};

    final response = await client.post(Endpoints.unhireTalents, data: data);

    return responseParser.parseResponseMeta<bool>(
        response, (metaResponse) => true);
  }

  @override
  Future<TalentsResponse> getDataEvaluationTalents(
      {required int invoiceId}) async {
    final response = await client.get(
      '${Endpoints.talents}?invoice_id=$invoiceId',
    );

    return responseParser.parseResponse<TalentsResponse>(
        response, (json) => TalentsResponse.fromJson(json));
  }
}
