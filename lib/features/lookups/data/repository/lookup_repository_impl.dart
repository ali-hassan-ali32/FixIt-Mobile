import 'package:injectable/injectable.dart';

import '../../api/services/lookup_api_service.dart';
import '../../domain/entities/lookup_item_entity.dart';
import '../../domain/repositories/lookup_repository.dart';


@Injectable(as: LookupRepository)
class LookupRepositoryImpl
    implements LookupRepository {

  final LookupApiService api;

  LookupRepositoryImpl(this.api);

  @override
  Future<List<LookupItemEntity>>
  getCities() async {

    final result =
    await api.getCities();

    return result
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<List<LookupItemEntity>>
  getRegions(
      String cityId,
      ) async {

    final result =
    await api.getRegions(
      cityId,
    );

    return result
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<List<LookupItemEntity>>
  getCategories() async {

    final result =
    await api.getCategories();

    return result
        .map((e) => e.toEntity())
        .toList();
  }
}