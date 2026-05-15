import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/raid_entity.dart';
import '../../domain/repositories/raid_repository.dart';
import 'raid_state.dart';

class RaidCubit extends Cubit<RaidState> {
  RaidCubit(this._repository) : super(const RaidState()) {
    _watchRaid();
  }

  final RaidRepository _repository;

  StreamSubscription<RaidEntity>? _raidSubscription;

  void _watchRaid() {
    _raidSubscription = _repository.watchRaid().listen(
      (RaidEntity raid) {
        emit(state.copyWith(raid: raid));
      },
      onError: (Object error) {
        emit(state.copyWith(errorMessage: error.toString()));
      },
    );
  }

  Future<void> joinRaid({required String userId}) async {
    emit(state.copyWith(isLoading: true));

    try {
      final bool success = await _repository.joinRaid(userId: userId);

      emit(state.copyWith(isLoading: false, joinSuccess: success));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> resetRaid() async {
    try {
      await _repository.resetRaid();
      emit(state.copyWith(resetSuccess: true));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _raidSubscription?.cancel();
    return super.close();
  }
}
