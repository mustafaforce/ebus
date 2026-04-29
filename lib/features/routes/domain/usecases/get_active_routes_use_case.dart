import 'package:ebus/features/routes/data/models/route_model.dart';
import 'package:ebus/features/routes/domain/repositories/route_repository.dart';

class GetActiveRoutesUseCase {
  GetActiveRoutesUseCase(this._repository);

  final RouteRepository _repository;

  Future<List<RouteModel>> call() {
    return _repository.getActiveRoutes();
  }
}