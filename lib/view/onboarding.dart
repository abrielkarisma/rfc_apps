import 'package:flutter/material.dart';
import 'package:rfc_apps/view/auth/auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/onboardingbackground.png',
                fit: BoxFit.fill,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
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
              child: Center(
                child: Container(
                  height: context.getHeight(439),
                  child: PageView(
                    controller: _controller,
                    children: [
                      Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              width: context.getWidth(290),
                              height: context.getHeight(270),
                              child: Center(
                                  child: Image(
                                image: AssetImage('assets/images/obd1.png'),
                                fit: BoxFit.fitHeight,
                              ))),
                          Container(
                            width: context.getWidth(250),
                            child: RichText(
                              text: TextSpan(
                                text: "Temukan Hasil Panen ",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.normal,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Segar",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: " dan "),
                                  TextSpan(
                                    text: "Berkualitas",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )),
                      Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: context.getWidth(290),
                            height: context.getHeight(274),
                            child: Center(
                                child: Image(
                              image: AssetImage('assets/images/obd2.png'),
                              fit: BoxFit.fitHeight,
                            )),
                          ),
                          Container(
                            width: context.getWidth(250),
                            child: RichText(
                              text: TextSpan(
                                text: "Belanja ",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.normal,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Mudah",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: " dengan "),
                                  TextSpan(
                                    text: "Sistem Digital",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )),
                      Container(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: context.getWidth(290),
                            height: context.getHeight(274),
                            child: Center(
                                child: Image(
                              image: AssetImage('assets/images/obd3.png'),
                              fit: BoxFit.fitHeight,
                            )),
                          ),
                          Container(
                            width: context.getWidth(335),
                            child: RichText(
                              text: TextSpan(
                                text: "Mari Kita Dukung ",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontFamily: "poppins",
                                  fontWeight: FontWeight.normal,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Pertanian Berkelanjutan",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(bottom: context.getHeight(64)),
              child: Center(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: ExpandingDotsEffect(
                          dotWidth: 10,
                          dotHeight: 10,
                          activeDotColor: Colors.white,
                          dotColor: Colors.grey,
                        ),
                        onDotClicked: (index) {
                          _controller.animateToPage(
                            index,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      Padding(padding: EdgeInsets.only(top: 74)),
                      SizedBox(
                        width: 335,
                        child: TextButton(
                          onPressed: () {
                            int currentPage = _controller.page?.toInt() ?? 0;
                            if (currentPage < 2) {
                              _controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AuthScreen()));
                            }
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ],
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
