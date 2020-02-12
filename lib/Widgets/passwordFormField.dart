import 'package:flutter/material.dart';
import 'package:matchup/bizlogic/passwordValidator.dart';
import 'package:matchup/bizlogic/validator.dart';

class PasswordFormField{
  String _password;
  bool _isLogin;

  PasswordFormField(bool isLogin){
    _isLogin = isLogin;
  }

  String get getPassword => _password;
  set setPassword(String password) { _password = password; }

  bool get getIsLogin => _isLogin;
  set setIsLogin(bool isLogin) { _isLogin = isLogin; }

  // TODO: password field should be given validator as a parameter to be used in different cases
  Widget buildPasswordField(){
    Validator passwordValidator = PasswordValidator(_isLogin);
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20, 0, 0.0),
        child: new TextFormField(
            key: Key('password'),
            maxLines: 1,
            obscureText: true,
            autofocus: false,
            decoration: InputDecoration(
              //contentPadding: EdgeInsets.fromLTRB(0.0, 15.0, 20.0, 0.0),
              hintText: "Password",
              icon: new Icon(Icons.lock,
              color: Colors.blueGrey
              )
            ),
            validator: (value) => passwordValidator.validate(value),
            onSaved: (value) => _password = passwordValidator.save(value),
        ),
      ),
      flex: 4
    );
  }
}