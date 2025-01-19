import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/model/artikel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ArtikelCarousel extends StatefulWidget {
  final List<Artikel> artikels;

  ArtikelCarousel({required this.artikels});

  @override
  State<ArtikelCarousel> createState() => _ArtikelCarouselState();
}

class _ArtikelCarouselState extends State<ArtikelCarousel> {
  int _currentPage = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    List<Artikel> sortedArtikels = widget.artikels
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    List<Artikel> limitedArtikels = sortedArtikels.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: context.getHeight(163),
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: context.getHeight(163),
                    autoPlay: false,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    padEnds: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                  ),
                  items: limitedArtikels.map((artikel) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(right: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            image: DecorationImage(
                              image: NetworkImage(artikel.images),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: 20.0, bottom: 10.0),
                                      width: 250,
                                      height: 90,
                                      child: Text(
                                        artikel.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "poppins",
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                          backgroundColor:
                                              Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 125,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(14.0),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          print(artikel.id);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Baca Artikel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.getHeight(13)),
        SmoothPageIndicator(
          controller: PageController(initialPage: _currentPage),
          count: limitedArtikels.length,
          effect: ExpandingDotsEffect(
            dotWidth: 10,
            dotHeight: 10,
            activeDotColor: Theme.of(context).primaryColor,
            dotColor: Color(0xFFE0E0E0),
          ),
          onDotClicked: (index) {
            _carouselController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }
}
