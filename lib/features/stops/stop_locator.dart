import 'package:ebus/features/stops/data/repositories/stop_repository_impl.dart';
import 'package:ebus/features/stops/domain/usecases/get_stops_by_route_use_case.dart';

class StopLocator {
  StopLocator._();

  static final StopRepositoryImpl _repository = StopRepositoryImpl();
  static final GetStopsByRouteUseCase getStopsByRouteUseCase =
      GetStopsByRouteUseCase(_repository);
}