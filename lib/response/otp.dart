class OtpResponse {
  final bool status;
  final String message;
  final OtpData data;

  OtpResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? OtpData.fromJson(json['data'])
          : OtpData(id: '', name: '', phoneNumber: ''),
    );
  }
  @override
  String toString() {
    return 'status: $status, message: $message, data: $data';
  }
}

class OtpData {
  final String id;
  final String name;
  final String phoneNumber;

  OtpData({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) {
    return OtpData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone'] ?? '',
    );
  }
@override
  String toString() {
    return 'id: $id, name: $name, phoneNumber: $phoneNumber';
  }
 
}

class resendOTPResponse{
 final bool status; 
 final String message;

  resendOTPResponse({
    required this.status,
    required this.message
  });

  factory resendOTPResponse.fromJson(Map<String, dynamic> json) {
    return resendOTPResponse(
    status: json['status'] ?? '',
     message: json['message'] ?? '',
    );
  }
@override
  String toString() {
    return 'status: $status, message: $message';
  }
}