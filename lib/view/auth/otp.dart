import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/service/otp_service.dart';

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
  final TextEditingController _phoneNumberController = TextEditingController();

  final WhatsAppService whatsAppService =
      WhatsAppService(apiKey: "zP19yXtcXNPntw34Gagx");

  void _sendOtp() async {
    String otpCode = whatsAppService.generateOtp();
    await whatsAppService.sendOtpViaWhatsApp(widget.phoneNumber, otpCode);
  }

  void _verifyOtp() {
    bool isValid = whatsAppService
        .verifyOtp(_controllers.map((controller) => controller.text).join());

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Valid!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Tidak Valid atau Sudah Kedaluwarsa!")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < _controllers.length - 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
    _sendOtp();
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Masukkan Kode OTP yang dikirim ke ${widget.phoneNumber}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "poppins"),
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
            Container(
              width: double.infinity,
              height: context.getHeight(54),
              child: TextButton(
                onPressed: () {
                  String otp =
                      _controllers.map((controller) => controller.text).join();
                  print('OTP Entered: $otp');
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
