import 'package:ebus/features/stops/data/models/stop_model.dart';
import 'package:ebus/features/stops/domain/repositories/stop_repository.dart';

class GetStopsByRouteUseCase {
  GetStopsByRouteUseCase(this._repository);

  final StopRepository _repository;

  Future<List<StopModel>> call(String routeId) {
    return _repository.getStopsByRoute(routeId);
  }
}