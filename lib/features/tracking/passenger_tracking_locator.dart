import 'package:ebus/features/tracking/data/repositories/passenger_tracking_repository_impl.dart';
import 'package:ebus/features/tracking/domain/repositories/passenger_tracking_repository.dart';
import 'package:ebus/features/tracking/domain/usecases/passenger_tracking_use_cases.dart';

class PassengerTrackingLocator {
  PassengerTrackingLocator._();

  static final PassengerTrackingRepository _repository =
      PassengerTrackingRepositoryImpl();
  static final GetTrackingByRouteUseCase getTrackingByRouteUseCase =
      GetTrackingByRouteUseCase(_repository);
  static final GetActiveRoutesUseCase getActiveRoutesUseCase =
      GetActiveRoutesUseCase(_repository);
}