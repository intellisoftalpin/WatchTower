import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'i_shared_preferences_repository.dart';

class SharedPreferencesRepository implements ISharedPreferencesRepository {

  static final SharedPreferencesRepository _singleton =
  SharedPreferencesRepository._internal();

  factory SharedPreferencesRepository() {
    return _singleton;
  }

  SharedPreferencesRepository._internal();

  @override
  Future setController(String controllerKey, String controllerValue) async {
   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(controllerKey, controllerValue);
  }

  @override
  Future getController(String controllerKey) async {
   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(controllerKey) ?? '';
  }

  @override
  Future getUsername(String usernameKey) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(usernameKey) ?? '';
  }

  @override
  Future setUsername(String usernameKey, String usernameValue) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(usernameKey, usernameValue);
  }

  @override
  Future getNotShowStartScreen(String startScreenKey) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(startScreenKey) ?? false;
  }

  @override
  Future setNotShowStartScreen(String startScreenKey, bool startScreenValue) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(startScreenKey, startScreenValue);
  }

  @override
  Future getThemeMode(String localThemeKey) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(localThemeKey);
  }

  @override
  Future setThemeMode(String localThemeKey, String localThemeValue) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(localThemeKey, localThemeValue);
  }

  @override
  Future getSuggestionsList(String suggestionsKey) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(suggestionsKey);
  }

  @override
  Future setSuggestionsList(String suggestionsKey, List<String> suggestionsValue) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList(suggestionsKey, suggestionsValue);
  }

  @override
  Future setSuggestion(String suggestionsKey, String suggestion) async{
    var oldSuggestions = await getSuggestionsList(suggestionsKey);
    List<String> newSuggestions = [];
    if(oldSuggestions != null){
      newSuggestions = oldSuggestions;
    }
    if(!newSuggestions.contains(suggestion)){
      newSuggestions.insert(0,suggestion);
      try{
       newSuggestions.take(5);
      }catch(e){
        if (kDebugMode) {
          print('$e');
        }
      }
    }
    setSuggestionsList(suggestionsKey, newSuggestions);
  }

  @override
  Future getJwtToken(String tokenKey) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(tokenKey);
  }

  @override
  Future setJwtToken(String tokenKey, String tokenValue) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(tokenKey, tokenValue);
  }

  @override
  Future removeShPrefByKey(String key) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(key);
  }
}
