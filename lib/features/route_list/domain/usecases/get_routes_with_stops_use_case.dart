import 'package:ebus/features/route_list/data/models/route_with_stops_model.dart';
import 'package:ebus/features/route_list/domain/repositories/route_list_repository.dart';

class GetRoutesWithStopsUseCase {
  GetRoutesWithStopsUseCase(this._repository);

  final RouteListRepository _repository;

  Future<List<RouteWithStopsModel>> call() {
    return _repository.getRoutesWithStops();
  }
}