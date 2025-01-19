import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/adminbackground.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                height: 100,
                decoration: BoxDecoration(// Sesuaikan dengan kebutuhan
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rooftop",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontFamily: "Monserrat_Alternates",
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      "Farming",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontFamily: "Monserrat_Alternates",
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      "Center.",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontFamily: "Monserrat_Alternates",
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: context.getHeight(470),
                width: context.getWidth(400),
                margin: EdgeInsets.only(
                    left: 20, right: 20, top: context.getHeight(459)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.getWidth(400),
                      height: context.getHeight(100),
                      child: Text(
                        "Login Admin",
                        style: TextStyle(
                            color: Color(0xFF6BC0CA),
                            fontSize: 36,
                            fontFamily: "poppins",
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: context.getHeight(36))),
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
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "yourmail@mail.com",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // 10 radius
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
                                color: Color(0xFF6BC0CA),
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
                              color: Color(0xFF6BC0CA),
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
                      margin: EdgeInsets.only(
                          top: context.getHeight(7),
                          bottom: context.getHeight(14)),
                      width: double.infinity,
                      child: Text(
                        "Lupa Password?",
                        style: TextStyle(
                          color: Color(0xFF6BC0CA),
                          fontSize: 12,
                          fontFamily: "poppins",
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: context.getHeight(54),
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          backgroundColor: Color(0xFF6BC0CA),
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
                            text: "Kembali ke halaman utama? ",
                            style: TextStyle(
                              color: Color(0xFF6BC0CA),
                              fontSize: 12,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w300,
                            ),
                            children: [
                              TextSpan(
                                text: "Disini",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ])));
  }
}
