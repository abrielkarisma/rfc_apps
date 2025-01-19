import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class RegisterPembeliWidget extends StatefulWidget {
  final PageController pageController;
  const RegisterPembeliWidget({
    super.key,
    required this.pageController,
  });

  @override
  State<RegisterPembeliWidget> createState() => _RegisterPembeliWidgetState();
}

class _RegisterPembeliWidgetState extends State<RegisterPembeliWidget> {
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPasswordError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: context.getHeight(59),
          width: double.infinity,
          child: Text(
            "Buat Akun Baru",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 36,
                fontFamily: "poppins",
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
        ),
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
            child: TextField(
              decoration: InputDecoration(
                hintText: "yourmail@mail.com",
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
          child: TextField(
            controller: _passwordController,
            obscureText: _isObscurePassword,
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
                  _isObscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscurePassword = !_isObscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: context.getHeight(7)),
          child: Text(
            "confirm password",
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
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _isObscureConfirmPassword,
            onChanged: (value) {
              setState(() {
                _showPasswordError =
                    _passwordController.text != _confirmPasswordController.text;
              });
            },
            decoration: InputDecoration(
              hintText: "Confirm password",
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
                  _isObscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscureConfirmPassword = !_isObscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ),
        if (_showPasswordError)
          Container(
            margin: EdgeInsets.only(top: context.getHeight(3)),
            child: Text(
              "Password dan Confirm Password tidak sama",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          height: context.getHeight(54),
          margin: EdgeInsets.only(top: context.getHeight(22)),
          child: TextButton(
            onPressed: () {
              if (_passwordController.text == _confirmPasswordController.text) {
                // Proses registrasi
                print("Registrasi berhasil");
              } else {
                setState(() {
                  _showPasswordError = true;
                });
              }
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Register',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            print("anjai");
          },
          child: Container(
            margin: EdgeInsets.only(
                top: context.getHeight(9), bottom: context.getHeight(4)),
            width: double.infinity,
            height: context.getHeight(38),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: context.getHeight(24),
                  padding: EdgeInsets.only(
                    left: 20,
                  ),
                  child: Image(
                    image: AssetImage("assets/images/google.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                Text("Register dengan Google",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0XFF333333),
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w400,
                    )),
                SizedBox(
                  width: context.getWidth(24),
                  height: context.getHeight(24),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Container(
            child: RichText(
              text: TextSpan(
                text: "Sudah punya akun? ",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(
                    text: "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        widget.pageController.jumpToPage(1);
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
                text: "Register sebagai penjual? ",
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
                        print("Pindah ke halaman register penjual");
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
