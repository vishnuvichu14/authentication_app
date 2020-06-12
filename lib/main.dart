//import 'dart:async';
//import 'dart:convert' show json;
//
//import "package:http/http.dart" as http;
//import 'package:flutter/material.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//
//GoogleSignIn _googleSignIn = GoogleSignIn(
//  scopes: <String>[
//    'email',
//    'https://www.googleapis.com/auth/contacts.readonly',
//  ],
//);
//
//void main() {
//  runApp(
//    MaterialApp(
//      title: 'Google Sign In',
//      home: SignInDemo(),
//    ),
//  );
//}
//
//class SignInDemo extends StatefulWidget {
//  @override
//  State createState() => SignInDemoState();
//}
//
//class SignInDemoState extends State<SignInDemo> {
//  GoogleSignInAccount _currentUser;
//  String _contactText;
//
//  @override
//  void initState() {
//    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        _currentUser = account;
//      });
//      if (_currentUser != null) {
//        _handleGetContact();
//      }
//    });
//    _googleSignIn.signInSilently();
//  }
//
//  Future<void> _handleGetContact() async {
//    setState(() {
//      _contactText = "Loading contact info...";
//    });
//    final http.Response response = await http.get(
//      'https://people.googleapis.com/v1/people/me/connections'
//          '?requestMask.includeField=person.names',
//      headers: await _currentUser.authHeaders,
//    );
//    if (response.statusCode != 200) {
//      setState(() {
//        _contactText = "People API gave a ${response.statusCode} "
//            "response. Check logs for details.";
//      });
//      print('People API ${response.statusCode} response: ${response.body}');
//      return;
//    }
//    final Map<String, dynamic> data = json.decode(response.body);
//    final String namedContact = _pickFirstNamedContact(data);
//    setState(() {
//      if (namedContact != null) {
//        _contactText = "I see you know $namedContact!";
//      } else {
//        _contactText = "No contacts to display.";
//      }
//    });
//  }
//
//  String _pickFirstNamedContact(Map<String, dynamic> data) {
//    final List<dynamic> connections = data['connections'];
//    final Map<String, dynamic> contact = connections?.firstWhere(
//          (dynamic contact) => contact['names'] != null,
//      orElse: () => null,
//    );
//    if (contact != null) {
//      final Map<String, dynamic> name = contact['names'].firstWhere(
//            (dynamic name) => name['displayName'] != null,
//        orElse: () => null,
//      );
//      if (name != null) {
//        return name['displayName'];
//      }
//    }
//    return null;
//  }
//
//  Future<void> _handleSignIn() async {
//    try {
//      await _googleSignIn.signIn();
//    } catch (error) {
//      print(error);
//    }
//  }
//
//  Future<void> _handleSignOut() => _googleSignIn.disconnect();
//
//  Widget _buildBody() {
//    if (_currentUser != null) {
//      return Column(
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
//        children: <Widget>[
//          ListTile(
//            leading: GoogleUserCircleAvatar(
//              identity: _currentUser,
//            ),
//            title: Text(_currentUser.displayName ?? ''),
//            subtitle: Text(_currentUser.email ?? ''),
//          ),
//          const Text("Signed in successfully."),
//          Text(_contactText ?? ''),
//          RaisedButton(
//            child: const Text('SIGN OUT'),
//            onPressed: _handleSignOut,
//          ),
//          RaisedButton(
//            child: const Text('REFRESH'),
//            onPressed: _handleGetContact,
//          ),
//        ],
//      );
//    } else {
//      return Column(
//        mainAxisAlignment: MainAxisAlignment.spaceAround,
//        children: <Widget>[
//          const Text("You are not currently signed in."),
//          RaisedButton(
//            child: const Text('SIGN IN'),
//            onPressed: _handleSignIn,
//          ),
//        ],
//      );
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        appBar: AppBar(
//          title: const Text('Google Sign In'),
//        ),
//        body: ConstrainedBox(
//          constraints: const BoxConstraints.expand(),
//          child: _buildBody(),
//        ));
//  }
//}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  var profileData;

  var facebookLogin = FacebookLogin();

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Facebook Login"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.white,
              ),
              onPressed: () => facebookLogin.isLoggedIn
                  .then((isLoggedIn) => isLoggedIn ? _logout() : {}),
            ),
          ],
        ),
        body: Container(
          child: Center(
            child: isLoggedIn
                ? _displayUserData(profileData)
                : _displayLoginButton(),
          ),
        ),
      ),
      theme: ThemeData(
        fontFamily: 'Raleway',
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.grey[600],
        ),
        // This colors the [InputOutlineBorder] when it is selected
        primaryColor: Colors.blue[500],
        textSelectionHandleColor: Colors.blue[500],
      ),
    );
  }

  void initiateFacebookLogin() async {
    var facebookLoginResult =
    await facebookLogin.logIn(['email']);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.width(400)&access_token=${facebookLoginResult
                .accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, profileData: profile);
        break;
    }
  }

  _displayUserData(profileData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 200.0,
          width: 200.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                profileData['picture']['data']['url'],
              ),
            ),
          ),
        ),
        SizedBox(height: 28.0),
        Text(
          "FBID ${profileData['id']}\n${profileData['name']}\n${profileData['email']}",
          style: TextStyle(
            fontSize: 20.0,
            letterSpacing: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _displayLoginButton() {
    return RaisedButton(
      child: Text("Login with Facebook"),
      onPressed: () => initiateFacebookLogin(),
      color: Colors.blue,
      textColor: Colors.white,
    );
  }

  _logout() async {
    await facebookLogin.logOut();
    onLoginStatusChanged(false);
    print("Logged out");
  }
}