import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/lookup_item_entity.dart';
import '../../domain/repositories/lookup_repository.dart';
import 'lookup_state.dart';

@injectable
class LookupCubit extends Cubit<LookupState> {

  final LookupRepository repository;

  LookupCubit(this.repository,) : super(const LookupState.initial(),);


  List<LookupItemEntity> get categories {
    if (state is LookupLoaded) {
      return (state as LookupLoaded).categories;
    }

    return [];
  }

  Future<void> loadCities() async {

    emit(const LookupState.loading(),);

    final cities = await repository.getCities();

    emit(
      LookupState.loaded(
        cities: cities,
      ),
    );
  }

  Future<void> loadRegions(String cityId,) async {

    final current =
    state as LookupLoaded;

    final regions = await repository.getRegions(cityId);

    emit(current.copyWith(regions: regions,),);
  }

  Future<void> loadCategories() async {

    final categories =
    await repository.getCategories();

    if (state is LookupLoaded) {

      final current =
      state as LookupLoaded;

      emit(
        current.copyWith(
          categories: categories,
        ),
      );

    } else {

      emit(
        LookupState.loaded(
          categories: categories,
        ),
      );

    }
  }
}