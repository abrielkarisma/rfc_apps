import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/auth.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
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
  final TextEditingController _verifPhoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _showPasswordError = false;
  String _selectedRole = '';
  final AuthService _authService = AuthService();

  
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _roleError;

  void _validateAndSubmit() async {
    setState(() {
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _roleError = null;
    });
    String nomer = _phoneNumberController.text;
    bool hasError = false;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final phoneRegex = RegExp(r'^08\d+$');
    
    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

    if (_emailController.text.isEmpty) {
      _emailError = 'Masukkan email anda';
      hasError = true;
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      _emailError = 'Masukkan email yang valid';
      hasError = true;
    }
    if (_phoneNumberController.text.isEmpty) {
      _phoneError = 'Masukkan nomor telepon anda';
      hasError = true;
    } else if (!phoneRegex.hasMatch(_phoneNumberController.text)) {
      _phoneError = 'Nomor telepon harus diawali dengan 08';
      hasError = true;
    }
    if (_passwordController.text.isEmpty) {
      _passwordError = 'Masukkan password anda';
      hasError = true;
    } else if (!passwordRegex.hasMatch(_passwordController.text)) {
      _passwordError =
          'Password harus minimal 8 karakter, mengandung setidaknya satu huruf besar, satu huruf kecil, satu angka, dan satu simbol';
      hasError = true;
    }
    if (_confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = 'Masukkan konfirmasi password anda';
      hasError = true;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordError = 'Password tidak sama';
      hasError = true;
    }
    if (_selectedRole.isEmpty) {
      _roleError = 'Pilih role anda';
      hasError = true;
    }
    if (hasError) {
      setState(() {});
      return;
    }
    String name = _emailController.text
        .split('@')
        .first
        .replaceAll(RegExp(r'[^ -\\w]'), ' ');
    String role = '';
    if (_selectedRole == 'PEMBELI') {
      role = 'user';
    } else if (_selectedRole == 'PENJUAL') {
      role = 'penjual';
    }
    try {
      final verifRegist = await _authService.registerUser(
        name,
        _emailController.text,
        _phoneNumberController.text,
        _passwordController.text,
        _confirmPasswordController.text,
        role,
      );
      if (verifRegist.message == 'User created') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              phoneNumber: nomer,
            ),
          ),
        );
      } else if (verifRegist.message ==
          'Email sudah terdaftar namun belum diaktifkan, silahkan melakukan login untuk mengaktifkan akun') {
        _modalLogin();
      } else {
        ToastHelper.showErrorToast(
            context,
            verifRegist.message.isNotEmpty
                ? verifRegist.message
                : 'Terjadi kesalahan, silahkan coba lagi');
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, 'Terjadi kesalahan: $e');
    }
  }

  Future<void> _verifyUserInput(String phoneNumber) async {
    String userInput = _verifPhoneController.text.trim();
    if (userInput == phoneNumber) {
      final resultResend = await AuthService().resendOTP(userInput);
      if (resultResend.status == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              phoneNumber: userInput,
            ),
          ),
        );
      } else {
        ToastHelper.showErrorToast(context, resultResend.message);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            phoneNumber: userInput,
          ),
        ),
      );
    } else {
      ToastHelper.showErrorToast(context,
          'Nomor telepon tidak sama dengan yang pernah didaftarkan, silakan coba lagi.');
    }
  }

  Future<void> _modalLogin() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "Pemberitahuan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "poppins",
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            "Email sudah terdaftar namun belum diaktifkan. Silahkan login untuk mengaktifkan akun Anda.",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "poppins",
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.pageController.jumpToPage(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "poppins",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
          if (_emailError != null)
            Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Text(
                _emailError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
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
          if (_phoneError != null)
            Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Text(
                _phoneError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
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
                    _isObscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
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
          if (_passwordError != null)
            Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Text(
                _passwordError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
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
                  _showPasswordError = _passwordController.text !=
                      _confirmPasswordController.text;
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
          if (_confirmPasswordError != null)
            Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Text(
                _confirmPasswordError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
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
              animationDuration: Duration(milliseconds: 500), 
            ),
          ),
          if (_roleError != null)
            Padding(
              padding: EdgeInsets.only(left: 8, top: 2),
              child: Text(
                _roleError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
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
      ),
    );
  }
}
