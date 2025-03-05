import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/auth_service.dart';
import 'package:rfc_apps/service/otp_service.dart';
import 'package:rfc_apps/view/auth/otp.dart';
import 'package:rfc_apps/widget/radio_button.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showPasswordError = false;
  String _selectedRole = '';
  final AuthService _authService = AuthService();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateAndSubmit() async {
    String nomer = _phoneNumberController.text;
    if (_emailController.text.isEmpty) {
      _showSnackBar('Masukkan email anda');
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showSnackBar('Masukkan email yang valid');
      return;
    }
    if (_phoneNumberController.text.isEmpty) {
      _showSnackBar('Masukkan nomor telepon anda');
      return;
    }
    final phoneRegex = RegExp(r'^08\d+$');
    if (!phoneRegex.hasMatch(_phoneNumberController.text)) {
      _showSnackBar('Nomor telepon harus diawali dengan 08');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showSnackBar('Masukkan password anda');
      return;
    }
    if (_passwordController.text.length < 8) {
      _showSnackBar('Password minimal 8 karakter');
      return;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _showSnackBar('Masukkan konfirmasi password anda');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Password tidak sama');
      return;
    }
    if (_selectedRole.isEmpty) {
      _showSnackBar('Pilih role anda');
      return;
    } else {
      final checkmail = await _authService.checkEmail(_emailController.text);
      print(checkmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: context.getHeight(40),
          width: double.infinity,
          child: Text(
            "Buat Akun Baru",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 28,
                fontFamily: "poppins",
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: context.getHeight(7)),
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
            "nomor telepon",
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
              controller: _phoneNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "08**********",
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
        Container(
          margin: EdgeInsets.only(top: context.getHeight(7)),
          child: Text(
            "daftar sebagai",
            style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: context.getHeight(7)),
          width: double.infinity,
          child: CustomRadioGroup(
            options: const ['PEMBELI', 'PENJUAL'],
            selectedValue: _selectedRole,
            onChanged: (value) => setState(() => _selectedRole = value),
            activeColor: Theme.of(context).primaryColor,
            animationDuration: Duration(milliseconds: 500), // Custom duration
          ),
        ),
        Container(
          width: double.infinity,
          height: context.getHeight(45),
          margin: EdgeInsets.only(top: context.getHeight(7)),
          child: TextButton(
            onPressed: () {
              _validateAndSubmit();
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
      ],
    );
  }
}
