import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travego/utils/server_info.dart';

import 'map.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _deviceSize = MediaQuery.of(context).size;
    final _height = _deviceSize.height;

    return Scaffold(
      key: _scaffoldState,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purpleAccent.withOpacity(0.5),
                  Colors.deepPurpleAccent.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: _deviceSize.height,
              width: _deviceSize.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: _height / 6.4),
                    padding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: _height / 8.4863221884498478723404255319149,
                    ),
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.deepPurpleAccent,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      'Travego',
                      style: TextStyle(
                        fontSize: _height / 15.954285714285714,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _height / 15.954285714285714,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: _height / 2.659047619047619),
                    child: AuthCard(
                      scaffoldState: _scaffoldState,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldState;
  const AuthCard({
    Key key,
    this.scaffoldState,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'fullName': '',
    'phoneNumber': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_authMode == AuthMode.Login) {
      final response = await http.post(ServerInfo.LOG_IN, body: {
        'phoneNumber': _authData['phoneNumber'],
        'password': _authData['password'],
      });
      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', json.decode(response.body)['token']);
        prefs.setInt('userId', json.decode(response.body)['id']);
        prefs.setString('fullName', json.decode(response.body)['fullName']);
        Navigator.pushReplacementNamed(
          context,
          MapScreen.routeName,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        widget.scaffoldState.currentState.showSnackBar(SnackBar(
          content: Text(
            'حدث خطأ ما و لم نستطع تسجيل دخولك, حاول مرةً أخرى',
            textAlign: TextAlign.center,
          ),
        ));
      }
    } else {
      final response = await http.post(ServerInfo.SIGN_UP, body: {
        'fullName': _authData['fullName'],
        'phoneNumber': _authData['phoneNumber'],
        'password': _authData['password'],
      });
      if (response.statusCode == 201) {
        setState(() {
          _authMode = AuthMode.Login;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        widget.scaffoldState.currentState.showSnackBar(SnackBar(
          content: Text(
            'حدث خطأ ما و لم نستطع تسجيل حساب جديد لك, حاول مرةً أخرى',
            textAlign: TextAlign.center,
          ),
        ));
      }
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final height = deviceSize.height;
    var loginCardHeight = height / 2.8489795918367346428571428571429;
    var signupCardHeight = height / 1.99428571428571425;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height:
            _authMode == AuthMode.Signup ? signupCardHeight : loginCardHeight,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup ? 380 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.symmetric(
          horizontal: height / 49.85714285714285625,
          vertical: height / 79.77142857142857,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'رقم الهاتف'),
                    keyboardType: TextInputType.number,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty ||
                          !value.startsWith('09') ||
                          value.length != 10) {
                        return 'رقم الهاتف غير صالح';
                      }
                    },
                    onSaved: (value) {
                      _authData['phoneNumber'] = value;
                    },
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'كلمة المرور'),
                    obscureText: true,
                    controller: _passwordController,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty || value.length < 3) {
                        return 'كلمة السر قصيرة جداً';
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                ),
                if (_authMode == AuthMode.Signup)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'تأكيد كلمة المرور'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          // ignore: missing_return
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'كلمات السر غير متطابقة';
                              }
                            }
                          : null,
                    ),
                  ),
                if (_authMode == AuthMode.Signup)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration: InputDecoration(labelText: 'الاسم الكامل'),
                      onSaved: (value) {
                        _authData['fullName'] = value;
                      },
                    ),
                  ),
                SizedBox(
                  height: height / 39.885714285714285,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  Column(
                    children: <Widget>[
                      RaisedButton(
                        child: Text(
                          _authMode == AuthMode.Login
                              ? 'تسجيل الدخول'
                              : 'تسجيل حساب جديد',
                          style: TextStyle(
                            fontSize: height / 39.885714285714285,
                          ),
                        ),
                        onPressed: _submit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: height / 26.59047619047619,
                          vertical: 8.0,
                        ),
                        color: Colors.deepPurpleAccent,
                        textColor:
                            Theme.of(context).primaryTextTheme.button.color,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FlatButton(
                        child: Text(
                          '${_authMode == AuthMode.Login ? 'سجل حساباً جديداً' : 'سجل دخولك'}',
                          style: TextStyle(
                            fontSize:
                                height / 44.317460317460316666666666666667,
                          ),
                        ),
                        onPressed: _switchAuthMode,
                        padding: EdgeInsets.symmetric(
                          horizontal: height / 26.59047619047619,
                          vertical: 4,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textColor: Colors.deepPurpleAccent,
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
