import 'package:flutter/material.dart';
import 'package:rfc_apps/view/auth/login_pembeli.dart';
import 'package:rfc_apps/view/auth/register_pembeli.dart';
import 'package:rfc_apps/widget/RFCLogo.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/authbackground.png',
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: RFCLogo(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    // color: Colors.red,
                    height: context.getHeight(510),
                    width: context.getWidth(400),
                    margin: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: context.getHeight(20)),
                    child: PageView(
                      // physics: NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      children: [
                        AuthWidget(pageController: _pageController),
                        LoginPembeliWidget(pageController: _pageController),
                        RegisterPembeliWidget(pageController: _pageController),
                      ],
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AuthWidget extends StatefulWidget {
  final PageController pageController;

  const AuthWidget({
    super.key,
    required this.pageController,
  });

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.getHeight(70),
          width: context.getWidth(400),
          child: Text(
            "Mulai Sekarang",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 36,
                fontFamily: "poppins",
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.start,
          ),
        ),
        Padding(padding: EdgeInsets.only(top: context.getHeight(72))),
        Container(
          width: double.infinity,
          height: context.getHeight(54),
          child: TextButton(
            onPressed: () {
              widget.pageController.jumpToPage(1);
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
        Padding(padding: EdgeInsets.only(top: context.getHeight(21.5))),
        Container(
          width: double.infinity,
          height: context.getHeight(54),
          child: TextButton(
            onPressed: () {
              widget.pageController.jumpToPage(2);
            },
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              backgroundColor: Colors.white,
            ),
            child: Text(
              'Register',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
                fontFamily: "poppins",
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: context.getHeight(34.5))),
        Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Color(0XFF333333), thickness: 1.5),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Atau login dengan",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 12,
                      color: Color(0XFF333333),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: Color(0XFF333333), thickness: 1.5),
                ),
              ],
            )),
        Padding(padding: EdgeInsets.only(top: context.getHeight(34.5))),
        GestureDetector(
          onTap: () {
            print("anjai");
          },
          child: Container(
            width: double.infinity,
            height: context.getHeight(38),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: context.getHeight(24),
                  padding: EdgeInsets.only(
                    left: 20,
                  ),
                  child: Image(
                    image: AssetImage("assets/images/google.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                Text("Register dengan Google",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0XFF333333),
                      fontFamily: "poppins",
                      fontWeight: FontWeight.w400,
                    )),
                SizedBox(
                  width: context.getWidth(24),
                  height: context.getHeight(24),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
