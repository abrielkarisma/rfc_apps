import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/auth.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/auth/otp.dart';
import 'package:rfc_apps/view/pembeli/homepage/homepage.dart';
import 'package:rfc_apps/view/penjual/home.dart';

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
  final TextEditingController _verifPhoneController = TextEditingController();

  void _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;

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
    try {
      final login = await AuthService().loginUser(email, password);
      if (login.status == true) {
        ToastHelper.showSuccessToast(context, 'Login berhasil');
        final tokenStorage = FlutterSecureStorage();
        await tokenStorage.write(key: 'token', value: login.token);
        String tokens = await tokenStorage.read(key: 'token') ?? '';
        print(tokens);
        final role = login.data?.role;
        if (role == 'user') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/homepage',
            (Route<dynamic> route) => false,
          );
        } else if (role == 'penjual') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home_seller',
            (Route<dynamic> route) => false,
          );
        } else if (role == 'pjawab') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login_admin',
            (Route<dynamic> route) => false,
          );
        } else {
          ToastHelper.showErrorToast(context, 'Role tidak ditemukan');
        }
      } else if (login.status == false) {
        if (login.message == 'Email belum diaktifkan') {
          String email = _emailController.text;
          final phoneResult = await AuthService().getPhonebyEmail(email);
          String phoneNumber = phoneResult.data!.phoneNumber;
          ModalAktivate(phoneNumber);
        } else if (login.message != 'Email belum diaktifkan') {
          ToastHelper.showErrorToast(context, login.message);
        }
        ;
      } else {
        ToastHelper.showErrorToast(
            context, login.message ?? 'Terjadi kesalahan, silahkan coba lagi');
      }
    } catch (error) {
      ToastHelper.showErrorToast(
          context, 'Terjadi kesalahan, periksa koneksi Anda');
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

  Future<dynamic> ModalAktivate(String phoneNumber) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Akun Anda Sudah Pernah Dibuat, Namun Belum Diaktivasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "poppins",
                    color: Theme.of(context).primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Lakukan verifikasi dengan memasukkan nomor yang telah Anda daftarkan: ${phoneNumber.replaceRange(3, phoneNumber.length - 3, '*' * (phoneNumber.length - 6))}",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "poppins",
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _verifPhoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Masukkan nomor telepon",
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
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _verifyUserInput(phoneNumber);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Verifikasi",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "poppins",
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            height: context.getHeight(33),
            margin: EdgeInsets.only(
                top: context.getHeight(7), bottom: context.getHeight(14)),
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/lupa_password');
              },
              child: Text("Lupa Password?",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w500,
                  )),
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
        ],
      ),
    );
  }
}
