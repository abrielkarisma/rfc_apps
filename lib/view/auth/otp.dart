import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/user.dart';
import 'package:rfc_apps/service/auth.dart';
import 'package:rfc_apps/utils/toastHelper.dart';
import 'package:rfc_apps/view/auth/auth.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  OTPVerificationPage({
    required this.phoneNumber,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  bool _isResendButtonEnabled = true;
  int _resendCooldown = 60;
  Timer? _timer;

  void _resendOTP() async {
    try {
      final resendOtp = await AuthService().resendOtp(
        widget.phoneNumber,
      );
      if (resendOtp.message == "OTP Berhasil dikirim") {
        ToastHelper.showSuccessToast(context, resendOtp.message);
        _startResendCooldown();
      } else {
        ToastHelper.showErrorToast(context, resendOtp.message);
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, "Terjadi kesalahan: $e");
    }
  }

  void _verifyOtp() async {
    try {
      final whatsappOtp = await AuthService().verifyOtp(
        otp: _controllers.map((controller) => controller.text).join(),
        phone_number: widget.phoneNumber,
      );

      if (whatsappOtp.status == true) {
        dialogSuccess();
      } else if (whatsappOtp.status == false &&
          whatsappOtp.message == "Phone number already activated") {
        ToastHelper.showInfoToast(
            context, "Akun anda sudah aktif, silahkan login");
      } else if (whatsappOtp.status == false) {
        ToastHelper.showErrorToast(context, whatsappOtp.message);
      }
    } catch (e) {
      ToastHelper.showErrorToast(context, "Terjadi kesalahan: $e");
    }
  }

  void _startResendCooldown() {
    setState(() {
      _isResendButtonEnabled = false;
      _resendCooldown = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _isResendButtonEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<dynamic> dialogSuccess() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                "Registrasi Berhasil!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "poppins",
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            "Akun Anda telah aktif. Silakan login untuk melanjutkan.",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "poppins",
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => AuthScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w500,
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
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifikasi OTP',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: "poppins"),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: 'Masukkan Kode OTP yang Dikirim ke Nomor Whatsapp ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  fontFamily: "poppins",
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: widget.phoneNumber,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rooftop",
                  style: TextStyle(
                    fontSize: 36,
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Monserrat_Alternates",
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  "Farming",
                  style: TextStyle(
                    fontSize: 36,
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Monserrat_Alternates",
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  "Center.",
                  style: TextStyle(
                    fontSize: 36,
                    color: Theme.of(context).primaryColor,
                    fontFamily: "Monserrat_Alternates",
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.0)),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: _isResendButtonEnabled ? _resendOTP : null,
                  child: Text(
                    _isResendButtonEnabled
                        ? "Tidak menerima kode? Kirim ulang kode"
                        : "Tunggu $_resendCooldown detik untuk kirim ulang",
                    style: TextStyle(
                      color: _isResendButtonEnabled
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: context.getHeight(54),
              child: TextButton(
                onPressed: () {
                  _verifyOtp();
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Verifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: "poppins",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
