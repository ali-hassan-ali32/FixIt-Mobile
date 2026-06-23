import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/lookup_item_entity.dart';

part 'lookup_state.freezed.dart';

@freezed
class LookupState with _$LookupState {

  const factory LookupState.initial() =
  LookupInitial;

  const factory LookupState.loading() =
  LookupLoading;

  const factory LookupState.loaded({
    @Default([])
    List<LookupItemEntity> cities,

    @Default([])
    List<LookupItemEntity> regions,

    @Default([])
    List<LookupItemEntity> categories,
  }) = LookupLoaded;

  const factory LookupState.error(
      String message,
      ) = LookupError;
}