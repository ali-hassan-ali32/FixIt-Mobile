import '../entities/lookup_item_entity.dart';

abstract class LookupRepository {

  Future<List<LookupItemEntity>>
  getCities();

  Future<List<LookupItemEntity>>
  getRegions(String cityId);

  Future<List<LookupItemEntity>>
  getCategories();
}