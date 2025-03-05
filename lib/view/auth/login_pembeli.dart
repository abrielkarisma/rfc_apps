import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class LoginPembeliWidget extends StatefulWidget {
  final PageController pageController;
  const LoginPembeliWidget({
    super.key,
    required this.pageController,
  });

  @override
  State<LoginPembeliWidget> createState() => _LoginPembeliWidgetState();
}

class _LoginPembeliWidgetState extends State<LoginPembeliWidget> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showSnackBar('Masukkan email anda');
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Masukkan email yang valid');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Masukkan password anda');
      return;
    }
    if (password.length < 8) {
      _showSnackBar('Password minimal 8 karakter');
      return;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.getWidth(400),
            height: context.getHeight(130),
            child: Text(
              "Masuk ke Akun Anda",
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 28,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.start,
            ),
          ),
          Padding(padding: EdgeInsets.only(top: context.getHeight(36))),
          Container(
            child: Text(
              "email",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: context.getHeight(7)),
              height: context.getHeight(46),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "yourmail@mail.com",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // 10 radius
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
              )),
          Container(
            margin: EdgeInsets.only(top: context.getHeight(7)),
            child: Text(
              "password",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: context.getHeight(7)),
            height: context.getHeight(46),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                hintText: "Enter password",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: context.getHeight(7), bottom: context.getHeight(14)),
            width: double.infinity,
            child: Text(
              "Lupa Password?",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          Container(
            width: double.infinity,
            height: context.getHeight(54),
            child: TextButton(
              onPressed: () {
                _handleLogin();
              },
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(top: context.getHeight(24)),
              child: RichText(
                text: TextSpan(
                  text: "Belum punya akun? ",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(
                      text: "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          widget.pageController.jumpToPage(2);
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              child: RichText(
                text: TextSpan(
                  text: "Login Sebagai Penjual? ",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    TextSpan(
                      text: "Disini",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          print("anjaii");
                        },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
