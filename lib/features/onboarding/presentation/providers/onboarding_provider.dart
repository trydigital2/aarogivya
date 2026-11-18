import 'package:flutter/foundation.dart';
import 'package:aarogivya/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._repository, {required bool isCompleted})
      : _isCompleted = isCompleted;

  final OnboardingRepository _repository;
  bool _isCompleted;
  bool _isBusy = false;

  bool get isCompleted => _isCompleted;
  bool get isBusy => _isBusy;

  Future<void> complete() async {
    _isBusy = true;
    notifyListeners();
    try {
      await _repository.complete();
      _isCompleted = true;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
