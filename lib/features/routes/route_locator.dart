import 'package:ebus/features/routes/data/repositories/route_repository_impl.dart';
import 'package:ebus/features/routes/domain/usecases/get_active_routes_use_case.dart';

class RouteLocator {
  RouteLocator._();

  static final RouteRepositoryImpl _repository = RouteRepositoryImpl();
  static final GetActiveRoutesUseCase getActiveRoutesUseCase =
      GetActiveRoutesUseCase(_repository);
}