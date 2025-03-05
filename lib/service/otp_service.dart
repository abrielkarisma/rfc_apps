import 'dart:math';
import 'package:http/http.dart' as http;

class WhatsAppService {
  final String apiKey;
  String? storedOtp;
  DateTime? otpExpirationTime;
  bool isOtpUsed = false;

  WhatsAppService({required this.apiKey});
  String generateOtp() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  Future<void> sendOtpViaWhatsApp(String phoneNumber, String otpCode) async {
    const String apiUrl = "https://api.fonnte.com/send"; 

    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    request.headers['Authorization'] = apiKey;
    request.fields['target'] = phoneNumber;
    request.fields['message'] = "Kode OTP Anda adalah: $otpCode";
    request.fields['countryCode'] = "62"; // Kode negara Indonesia

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print("OTP berhasil dikirim!");
        storedOtp = otpCode; 
        otpExpirationTime =
            DateTime.now().add(Duration(minutes: 5)); // Set waktu kedaluwarsa
        isOtpUsed = false; // Reset status penggunaan OTP
      } else {
        print("Gagal mengirim OTP. Status code: ${response.statusCode}");
        var errorData = await response.stream.bytesToString();
        print("Error: $errorData");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  bool verifyOtp(String userInput) {
    if (isOtpUsed) {
      print("OTP sudah digunakan!");
      return false;
    }

    if (otpExpirationTime == null ||
        DateTime.now().isAfter(otpExpirationTime!)) {
      print("OTP sudah kedaluwarsa!");
      return false;
    }

    if (userInput == storedOtp) {
      isOtpUsed = true; 
      return true;
    }

    return false;
  }
}
