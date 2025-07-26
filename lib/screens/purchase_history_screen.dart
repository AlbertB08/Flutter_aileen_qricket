import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/invoice_service.dart';
import '../services/event_service.dart';
import '../models/user_model.dart';
import '../models/invoice_model.dart';
import '../models/event_model.dart';
import 'invoice_details_screen.dart';
import 'base_screen.dart';

class PurchaseHistoryScreen extends BaseScreen {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends BaseScreenState<PurchaseHistoryScreen> {
  User? _currentUser;
  List<InvoiceModel> _userInvoices = [];
  List<EventModel> _allEvents = [];
  bool _isLoading = true;
  String _sortOption = 'DateNewest';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      showLoading();
      
      // Load current user
      _currentUser = AuthService.currentUser;
      
      // Load events
      final eventService = EventService();
      await eventService.initialize();
      _allEvents = eventService.events;
      
      // Generate invoices for participated events that don't have invoices yet
      if (_currentUser != null) {
        final newInvoices = InvoiceService.generateInvoicesForParticipatedEvents(_currentUser!, _allEvents);
        // Note: The invoices are automatically added to the InvoiceService
      }
      
      // Load user's invoices
      if (_currentUser != null) {
        _userInvoices = InvoiceService.getInvoicesForUser(_currentUser!.id);
      }
      
      hideLoading();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      hideLoading();
      showError('Failed to load purchase history: $e');
    }
  }

  List<InvoiceModel> get _filteredInvoices {
    List<InvoiceModel> filtered = [..._userInvoices];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((invoice) =>
        invoice.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        invoice.ticketId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        invoice.id.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply sorting
    switch (_sortOption) {
      case 'DateNewest':
        filtered.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
      case 'DateOldest':
        filtered.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
        break;
      case 'AmountHigh':
        filtered.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'AmountLow':
        filtered.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
      case 'EventNameAZ':
        filtered.sort((a, b) => a.eventName.toLowerCase().compareTo(b.eventName.toLowerCase()));
        break;
      case 'EventNameZA':
        filtered.sort((a, b) => b.eventName.toLowerCase().compareTo(a.eventName.toLowerCase()));
        break;
    }

    return filtered;
  }

  EventModel? _getEventForInvoice(InvoiceModel invoice) {
    return _allEvents.where((event) => event.id == invoice.eventId).firstOrNull;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredInvoices = _filteredInvoices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase History'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No purchases yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your ticket purchases will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search and Sort Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Search Bar
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search purchases...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Sort Dropdown
                          DropdownButton<String>(
                            value: _sortOption,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'DateNewest', child: Text('Date: Newest First')),
                              DropdownMenuItem(value: 'DateOldest', child: Text('Date: Oldest First')),
                              DropdownMenuItem(value: 'AmountHigh', child: Text('Amount: High to Low')),
                              DropdownMenuItem(value: 'AmountLow', child: Text('Amount: Low to High')),
                              DropdownMenuItem(value: 'EventNameAZ', child: Text('Event: A-Z')),
                              DropdownMenuItem(value: 'EventNameZA', child: Text('Event: Z-A')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _sortOption = value ?? 'DateNewest';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Purchase List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = filteredInvoices[index];
                            final event = _getEventForInvoice(invoice);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey[800] 
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(invoice.status).withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (event != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => InvoiceDetailsScreen(
                                          invoice: invoice,
                                          event: event,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(invoice.status).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              _getStatusIcon(invoice.status),
                                              color: _getStatusColor(invoice.status),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  invoice.eventName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _formatDateTime(invoice.purchaseDate),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '\$${invoice.formattedTotalAmount}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: _getStatusColor(invoice.status),
                                                ),
                                              ),
                                              Text(
                                                invoice.status.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _getStatusColor(invoice.status),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Ticket ID: ${invoice.ticketId}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Invoice ID: ${invoice.id}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 