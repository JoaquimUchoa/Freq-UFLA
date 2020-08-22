import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freq_ufla/util/generalAlertDialog.dart';
import 'package:freq_ufla/services/authentication.dart';

import 'package:freq_ufla/components/button.dart';

class Login extends StatefulWidget {
  Login({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formStudentKey = GlobalKey<FormState>();
  final _formProfessorKey = GlobalKey<FormState>();

  String _registrationNumber;

  String _email;
  String _password;

  GeneralAlertDialog _alert;

  bool _isStudentLogin;
  bool _isLoading;

  bool _validateAndSaveProfessorForm() {
    final form = _formProfessorKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool _validateAndSaveStudentForm() {
    final form = _formStudentKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Faz o login dos usuários
  void _formSubmit() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_isStudentLogin) {
        if (_validateAndSaveStudentForm()) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('registrationNumber', _registrationNumber);
          widget.loginCallback();
        }
      } else {
        if (_validateAndSaveProfessorForm()) {
          String userId = await widget.auth.signIn(_email, _password);

          if (userId.length > 0 && userId != null) {
            widget.loginCallback();
          }
        }
      }
    } catch (e) {
      _showDialog('Erro', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(title, content) {
    this._alert = GeneralAlertDialog(title: title, content: content);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return this._alert;
      },
    );
  }

  @override
  void initState() {
    _isLoading = false;
    _isStudentLogin = true;
    super.initState();
  }

  void _toggleFormMode() {
    setState(() {
      _isStudentLogin = !_isStudentLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              _formBlock(),
              _circularProgress(),
            ],
          ),
        ));
  }

  Widget _circularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _formBlock() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0,),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          _logo(),
          _form(),
          _loginButton(),
          _changeFormButton(),
        ],
      ),
    );
  }

  Widget _form() {
    if (_isStudentLogin) {
      return Form(
        key: _formStudentKey,
        child: _registrationNumberInput(),
      );
    }
    return Form(
        key: _formProfessorKey,
        child: Column(
          children: <Widget>[
            _emailInput(),
            _passwordInput(),
          ],
        ));
  }

  Widget _logo() {
    return Column(
      children: <Widget>[
        Image.asset(
          'assets/img/agenda.png',
          height: 150,
          width: 150,
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Text(
            'Freq UFLA',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        )
      ],
    );
  }

  Widget _registrationNumberInput() {
    return TextFormField(
      maxLines: 1,
      maxLength: 9,
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Matrícula',
          icon: Icon(
            Icons.account_box,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty)
          return 'Preencha sua matrícula';
        else if (value.length != 9) return 'A matrícula deve possuir 9 dígitos';
        return null;
      },
      onSaved: (value) => _registrationNumber = value.trim(),
    );
  }

  Widget _emailInput() {
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
          hintText: 'Email',
          icon: Icon(
            Icons.mail,
            color: Colors.grey,
          )),
      validator: (value) =>
          EmailValidator.validate(value) ? null : 'Entre com um email válido',
      onSaved: (value) => _email = value.trim(),
    );
  }

  Widget _passwordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty)
            return 'Senha necessária';
          else if (value.length < 6)
            return 'A senha precisa ter pelo menos 6 caracteres';
          return null;
        },
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget _loginButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
      child: Button(text: 'Entrar', callbackFunc: _formSubmit),
    );
  }

  Widget _changeFormButton() {
    return FlatButton(
        child: Text(_isStudentLogin ? 'Sou professor' : 'Sou aluno',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: _toggleFormMode);
  }
}
