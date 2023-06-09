import 'package:flutter/material.dart';
import 'package:tower/ui/screens/settings_screen.dart';
import '../main.dart';

Duration updateSettingsTime = const Duration(seconds: 11);

/*
It was necessary to add 1 second to every updateSettingsTime value to
the countdown timer started from the right value
*/

class UpdateSettingsManager with ChangeNotifier{
  void switchSettingsTime(TimeBarValue timeBarValue){
    if(timeBarValue == TimeBarValue.tenSeconds){
      updateSettingsTime = const Duration(seconds: 11);
      DateTime now = DateTime.now();
      next = now.add(updateSettingsTime);
    }
    else if(timeBarValue == TimeBarValue.thirtySeconds){
      updateSettingsTime = const Duration(seconds: 31);
      DateTime now = DateTime.now();
      next = now.add(updateSettingsTime);
    }
    else if(timeBarValue == TimeBarValue.sixtySeconds){
      updateSettingsTime = const Duration(seconds: 61);
      DateTime now = DateTime.now();
      next = now.add(updateSettingsTime);
    }
    notifyListeners();
  }
}