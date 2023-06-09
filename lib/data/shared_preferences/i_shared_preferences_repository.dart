abstract class ISharedPreferencesRepository {
  Future setController(String controllerKey,String controllerValue);
  Future getController(String controllerKey);
  Future setUsername(String usernameKey,String usernameValue);
  Future getUsername(String usernameKey);
  Future setNotShowStartScreen(String startScreenKey,bool startScreenValue);
  Future getNotShowStartScreen(String startScreenKey);
  Future setThemeMode(String localThemeKey,String localThemeValue);
  Future getThemeMode(String localThemeKey);
  Future setSuggestionsList(String suggestionsKey, List<String> suggestionsValue);
  Future getSuggestionsList(String suggestionsKey);
  Future setSuggestion(String suggestionsKey, String suggestion);
  Future setJwtToken(String tokenKey, String tokenValue);
  Future getJwtToken(String tokenKey);
  Future removeShPrefByKey(String key);
}