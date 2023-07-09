import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier{

  ThemeMode _theme = ThemeMode.light;

  get theme => _theme;

 void switchTheme(int value){
   if(value == 1){
     var systemTheme = WidgetsBinding.instance.platformDispatcher.platformBrightness;
     if( systemTheme == Brightness.dark ){
       _theme = ThemeMode.dark;
     }else{
       _theme = ThemeMode.light;
     }
   }
   else if(value == 2){
     _theme = ThemeMode.light;
   }else if(value == 3){
     _theme = ThemeMode.dark;
   }
    notifyListeners();
  }
}