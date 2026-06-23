import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/lookup_repository.dart';

import 'lookup_state.dart';

@injectable
class LookupCubit extends Cubit<LookupState> {

  final LookupRepository repository;

  LookupCubit(this.repository,) : super(const LookupState.initial(),);

  Future<void> loadCities() async {

    emit(const LookupState.loading(),);

    final cities = await repository.getCities();

    debugPrint(
      'Cities Count = ${cities.length}',
    );

    for (final city in cities) {
      debugPrint(
        'City => ${city.id} | ${city.name}',
      );
    }

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

    debugPrint(
      'Categories Count = ${categories.length}',
    );

    for (final category in categories) {
      debugPrint(
        'Category => ${category.id} | ${category.name}',
      );
    }

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