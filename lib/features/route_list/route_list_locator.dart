import 'package:ebus/features/route_list/data/repositories/route_list_repository_impl.dart';
import 'package:ebus/features/route_list/domain/repositories/route_list_repository.dart';
import 'package:ebus/features/route_list/domain/usecases/get_routes_with_stops_use_case.dart';

class RouteListLocator {
  RouteListLocator._();

  static final RouteListRepository _repository = RouteListRepositoryImpl();
  static final GetRoutesWithStopsUseCase getRoutesWithStopsUseCase =
      GetRoutesWithStopsUseCase(_repository);
}