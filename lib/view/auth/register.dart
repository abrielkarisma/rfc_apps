import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/auth.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/auth/otp.dart';
import 'package:rfc_apps/widget/radio_button.dart';
import 'package:toastification/toastification.dart';

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

  void _validateAndSubmit() async {
    String nomer = _phoneNumberController.text;
    if (_emailController.text.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan email anda');
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text)) {
      ToastHelper.showErrorToast(context, 'Masukkan email yang valid');
      return;
    }
    if (_phoneNumberController.text.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan nomor telepon anda');
      return;
    }
    final phoneRegex = RegExp(r'^08\d+$');
    if (!phoneRegex.hasMatch(_phoneNumberController.text)) {
      ToastHelper.showErrorToast(
          context, 'Nomor telepon harus diawali dengan 08');
      return;
    }
    if (_passwordController.text.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan password anda');
      return;
    }
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!passwordRegex.hasMatch(_passwordController.text)) {
      ToastHelper.showErrorToast(context,
          'Password harus minimal 8 karakter, mengandung setidaknya satu huruf besar, satu huruf kecil, satu angka, dan satu simbol');
      return;
    }
    if (_confirmPasswordController.text.isEmpty) {
      ToastHelper.showErrorToast(context, 'Masukkan konfirmasi password anda');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ToastHelper.showErrorToast(context, 'Password tidak sama');
      return;
    }
    if (_selectedRole.isEmpty) {
      ToastHelper.showErrorToast(context, 'Pilih role anda');
      return;
    }
    String name = _emailController.text
        .split('@')
        .first
        .replaceAll(RegExp(r'[^\w]'), ' ');
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
          'Email already registered, please check your email to activate your account') {
        try {
          final result =
              await _authService.getPhonebyEmail(_emailController.text);
          print(result.status);
          if (result.status == true) {
            final phoneNumber = result.data!.phoneNumber;
            print('Phone number retrieved: $phoneNumber');
            ModalAktivate(phoneNumber);
          } else {
            ToastHelper.showErrorToast(context, result.message);
          }
        } catch (e) {
          print('Error in getPhonebyEmail: $e');
          ToastHelper.showErrorToast(context, 'Terjadi kesalahan: $e');
        }
      } else {
        ToastHelper.showErrorToast(context,
            verifRegist.message ?? 'Terjadi kesalahan, silahkan coba lagi');
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, 'Terjadi kesalahan: $e');
    }
  }

  Future<void> _verifyUserInput(String phoneNumber) async {
    String userInput = _verifPhoneController.text.trim();
    if (userInput == phoneNumber) {
      // ToastHelper.showSuccessToast(
      //     context, 'Nomor telepon berhasil diverifikasi!');
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
