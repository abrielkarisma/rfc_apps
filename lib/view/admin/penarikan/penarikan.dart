import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rfc_apps/service/saldo.dart';
import 'package:rfc_apps/utils/date_formatter.dart';
import 'package:rfc_apps/utils/currency_formatter.dart';
import 'package:rfc_apps/view/admin/penarikan/prosesPenarikan.dart';
import 'package:shimmer/shimmer.dart';

const Color appPrimaryColor = Color(0xFF6BC0CA);
const Color appPendingColor = Colors.orangeAccent;
const Color appCompletedColor = appPrimaryColor;
const Color appRejectedColor = Colors.redAccent;

class AdminRequestPenarikanPage extends StatefulWidget {
  const AdminRequestPenarikanPage({super.key});

  @override
  State<AdminRequestPenarikanPage> createState() =>
      _AdminRequestPenarikanPageState();
}

class _AdminRequestPenarikanPageState extends State<AdminRequestPenarikanPage> {
  final SaldoService _saldoService = SaldoService();
  final List<Map<String, dynamic>> _requests = [];
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  Timer? _timer;

  String _selectedStatus = 'pending';
  final List<String> _statusOptions = ['pending', 'completed', 'rejected'];

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRequests(isRefresh: true);
    _scrollController.addListener(_onScroll);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchRequests(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _requests.clear();
      _errorMessage = null;
      setState(() {
        _isLoading = true;
      });
    } else {
      if (_currentPage >= _totalPages || _isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _saldoService.getAllPenarikanSaldoRequests(
        status: _selectedStatus,
        page: _currentPage,
        limit: 10,
      );
      final List<dynamic> newRequests =
          response['data'] as List<dynamic>? ?? [];

      setState(() {
        _requests.addAll(newRequests.cast<Map<String, dynamic>>());
        _totalPages = response['totalPages'] as int? ?? 1;
        if (newRequests.isNotEmpty && _currentPage < _totalPages) {
          _currentPage++;
        } else if (newRequests.isEmpty && _currentPage < _totalPages) {
        } else if (newRequests.isNotEmpty && _currentPage == _totalPages) {}
        if (newRequests.isNotEmpty) {
          if (_currentPage < (response['totalPages'] as int? ?? 1)) {
            _currentPage++;
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().length > 100
            ? 'Terjadi kesalahan server.'
            : e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage <= _totalPages) {
      _fetchRequests();
    }
  }

  void _changeStatusFilter(String? newStatus) {
    if (newStatus != null && newStatus != _selectedStatus) {
      setState(() {
        _selectedStatus = newStatus;
      });
      _fetchRequests(isRefresh: true);

      
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

  void _onPageChanged(int index) {
    if (index < _statusOptions.length) {
      final newStatus = _statusOptions[index];
      if (newStatus != _selectedStatus) {
        setState(() {
          _selectedStatus = newStatus;
        });
        _fetchRequests(isRefresh: true);
      }
    }
  }

  String _formatStatusPenarikan(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }

  Color _getColorForStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return appPendingColor;
      case 'completed':
        return appCompletedColor;
      case 'rejected':
        return appRejectedColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _statusOptions.length,
            itemBuilder: (context, index) {
              return RefreshIndicator(
                onRefresh: () => _fetchRequests(isRefresh: true),
                color: appPrimaryColor,
                child: _buildRequestList(),
              );
            },
          ),
        ),
      ],
    );
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
                      _formatStatusPenarikan(status),
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

  Widget _buildRequestList() {
    if (_isLoading && _requests.isEmpty) {
      return _buildLoadingShimmerList();
    } else if (_errorMessage != null && _requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.red.shade400, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                onPressed: () => _fetchRequests(isRefresh: true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                    foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      );
    } else if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
                'Tidak ada permintaan penarikan dengan status "${_formatStatusPenarikan(_selectedStatus)}".',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: _requests.length + (_isLoadingMore ? 1 : 0),
      padding: const EdgeInsets.all(12.0),
      itemBuilder: (context, index) {
        if (index == _requests.length) {
          return _buildLoadingMoreIndicator();
        }
        final request = _requests[index];
        final Map<String, dynamic>? userData =
            request['user'] as Map<String, dynamic>?;
        final Map<String, dynamic>? rekeningData =
            request['rekening'] as Map<String, dynamic>?;
        final String status = request['status']?.toString() ?? 'unknown';

        return Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          shadowColor: Colors.grey.withOpacity(0.3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminProsesPenarikanPage(
                      requestData: request,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchRequests(isRefresh: true);
                }
              },
              borderRadius: BorderRadius.circular(16.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData?['name'] ?? 'Nama Pengguna Tidak Ada',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Colors.grey.shade500,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      userData?['email'] ?? 'Email Tidak Ada',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorForStatus(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _getColorForStatus(status).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getIconForStatus(status),
                                  color: _getColorForStatus(status), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _formatStatusPenarikan(status),
                                style: TextStyle(
                                    color: _getColorForStatus(status),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                              Icons.payments_outlined,
                              'Jumlah Diminta:',
                              CurrencyFormatter.formatRupiah(
                                  request['jumlahDiminta'])),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                              Icons.receipt_long_outlined,
                              'Jumlah Diterima:',
                              CurrencyFormatter.formatRupiah(
                                  request['jumlahDiterima'])),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.account_balance, 'Rekening:',
                              '${rekeningData?['namaBank'] ?? '-'} (${rekeningData?['nomorRekening'] ?? '-'})'),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.person_outline, 'Atas Nama:',
                              '${rekeningData?['namaPemilikRekening'] ?? rekeningData?['namaPenerima'] ?? '-'}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey.shade500,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Diajukan: ${DateFormatter.formatTanggalSingkat(request['tanggalRequest']?.toString())} ${DateFormatter.formatJam(request['tanggalRequest']?.toString())}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: appPrimaryColor),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingShimmerList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: 150, height: 18.0, color: Colors.white),
                        Container(width: 80, height: 20.0, color: Colors.white),
                      ]),
                  const SizedBox(height: 8),
                  Container(width: 200, height: 12.0, color: Colors.white),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(width: 180, height: 12.0, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(color: appPrimaryColor),
      ),
    );
  }
}
