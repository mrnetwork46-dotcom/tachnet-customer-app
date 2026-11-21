import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const DashboardScreen({super.key, required this.onLogout});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _customer;
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Map<String, dynamic> _extractCustomer(Map<String, dynamic> response) {
    dynamic data = response['customer'] ?? response['data'] ?? response;
    if (data is Map<String, dynamic>) {
      // Some API responses wrap customer data one level deeper.
      final nested = data['customer'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return {};
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ApiService.dashboard();
      if (!mounted) return;
      setState(() => _customer = _extractCustomer(result));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _value(String key, [String fallback = '—']) {
    final value = _customer?[key];
    if (value == null || value.toString().trim().isEmpty) return fallback;
    return value.toString();
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final name = _value('name', 'Customer');
    return Scaffold(
      appBar: AppBar(
        title: const Text('TACH Customer'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2878D0), Color(0xFF55A1E8)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('স্বাগতম',
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 5),
                            Text(name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 8),
                            Text('Customer ID: ${_value('customer_id')}',
                                style: const TextStyle(color: Colors.white)),
                            Text('Status: ${_value('status')}',
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: 'বর্তমান বকেয়া',
                              value: '৳ ${_value('due', '0')}',
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              title: 'অগ্রিম জমা',
                              value: '৳ ${_value('advance', '0')}',
                              icon: Icons.savings_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DetailCard(
                        title: 'সংযোগের তথ্য',
                        rows: {
                          'মোবাইল': _value('phone'),
                          'Username': _value('username'),
                          'ঠিকানা': _value('address'),
                          'এলাকা': _value('area'),
                          'প্যাকেজ': _value('package'),
                          'স্পিড': _value('package_speed'),
                          'মাসিক বিল': '৳ ${_value('monthly_fee')}',
                          'মেয়াদ শেষ': _value('expire_date'),
                          'অনলাইন অবস্থা': _value('online_status'),
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'পরবর্তী আপডেট',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'এই প্রথম সংস্করণে লগইন ও গ্রাহক ড্যাশবোর্ড যুক্ত করা হয়েছে। '
                        'মাসিক বিল, পেমেন্ট হিস্ট্রি, অভিযোগ এবং নোটিফিকেশন পরের ধাপে যুক্ত হবে।',
                        style: TextStyle(color: Color(0xFF718096), height: 1.5),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _InfoCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Color(0xFFDCE3EC), blurRadius: 12, offset: Offset(4, 4)),
          BoxShadow(
              color: Colors.white, blurRadius: 12, offset: Offset(-4, -4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2878D0)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF718096))),
          const SizedBox(height: 5),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final Map<String, String> rows;
  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF8FAFD),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...rows.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(entry.key,
                            style: const TextStyle(color: Color(0xFF718096))),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(entry.value,
                            textAlign: TextAlign.end,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('আবার চেষ্টা করুন')),
          ],
        ),
      ),
    );
  }
}
