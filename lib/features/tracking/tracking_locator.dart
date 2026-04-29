import 'package:ebus/features/tracking/data/repositories/bus_location_repository_impl.dart';
import 'package:ebus/features/tracking/domain/repositories/bus_location_repository.dart';
import 'package:ebus/features/tracking/domain/usecases/bus_location_use_cases.dart';

class TrackingLocator {
  TrackingLocator._();

  static final BusLocationRepository _repository = BusLocationRepositoryImpl();
  static final UpdateBusLocationUseCase updateBusLocationUseCase =
      UpdateBusLocationUseCase(_repository);
  static final GetBusLocationUseCase getBusLocationUseCase =
      GetBusLocationUseCase(_repository);
}