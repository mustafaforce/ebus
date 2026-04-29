import 'package:ebus/features/stops/data/models/stop_model.dart';

class StopService {
  StopService._();

  static final StopService _instance = StopService._();
  static StopService get instance => _instance;

  StopModel? _selectedStop;
  StopModel? get selectedStop => _selectedStop;

  bool get hasStop => _selectedStop != null;

  void setStop(StopModel stop) {
    _selectedStop = stop;
  }

  void clearStop() {
    _selectedStop = null;
  }
}