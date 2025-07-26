import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/invoice_model.dart';
import '../services/invoice_service.dart';
import '../services/auth_service.dart';
import 'ticket_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TicketPurchaseScreen extends StatefulWidget {
  final EventModel event;
  final User user;

  const TicketPurchaseScreen({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  String _selectedTicketType = 'General Admission';
  int _quantity = 1;
  String _selectedPaymentMethod = 'credit_card';
  bool _isProcessing = false;
  bool _purchaseSuccessful = false;

  final List<String> _ticketTypes = [
    'General Admission',
    'VIP Pass',
    'Early Bird',
    'Student Discount',
  ];

  final Map<String, double> _ticketPrices = {
    'General Admission': 25.00,
    'VIP Pass': 75.00,
    'Early Bird': 20.00,
    'Student Discount': 15.00,
  };

  final List<String> _paymentMethods = [
    'credit_card',
    'paypal',
    'bank_transfer',
  ];

  final Map<String, String> _paymentMethodLabels = {
    'credit_card': 'Credit Card',
    'paypal': 'PayPal',
    'bank_transfer': 'Bank Transfer',
  };

  double get _unitPrice => _ticketPrices[_selectedTicketType] ?? 25.00;
  double get _totalAmount => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent going back if purchase was successful
        if (_purchaseSuccessful) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Buy Tickets - ${widget.event.name}'),
          backgroundColor: const Color(0xFF00B388),
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.event.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.formattedDate,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.formattedTime,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.event.location,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ticket Type Selection
              Text(
                'Ticket Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _ticketTypes.map((type) {
                      final price = _ticketPrices[type] ?? 25.00;
                      final isSelected = _selectedTicketType == type;
                      
                      return RadioListTile<String>(
                        title: Text(type),
                        subtitle: Text('\$${price.toStringAsFixed(2)}'),
                        value: type,
                        groupValue: _selectedTicketType,
                        onChanged: (value) {
                          setState(() {
                            _selectedTicketType = value!;
                          });
                        },
                        activeColor: const Color(0xFF00B388),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quantity Selection
              Text(
                'Quantity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Expanded(
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: _quantity < 10
                            ? () {
                                setState(() {
                                  _quantity++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Payment Method Selection
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _paymentMethods.map((method) {
                      final label = _paymentMethodLabels[method] ?? method;
                      final isSelected = _selectedPaymentMethod == method;
                      
                      return RadioListTile<String>(
                        title: Text(label),
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        activeColor: const Color(0xFF00B388),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Total Amount
              Card(
                color: const Color(0xFF00B388).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00B388),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Purchase Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _purchaseTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B388),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Purchase Ticket',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchaseTicket() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create invoice
      final invoice = InvoiceService.createInvoice(
        eventId: widget.event.id,
        eventName: widget.event.name,
        userId: widget.user.id,
        userName: '${widget.user.fname} ${widget.user.lname}',
        ticketType: _selectedTicketType,
        quantity: _quantity,
        unitPrice: _unitPrice,
        currency: 'USD',
        paymentMethod: _selectedPaymentMethod,
        paymentDetails: _getPaymentDetails(),
        billingAddress: _getBillingAddress(),
        eventDetails: _getEventDetails(),
        terms: _getTerms(),
      );

      // Update user's participated events
      final updatedUser = widget.user.copyWith(
        participatedEventIds: [...widget.user.participatedEventIds, widget.event.id],
      );
      await AuthService.updateCurrentUser(updatedUser);

      // Add activity log for ticket purchase
      await AuthService.addActivityLog(
        'Ticket Purchase',
        'Purchased ticket for ${widget.event.name} - Invoice: ${invoice.id}, Ticket: ${invoice.ticketId}',
      );

      // Save invoice to SharedPreferences
      await _saveInvoiceToSharedPreferences(invoice);

      if (mounted) {
        setState(() {
          _purchaseSuccessful = true;
        });
        print('TicketPurchaseScreen: Purchase successful, showing success dialog');
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Purchase Successful!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text('Your ticket has been purchased successfully!'),
                const SizedBox(height: 8),
                Text(
                  'Invoice ID: ${invoice.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ticket ID: ${invoice.ticketId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('TicketPurchaseScreen: Close button pressed, returning true');
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Return true to indicate successful purchase
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => TicketViewScreen(
                        invoice: invoice,
                        event: widget.event,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B388),
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Ticket'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error purchasing ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Map<String, dynamic> _getPaymentDetails() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
        return {
          'cardLast4': '1234',
          'cardType': 'Visa',
        };
      case 'paypal':
        return {
          'paypalEmail': '${widget.user.fname.toLowerCase()}.${widget.user.lname.toLowerCase()}@example.com',
        };
      case 'bank_transfer':
        return {
          'bankName': 'Chase Bank',
          'accountLast4': '5678',
        };
      default:
        return {};
    }
  }

  Map<String, dynamic> _getBillingAddress() {
    return {
      'name': '${widget.user.fname} ${widget.user.lname}',
      'email': '${widget.user.fname.toLowerCase()}.${widget.user.lname.toLowerCase()}@example.com',
      'phone': '+1-555-0123',
      'address': '123 Main Street',
      'city': 'New York',
      'state': 'NY',
      'zipCode': '10001',
      'country': 'USA',
    };
  }

  Map<String, dynamic> _getEventDetails() {
    return {
      'date': widget.event.date.toIso8601String(),
      'location': widget.event.location,
      'venue': widget.event.location.split(',')[0].trim(),
      'time': widget.event.formattedTime,
    };
  }

  Map<String, dynamic> _getTerms() {
    return {
      'refundPolicy': 'No refunds available for this event',
      'cancellationPolicy': 'Tickets are non-transferable and non-refundable',
      'termsOfService': 'By purchasing this ticket, you agree to all terms and conditions',
    };
  }

  Future<void> _saveInvoiceToSharedPreferences(InvoiceModel invoice) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invoicesKey = 'user_invoices_${widget.user.id}';
      
      // Get existing invoices
      final existingInvoicesJson = prefs.getString(invoicesKey);
      List<Map<String, dynamic>> invoices = [];
      
      if (existingInvoicesJson != null) {
        final List<dynamic> existingInvoices = jsonDecode(existingInvoicesJson);
        invoices = existingInvoices.cast<Map<String, dynamic>>();
      }
      
      // Add new invoice
      invoices.add(invoice.toJson());
      
      // Save back to SharedPreferences
      await prefs.setString(invoicesKey, jsonEncode(invoices));
    } catch (e) {
      print('Error saving invoice to SharedPreferences: $e');
    }
  }
} 