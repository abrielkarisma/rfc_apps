import 'package:flutter/material.dart';
import 'manageRFC.dart';
import 'managePjawab.dart';

const Color appPrimaryColor = Color(0xFF6BC0CA);
const Color appPendingColor = Colors.orangeAccent;
const Color appCompletedColor = appPrimaryColor;
const Color appRejectedColor = Colors.redAccent;

class RFCManagementTabView extends StatefulWidget {
  const RFCManagementTabView({super.key});

  @override
  State<RFCManagementTabView> createState() => _RFCManagementTabViewState();
}

class _RFCManagementTabViewState extends State<RFCManagementTabView> {
  final PageController _pageController = PageController();
  String _selectedStatus = 'rfc';
  final List<String> _statusOptions = ['rfc', 'pjawab'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              ManageRFCPageContent(),
              ManagePjawabPageContent(),
            ],
          ),
        ),
      ],
    );
  }

  void _onPageChanged(int index) {
    if (index < _statusOptions.length) {
      final newStatus = _statusOptions[index];
      if (newStatus != _selectedStatus) {
        setState(() {
          _selectedStatus = newStatus;
        });
      }
    }
  }

  void _changeStatusFilter(String? newStatus) {
    if (newStatus != null && newStatus != _selectedStatus) {
      setState(() {
        _selectedStatus = newStatus;
      });

      
      final index = _statusOptions.indexOf(newStatus);
      if (index != -1) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  String _formatStatusRFC(String? status) {
    switch (status?.toLowerCase()) {
      case 'rfc':
        return 'RFC';
      case 'pjawab':
        return 'Penanggung Jawab';
      default:
        return status ?? 'Unknown';
    }
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_statusOptions.length, (index) {
          final status = _statusOptions[index];
          final bool isSelected = status == _selectedStatus;
          return Expanded(
            child: GestureDetector(
              onTap: () => _changeStatusFilter(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected
                        ? appPrimaryColor.withOpacity(0.1)
                        : Colors.transparent),
                child: Column(
                  children: [
                    Text(
                      _formatStatusRFC(status),
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? appPrimaryColor : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      width: isSelected ? 30 : 0,
                      decoration: BoxDecoration(
                        color: appPrimaryColor,
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
