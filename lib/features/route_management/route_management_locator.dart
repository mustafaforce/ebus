import 'package:ebus/features/route_management/data/repositories/route_management_repository_impl.dart';
import 'package:ebus/features/route_management/domain/repositories/route_management_repository.dart';
import 'package:ebus/features/route_management/domain/usecases/create_route_use_case.dart';
import 'package:ebus/features/route_management/domain/usecases/delete_route_use_case.dart';
import 'package:ebus/features/route_management/domain/usecases/update_route_use_case.dart';

class RouteManagementLocator {
  RouteManagementLocator._();

  static final RouteManagementRepository _repository =
      RouteManagementRepositoryImpl();
  static final CreateRouteUseCase createRouteUseCase =
      CreateRouteUseCase(_repository);
  static final UpdateRouteUseCase updateRouteUseCase =
      UpdateRouteUseCase(_repository);
  static final DeleteRouteUseCase deleteRouteUseCase =
      DeleteRouteUseCase(_repository);
}
