import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tower/ui/screens/nodes_overview.dart';
import 'package:tower/ui/screens/start_screen.dart';
import '../../data/repository/client.dart';
import '../../data/shared_preferences/shared_preferences_repository.dart';
import '../../main.dart';
import '../common.dart';
import 'dart:io' show Platform;

extension StringLastChar on String {
  String lastChars(int n) => substring(length - n);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  bool connectButtonActive = true;
  final SharedPreferencesRepository _preferences = SharedPreferencesRepository();
  List<String> suggestionsListController = [];
  List<String> suggestionsListUsername = [];
  bool autocompleteController = false;
  bool autocompleteUsername = false;


  void getSharedPreferences() async{
    serverController.text = await _preferences.getController('controller');
    userController.text = await _preferences.getUsername('username');
    if(kDebugMode){
      print('USER CONTROLLER: ${userController.text}');
      print('SERVER CONTROLLER: ${serverController.text}');
    }
  }

  void getShPrefSuggestionsController() async{
    try{
      suggestionsListController = await _preferences.getSuggestionsList('suggestions_server');
    }catch(e){
      if(kDebugMode){print(e);}
    }
   if(kDebugMode){print('SUGGESTIONS LIST CONTROLLER: $suggestionsListController');}
  }

  void getShPrefSuggestionsUsername() async{
    try{
      suggestionsListUsername = await _preferences.getSuggestionsList('suggestions_username');
    }catch(e){
      if(kDebugMode){print(e);}
    }
    if(kDebugMode){print('SUGGESTIONS LIST USERNAME: $suggestionsListUsername');}
  }

  @override
  void initState() {
    manualUpdateTimer?.cancel();
    autoUpdateTimer?.cancel();
    getSharedPreferences();
    getShPrefSuggestionsController();
    getShPrefSuggestionsUsername();
    // if(box.read('server') != null && box.read('username') != null){
    //   userController.text = box.read('username');
    //   serverController.text = box.read('server');
    // }
    super.initState();
  }

  void _login() {
    if(connectButtonActive == false) return;
    if (passwordController.text.isEmpty ||
        userController.text.isEmpty ||
        serverController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("One or more fields are empty"),
      ));
    } else if (serverController.text.lastChars(1).contains(' ')) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("One or more fields are incorrect"),
      ));
    } else {
      setState(() { connectButtonActive = false;});
     // String? token;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        logIn(
          password: passwordController.text,
          username: userController.text,
          url: serverController.text,
        ).then((value) {
          setState(() {
            connectButtonActive = true;
            // token = value;
            tokenJWT = value;
            if (tokenJWT != null) {
              //if (tokenJWT!.length > 2) {
            // if (token != null) {
            //   if (token!.length > 2) {
                ScaffoldMessenger.of(context).clearSnackBars();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => const NodeOverviewScreen()), (route) => false);
                _preferences.setController('controller', serverController.text);
                _preferences.setUsername('username', userController.text);
                _preferences.setNotShowStartScreen('startScreen', true);
                _preferences.setSuggestion('suggestions_server', serverController.text);
                _preferences.setSuggestion('suggestions_username', userController.text);
                _preferences.setJwtToken('token', tokenJWT!);
                box.write('isTokenExpired', false);
                //box.write('notShowStartScreen', true);
                //box.write('token', '$token');
                //box.write('username', userController.text);
               // box.write('server', serverController.text);
            //   }
            // else {
            //     ScaffoldMessenger.of(context).clearSnackBars();
            //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //       content: Text("One or more fields are incorrect"),
            //     ));
            //   }
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("One or more fields are incorrect"),
              ));
            }
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (Platform.isAndroid) {
        return mobileMarkup(context);
      } else if (Platform.isIOS) {
        return mobileMarkup(context);
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return desktopMarkup(context);
      } else {
        return const ErrorMessage();
      }
    } catch (e) {
      /*------------------------------------------------------------------------
       for web it isn't possible to define platform.
       So it will an exception
       -------------------------------------------------------------------------
       */
      return const ErrorMessage();
    }
  }

  Scaffold desktopMarkup(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? kBackgroundColorDark
          : kBackgroundColorLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.07,
            horizontal: MediaQuery.of(context).size.width * 0.1),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEF6FF),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(30),
                        bottomLeft: const Radius.circular(30),
                        bottomRight: MediaQuery.of(context).size.width < 550
                            ? const Radius.circular(30)
                            : Radius.zero,
                        topRight: MediaQuery.of(context).size.width < 550
                            ? const Radius.circular(30)
                            : Radius.zero),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.03),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: SvgPicture.asset('assets/log_in.svg'),
                        ),
                        Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width * 0.05)
                                  .copyWith(
                                      top: MediaQuery.of(context).size.height *
                                          0.02),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Controller server',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            Text(
                                              '*',
                                              style: TextStyle(
                                                  color: Colors.red, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        height: 45,
                                        child: TextFormField(
                                          controller: serverController,
                                          onChanged: (serverString) {
                                            if (kDebugMode) {
                                              print('server: $serverString');
                                            }
                                          },
                                            onTap: (){
                                              autocompleteController = !autocompleteController;
                                              autocompleteUsername = false;
                                              setState(() {});
                                        },
                                          decoration: loginPageTextFormDecoration(
                                              context,
                                              'Controller server',
                                              DeviceType.desktop,
                                              FieldType.controller),
                                          style:
                                              const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Row(
                                          children: [
                                            Text('User',
                                                style:
                                                    TextStyle(color: Colors.black)),
                                            Text(
                                              '*',
                                              style: TextStyle(
                                                  color: Colors.red, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        height: 45,
                                        child: TextFormField(
                                          controller: userController,
                                          onChanged: (userString) {
                                            if (kDebugMode) {
                                              print('user: $userString');
                                            }
                                          },
                                          onTap: (){
                                            autocompleteUsername = !autocompleteUsername;
                                            autocompleteController = false;
                                            setState(() {});
                                          },
                                          decoration: loginPageTextFormDecoration(
                                              context,
                                              'User',
                                              DeviceType.desktop,
                                              FieldType.username),
                                          style:
                                              const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Password',
                                              style: TextStyle(color: Colors.black),
                                            ),
                                            Text(
                                              '*',
                                              style: TextStyle(
                                                  color: Colors.red, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        height: 45,
                                        child: TextFormField(
                                          controller: passwordController,
                                          onChanged: (passwordString) {
                                            if (kDebugMode) {
                                              print('password: $passwordString');
                                            }
                                          },
                                          onTap: (){
                                            autocompleteController = false;
                                            autocompleteUsername = false;
                                            setState(() {});
                                          },
                                          decoration: loginPageTextFormDecoration(
                                              context,
                                              'Password',
                                              DeviceType.desktop,
                                              FieldType.password),
                                          obscureText: obscureText,
                                          style:
                                              const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                                visible: autocompleteController && suggestionsListController.isNotEmpty,
                                child: Positioned(
                                  top: 70,
                                  left: windowWidth < 1000 ? MediaQuery.of(context).size.width / 6 : MediaQuery.of(context).size.width / 5,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color:  Colors.grey.shade200,
                                          borderRadius: const BorderRadius.all(Radius.circular(8))
                                      ),
                                      child: suggestionsCardDesktopController(),
                                  ),
                                )
                            ),
                            Visibility(
                                visible: autocompleteUsername && suggestionsListUsername.isNotEmpty,
                                child: Positioned(
                                  top: 150,
                                  left: windowWidth < 1000 ? MediaQuery.of(context).size.width / 6 : MediaQuery.of(context).size.width / 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color:  Colors.grey.shade200,
                                        borderRadius: const BorderRadius.all(Radius.circular(8))
                                    ),
                                    child: suggestionsCardDesktopUsername(),
                                  ),
                                )
                            ),
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: Ink(
                                  decoration: connectButtonActive ?  BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF3A7EFF),
                                            Color(0xFF5690FF),
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter),
                                      borderRadius: BorderRadius.circular(10)): BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Colors.grey.shade400,
                                            Colors.grey.shade400
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Container(
                                    height: 55,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Connect',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w100),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              MediaQuery.of(context).size.width > 550
                  ? Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical:
                                MediaQuery.of(context).size.height * 0.01),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/login_decoration/login_desktop.svg',
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget mobileMarkup(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartScreen()), (Route<dynamic> route) => false);
        passwordController.clear();
        userController.clear();
        serverController.clear();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? kBackgroundColorDark
            : kBackgroundColorLight,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.25,
                          bottom: MediaQuery.of(context).size.height * 0.1),
                      child: SvgPicture.asset('assets/log_in.svg'),
                    ),
                  ),
                  Positioned(
                    child:
                        SvgPicture.asset('assets/login_decoration/spot_1.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.6,
                  ),
                  Positioned(
                    child:
                        SvgPicture.asset('assets/login_decoration/spot_2.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                    top: MediaQuery.of(context).size.height * 0.08,
                    left: MediaQuery.of(context).size.width * 0.4,
                  ),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_3.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF214DA8) : null),
                      top: MediaQuery.of(context).size.height * 0.15,
                      left: MediaQuery.of(context).size.width * 0.15),
                  Positioned(
                    child:
                        SvgPicture.asset('assets/login_decoration/spot_4.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF214DA8) : null),
                    top: MediaQuery.of(context).size.height * 0.13,
                    right: MediaQuery.of(context).size.width * 0.2,
                  ),
                  Positioned(
                    child:
                        SvgPicture.asset('assets/login_decoration/spot_5.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                    top: MediaQuery.of(context).size.height * 0.22,
                    left: MediaQuery.of(context).size.width * 0.3,
                  ),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_6.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                      top: MediaQuery.of(context).size.height * 0.3,
                      left: MediaQuery.of(context).size.width * 0.2),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_7.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                      top: MediaQuery.of(context).size.height * 0.3,
                      left: MediaQuery.of(context).size.width * 0.8),
                  Positioned(
                      child: SvgPicture.asset(
                          'assets/login_decoration/spot_8.svg', color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF172954) : null),
                      top: MediaQuery.of(context).size.height * 0.35,
                      left: MediaQuery.of(context).size.width * 0.45),
                ],
              ),
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.height * 0.03)
                        .copyWith(top: MediaQuery.of(context).size.height * 0.05),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Text('Controller server'),
                                  Text(
                                    '*',
                                    style:
                                        TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 45,
                              child: TextFormField(
                                controller: serverController,
                                onChanged: (serverString) {
                                  if (kDebugMode) {
                                    print('server: $serverString');
                                  }
                                },
                                onTap: (){
                                    autocompleteController = !autocompleteController;
                                    autocompleteUsername = false;
                                    setState(() {});
                                },
                                keyboardType: TextInputType.text,
                                decoration: loginPageTextFormDecoration(
                                    context,
                                    'Controller server',
                                    DeviceType.mobile,
                                    FieldType.controller),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Text('User'),
                                  Text(
                                    '*',
                                    style:
                                        TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 45,
                              child: TextFormField(
                                controller: userController,
                                onChanged: (userString) {
                                  if (kDebugMode) {
                                    print('user: $userString');
                                  }
                                },
                                onTap: (){
                                  autocompleteUsername = !autocompleteUsername ;
                                  autocompleteController = false;
                                  setState(() {});
                                },
                                keyboardType: TextInputType.text,
                                decoration: loginPageTextFormDecoration(context,
                                    'User', DeviceType.mobile, FieldType.username),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Text('Password'),
                                  Text(
                                    '*',
                                    style:
                                        TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 45,
                              child: TextFormField(
                                controller: passwordController,
                                onChanged: (passwordString) {
                                  if (kDebugMode) {
                                    print('password: $passwordString');
                                  }
                                },
                                onTap: (){
                                  autocompleteController = false;
                                  autocompleteUsername = false;
                                  setState(() {});
                                },
                                keyboardType: TextInputType.text,
                                obscureText: obscureText,
                                decoration: loginPageTextFormDecoration(
                                    context,
                                    'Password',
                                    DeviceType.mobile,
                                    FieldType.password),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: autocompleteController && suggestionsListController.isNotEmpty,
                      child: Positioned(
                        top: 100,
                       left: MediaQuery.of(context).size.width / 3,
                        child: Container(
                            decoration: BoxDecoration(
                                color:  Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white: Colors.grey.shade200,
                                borderRadius: const BorderRadius.all(Radius.circular(8))
                            ),
                            child: suggestionsCardMobileController()
                        ),
                      )
                  ),
                  Visibility(
                      visible: autocompleteUsername && suggestionsListUsername.isNotEmpty,
                      child: Positioned(
                        top: 180,
                        left: MediaQuery.of(context).size.width / 3,
                        child: Container(
                            decoration: BoxDecoration(
                                color:  Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white: Colors.grey.shade200,
                                borderRadius: const BorderRadius.all(Radius.circular(8))
                            ),
                            child: suggestionsCardMobileUsername(),
                        ),
                      )
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.03),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Ink(
                        decoration: connectButtonActive ?  BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF3A7EFF),
                                  Color(0xFF5690FF),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter),
                            borderRadius: BorderRadius.circular(30)):
                        BoxDecoration(gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade400,
                              Colors.grey.shade400
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter),
                            borderRadius: BorderRadius.circular(30)),
                        child: Container(
                          height: 55,
                          alignment: Alignment.center,
                          child: const Text(
                            'Connect',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w100),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration loginPageTextFormDecoration(BuildContext context,
      String hintText, DeviceType deviceType, FieldType fieldType) {
    BorderSide focusedBorder;
    BorderSide enabledBorder;
    Color fillColor;

    if (deviceType == DeviceType.mobile) {
      focusedBorder = BorderSide(
          width: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF282C49)
              : Colors.grey.shade300);
      enabledBorder = BorderSide(
          width: 1,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF282C49)
              : Colors.grey.shade300);
      fillColor = Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C2039)
          : Colors.white;
    } else {
      focusedBorder = BorderSide(width: 1, color: Colors.grey.shade300);
      enabledBorder = BorderSide(width: 1, color: Colors.grey.shade300);
      fillColor = Colors.white;
    }

    InputDecoration kFieldLogInScreenDecoration = InputDecoration(
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        borderSide: focusedBorder,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        borderSide: enabledBorder,
      ),
      filled: true,
      hintText: hintText,
      fillColor: fillColor,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      suffixIcon: fieldType == FieldType.password
          ? GestureDetector(
              child: Icon(
                obscureText == true ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade400,
              ),
              onTap: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            )
          : const SizedBox.shrink(),
    );
    return kFieldLogInScreenDecoration;
  }

  Column suggestionsCardDesktopController() {
    int maxLength = 0;
    List<Widget> suggestions = [];

    if(suggestionsListController.isNotEmpty){
      maxLength = suggestionsListController.first.length;
    }
    for(int i = 0; i <  suggestionsListController.length; i++){
      int amountOfSymbols = suggestionsListController[i].length;
      if(amountOfSymbols > maxLength){
        maxLength = amountOfSymbols;
      }
    }
    for(int i = 0; i <  suggestionsListController.length; i++){
      suggestions.add(InkWell(
        onTap: (){
          autocompleteController = !autocompleteController;
          setState(() {
            String text = suggestionsListController[i];
            serverController.text = text;
          });
        },
        child: SizedBox(
          width: maxLength * 9,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                        Text(suggestionsListController[i], style: const TextStyle(color: Colors.black),),
                        i < suggestionsListController.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        deleteSuggestionController(suggestionsListController, i);
                      },
                      child: Column(
                        children: [
                          i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.close, size: 18, color: Colors.black),
                          ),
                          i < suggestionsListController.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
                i + 1 != suggestionsListController.length ? Padding(
                  padding:  const EdgeInsets.only(right: 8),
                  child: Container(color: Colors.grey.shade300,
                      width: double.infinity ,
                      height: 2),
                ): const SizedBox.shrink(),
                i + 1 != suggestionsListController.length ? const SizedBox(height: 8): const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      );
    }
    return Column(children: suggestions);
  }

  Column suggestionsCardDesktopUsername() {
    int maxLength = 0;
    List<Widget> suggestions = [];

    if(suggestionsListUsername.isNotEmpty){
      maxLength = suggestionsListUsername.first.length;
    }
    for(int i = 0; i <  suggestionsListUsername.length; i++){
      int amountOfSymbols = suggestionsListUsername[i].length;
      if(amountOfSymbols > maxLength){
        maxLength = amountOfSymbols;
      }
    }
    for(int i = 0; i <  suggestionsListUsername.length; i++){
      suggestions.add(InkWell(
        onTap: (){
          autocompleteUsername = !autocompleteUsername;
          setState(() {
            String text = suggestionsListUsername[i];
            userController.text = text;
          });
        },
        child: SizedBox(
          width: maxLength * 24,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                        Text(suggestionsListUsername[i], style: const TextStyle(color: Colors.black),),
                        i < suggestionsListUsername.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        deleteSuggestionUsername(suggestionsListUsername, i);
                      },
                      child: Column(
                        children: [
                          i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.close, size: 18, color: Colors.black),
                          ),
                          i < suggestionsListUsername.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
                i + 1 != suggestionsListUsername.length ? Padding(
                  padding:  const EdgeInsets.only(right: 8),
                  child: Container(color: Colors.grey.shade300,
                      width: double.infinity ,
                      height: 2),
                ): const SizedBox.shrink(),
                i + 1 != suggestionsListUsername.length ? const SizedBox(height: 8): const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      );
    }
    return Column(children: suggestions);
  }

  Column suggestionsCardMobileController() {
    int maxLength = 0;
    List<Widget> suggestions = [];

    if(suggestionsListController.isNotEmpty){
      maxLength = suggestionsListController.first.length;
    }
    for(int i = 0; i <  suggestionsListController.length; i++){
      int amountOfSymbols = suggestionsListController[i].length;
      if(amountOfSymbols > maxLength){
        maxLength = amountOfSymbols;
      }
    }
    for(int i = 0; i <  suggestionsListController.length; i++){
      suggestions.add(InkWell(
        onTap: (){
          autocompleteController = !autocompleteController;
          setState(() {
            String text = suggestionsListController[i];
          serverController.text = text;
          });
        },
        child: SizedBox(
          width: maxLength * 11,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                        Text(suggestionsListController[i], style: const TextStyle(color: Colors.black),),
                         i < suggestionsListController.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        deleteSuggestionController(suggestionsListController, i);
                      },
                      child: Column(
                        children: [
                          i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                         const Padding(
                           padding: EdgeInsets.only(right: 8),
                           child: Icon(Icons.close, size: 18, color: Colors.black),
                         ),
                          i < suggestionsListController.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
                i + 1 != suggestionsListController.length ? Padding(
                  padding:  const EdgeInsets.only(right: 8),
                  child: Container(color: Colors.grey.shade300,
                      width: double.infinity ,
                      height: 2),
                ): const SizedBox.shrink(),
                i + 1 != suggestionsListController.length ? const SizedBox(height: 8): const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      );
    }
    return Column(children: suggestions);
  }

  Column suggestionsCardMobileUsername() {
    int maxLength = 0;
    List<Widget> suggestions = [];

    if(suggestionsListUsername.isNotEmpty){
      maxLength = suggestionsListUsername.first.length;
    }
    for(int i = 0; i <  suggestionsListUsername.length; i++){
      int amountOfSymbols = suggestionsListUsername[i].length;
      if(amountOfSymbols > maxLength){
        maxLength = amountOfSymbols;
      }
    }
    for(int i = 0; i <  suggestionsListUsername.length; i++){
      suggestions.add(InkWell(
        onTap: (){
          autocompleteUsername = !autocompleteUsername;
          setState(() {
            String text = suggestionsListUsername[i];
            userController.text = text;
          });
        },
        child: SizedBox(
          width: maxLength * 24,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                        Text(suggestionsListUsername[i], style: const TextStyle(color: Colors.black),),
                        i < suggestionsListUsername.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        deleteSuggestionUsername(suggestionsListUsername, i);
                      },
                      child: Column(
                        children: [
                          i == 0 ? const SizedBox(height: 8): const SizedBox.shrink(),
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.close, size: 18, color: Colors.black),
                          ),
                          i < suggestionsListUsername.length ? const SizedBox(height: 8): const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
                i + 1 != suggestionsListUsername.length ? Padding(
                  padding:  const EdgeInsets.only(right: 8),
                  child: Container(color: Colors.grey.shade300,
                      width: double.infinity ,
                      height: 2),
                ): const SizedBox.shrink(),
                i + 1 != suggestionsListUsername.length ? const SizedBox(height: 8): const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
      );
    }
    return Column(children: suggestions);
  }

  void deleteSuggestionController(List<String> currentList, int index)async{
    List<String> list = [];
    suggestionsListController.removeAt(index);
    setState(() {});
    try{
      list = await _preferences.getSuggestionsList('suggestions_server');
    }catch(e){
      if(kDebugMode){print(e);}
    }
    if(kDebugMode){print('SUGGESTIONS LIST BEFORE CLEARING: $list');}
    _preferences.removeShPrefByKey('suggestions_server');
    var listAfterClearing = await _preferences.getSuggestionsList('suggestions_server');
    /*
    listAfterClearing can be null in two cases:
    - first log in
    - delete all suggestions
    */
    if(kDebugMode){print('SUGGESTIONS LIST AFTER CLEARING: $listAfterClearing');}
    for(int i = 0; i < currentList.length; i++){
      if(kDebugMode){
        print('NEW SUGGESTIONS LIST ITEMS:  ${currentList[i]}');
      }
      _preferences.setSuggestion('suggestions_server', currentList[i]);
    }
  }

  void deleteSuggestionUsername(List<String> currentList, int index)async{
    List<String> list = [];
    suggestionsListUsername.removeAt(index);
    setState(() {});
    try{
      list = await _preferences.getSuggestionsList('suggestions_username');
    }catch(e){
      if(kDebugMode){print(e);}
    }
    if(kDebugMode){print('SUGGESTIONS USERNAME LIST BEFORE CLEARING: $list');}
    _preferences.removeShPrefByKey('suggestions_username');
    var listAfterClearing = await _preferences.getSuggestionsList('suggestions_username');
    /*
    listAfterClearing can be null in two cases:
    - first log in
    - delete all suggestions
    */
    if(kDebugMode){print('SUGGESTIONS USERNAME LIST AFTER CLEARING: $listAfterClearing');}
    for(int i = 0; i < currentList.length; i++){
      if(kDebugMode){
        print('NEW SUGGESTIONS USERNAME LIST ITEMS:  ${currentList[i]}');
      }
      _preferences.setSuggestion('suggestions_username', currentList[i]);
    }
  }
}
