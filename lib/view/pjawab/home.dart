import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rfc_apps/extension/screen_flexible.dart';
import 'package:rfc_apps/view/pjawab/penarikan/penarikan.dart';
import 'package:rfc_apps/view/pjawab/user/user_list.dart';

class PjawabHome extends StatefulWidget {
  const PjawabHome({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<PjawabHome> createState() => _PjawabHomeState();
}

class _PjawabHomeState extends State<PjawabHome> {
  late int _selectedIndex;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  late final List<Widget> _widgetOptions = <Widget>[
    UserList(),
    AdminRequestPenarikanPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Rooftop Farming Center.",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: "Monserrat_Alternates",
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: SvgPicture.asset(
            "assets/images/admin_background.svg",
            fit: BoxFit.cover,
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                left: 20, right: 20, top: context.getHeight(100), bottom: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Admin",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: context.getHeight(16)),
              Expanded(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ]))
      ]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 4.0,
            right: 4.0,
            top: 8.0,
            bottom: MediaQuery.of(context).padding.bottom + 8.0,
          ),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 4,
            activeColor: Colors.white,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            duration: Duration(milliseconds: 300),
            tabBackgroundColor: Color(0xFF6BC0CA),
            color: Color(0xFF6BC0CA),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            tabs: [
              GButton(
                icon: LineIcons.users,
                text: 'Kelola Penjual',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
              GButton(
                icon: LineIcons.moneyBill,
                text: 'Penarikan',
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
