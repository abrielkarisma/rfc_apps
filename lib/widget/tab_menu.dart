import 'package:flutter/material.dart';

class TabMenu extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final PageController pageController;
  final Function(int) onTabChanged;

  const TabMenu({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.pageController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                onTabChanged(index);
                pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected ? Colors.green[100] : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      width: isSelected ? 30 : 0,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}