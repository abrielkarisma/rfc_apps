// if (_selectedRole == 'PEMBELI') {
//         final bool? isOtpValid = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => OTPVerificationPage(
//               phoneNumber: nomer,
//             ),
//           ),
//         );
//         if (isOtpValid == true) {
//           print('Email: ${_emailController.text}');
//           print('Nomor Telepon: ${_phoneNumberController.text}');
//           print('Password: ${_passwordController.text}');
//           print('Konfirmasi Password: ${_confirmPasswordController.text}');
//           print('Role: $_selectedRole');
//         }
//       }
//       // if (_selectedRole == 'PENJUAL') {
//       //   showDialog(
//       //     context: context,
//       //     builder: (BuildContext context) {
//       //       return AlertDialog(
//       //         title: Text('Data Tambahan Penjual'),
//       //         content: Column(
//       //           mainAxisSize: MainAxisSize.min,
//       //           children: [
//       //             Text(
//       //                 'Masukkan kode OTP yang telah dikirim ke nomor ${nomer.substring(0, 4)}****${nomer.substring(nomer.length - 3)}'),
//       //             TextField(
//       //               keyboardType: TextInputType.number,
//       //               controller: _otpController,
//       //               decoration: InputDecoration(
//       //                 hintText: 'Kode OTP',
//       //               ),
//       //             ),
//       //           ],
//       //         ),
//       //         actions: [
//       //           TextButton(
//       //             onPressed: () {
//       //               _verifyOtp();
//       //             },
//       //             child: Text('Verifikasi'),
//       //           ),
//       //         ],
//       //       );
//       //     },
//       //   );
//       // }
