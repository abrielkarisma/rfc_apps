import 'package:flutter/material.dart';
import 'package:rfc_apps/service/auth.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'dart:async';

class LupaPasswordPage extends StatefulWidget {
  @override
  State<LupaPasswordPage> createState() => _LupaPasswordPageState();
}

class _LupaPasswordPageState extends State<LupaPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool buttonCheck = false;
  bool isOTPSent = false;
  int countdown = 0;
  String phone = '';
  Timer? _timer;

  void _startCountdown() {
    setState(() {
      countdown = 60;
      isOTPSent = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          timer.cancel();
          isOTPSent = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOTP(email) async {
    final authService = AuthService();
    final result = await authService.forgotPassword(email);
    if (result.status == true) {
      setState(() {
        buttonCheck = true;
      });
      ToastHelper.showSuccessToast(context, 'OTP berhasil dikirim');
      phone = result.data.phoneNumber ?? '';
      _startCountdown();
    } else {
      ToastHelper.showErrorToast(context, result.message);
      ;
    }
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final otp = _otpController.text;

    if (email.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan email anda');
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ToastHelper.showErrorToast(context, 'Masukkan email yang valid');
      return;
    }

    if (password.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan password anda');
      return;
    }
    if (password.length < 8) {
      ToastHelper.showErrorToast(context, 'Password minimal 8 karakter');
      return;
    }

    if (confirmPassword.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan konfirmasi password anda');
      return;
    }
    if (password != confirmPassword) {
      ToastHelper.showErrorToast(
          context, 'Password dan konfirmasi password tidak sama');
      return;
    }

    if (otp.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan OTP anda');
      return;
    }

    final authService = AuthService();
    final result =
        await authService.resetPassword(email, password, confirmPassword, otp);
    if (result.status == true) {
      ToastHelper.showSuccessToast(context, 'Password berhasil diubah');
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      ToastHelper.showErrorToast(context, result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lupa Password',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Masukkan email Anda untuk menerima tautan reset password.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            Container(
              child: Text(
                "Email",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.01),
              height: MediaQuery.of(context).size.height * 0.06,
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "yourmail@mail.com",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                  ),
                  suffixIcon: TextButton(
                    onPressed: isOTPSent
                        ? null
                        : () {
                            _sendOTP(_emailController.text);
                          },
                    child: Text(
                      isOTPSent ? "Tunggu $countdown detik" : "Kirim OTP",
                      style: TextStyle(
                        color: isOTPSent
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        fontFamily: "Poppins",
                      ),
                    ),
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
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Text(
                "Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Masukkan password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Text(
                "Konfirmasi Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Konfirmasi password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (buttonCheck)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Masukkan OTP yang telah dikirim ke nomor ${phone.replaceRange(3, phone.length - 3, '*' * (phone.length - 6))}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            SizedBox(height: 20),
            Container(
              child: Text(
                "OTP",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                hintText: "Masukkan OTP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: buttonCheck ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor:
                    buttonCheck ? Theme.of(context).primaryColor : Colors.grey,
              ),
              child: Text(
                buttonCheck ? 'Kirim' : 'Silahkan kirim OTP terlebih dahulu',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(
                'Kembali ke Login',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
