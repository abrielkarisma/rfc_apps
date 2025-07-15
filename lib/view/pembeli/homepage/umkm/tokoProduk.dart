import 'package:flutter/material.dart';
import 'package:rfc_apps/widget/produk_grid.dart';
import 'dart:async';

class ProdukToko extends StatefulWidget {
  const ProdukToko({super.key, required this.idToko});
  final String idToko;
  @override
  State<ProdukToko> createState() => _ProdukTokoState();
}

class _ProdukTokoState extends State<ProdukToko> with TickerProviderStateMixin {
  Key _produkListKey = UniqueKey();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _produkListKey = UniqueKey();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
      _produkListKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
              Colors.grey[100]!,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Colors.white, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Produk Toko",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari produk yang kamu inginkan...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                              fontFamily: "Inter",
                            ),
                            prefixIcon: Container(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.search_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? _isSearching
                                    ? Padding(
                                        padding: EdgeInsets.all(12),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.clear_rounded,
                                            color: Colors.grey[400], size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                            _searchQuery = "";
                                            _isSearching = false;
                                            
                                            _produkListKey = UniqueKey();
                                          });
                                        },
                                      )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                          ),
                          onChanged: (value) {
                            
                            setState(() {
                              _isSearching = true;
                            });

                            
                            _debounceTimer?.cancel();

                            
                            _debounceTimer =
                                Timer(Duration(milliseconds: 500), () {
                              setState(() {
                                _searchQuery = value;
                                _isSearching = false;
                                
                                _produkListKey = UniqueKey();
                              });
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Semua Produk",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins",
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _refreshProducts();
                          },
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: ProdukGrid(
                              key: _produkListKey,
                              cardType: "byToko",
                              id: widget.idToko,
                              searchQuery: _searchQuery,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
