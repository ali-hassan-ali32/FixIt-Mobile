import 'package:json_annotation/json_annotation.dart';

part 'update_job_status_request.g.dart';

@JsonSerializable()
class UpdateJobStatusRequest {
  final int status;

  const UpdateJobStatusRequest({
    required this.status,
  });

  factory UpdateJobStatusRequest.fromJson(
      Map<String, dynamic> json,
      ) =>
      _$UpdateJobStatusRequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$UpdateJobStatusRequestToJson(
        this,
      );
}