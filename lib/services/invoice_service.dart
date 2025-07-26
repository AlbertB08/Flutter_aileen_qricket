import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/invoice_model.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';

class InvoiceService {
  static List<InvoiceModel> _invoices = [];
  static bool _initialized = false;

  /// Initialize the invoice service by loading data
  static Future<void> initialize({bool force = false}) async {
    if (_initialized && !force) return;

    try {
      final String response = await rootBundle.loadString('assets/data/invoices.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> invoicesJson = data['invoices'] as List<dynamic>;
      
      _invoices = invoicesJson
          .map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _initialized = true;
    } catch (e) {
      print('Error loading invoices: $e');
      _invoices = [];
    }
  }

  /// Get all invoices
  static List<InvoiceModel> get invoices => List.unmodifiable(_invoices);

  /// Get invoices for a specific user
  static List<InvoiceModel> getInvoicesForUser(String userId) {
    return _invoices.where((invoice) => invoice.userId == userId).toList();
  }

  /// Generate invoices for existing participated events that don't have invoices
  static List<InvoiceModel> generateInvoicesForParticipatedEvents(User user, List<EventModel> events) {
    final List<InvoiceModel> newInvoices = [];
    final existingInvoiceEventIds = getInvoicesForUser(user.id).map((inv) => inv.eventId).toSet();
    
    for (final eventId in user.participatedEventIds) {
      // Skip if invoice already exists for this event
      if (existingInvoiceEventIds.contains(eventId)) continue;
      
      // Find the event details
      final event = events.where((e) => e.id == eventId).firstOrNull;
      if (event == null) continue;
      
      // Generate invoice for this participated event
      final invoice = createInvoice(
        eventId: event.id,
        eventName: event.name,
        userId: user.id,
        userName: '${user.fname} ${user.lname}',
        ticketType: 'General Admission',
        quantity: 1,
        unitPrice: 25.00,
        currency: 'USD',
        paymentMethod: 'credit_card',
        paymentDetails: {
          'cardLast4': '1234',
          'cardType': 'Visa',
        },
        billingAddress: {
          'name': '${user.fname} ${user.lname}',
          'email': '${user.fname.toLowerCase()}.${user.lname.toLowerCase()}@example.com',
          'phone': '+1-555-0123',
          'address': '123 Main Street',
          'city': 'New York',
          'state': 'NY',
          'zipCode': '10001',
          'country': 'USA',
        },
        eventDetails: {
          'date': event.date.toIso8601String(),
          'location': event.location,
          'venue': event.location.split(',')[0].trim(),
          'time': '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}',
        },
        terms: {
          'refundPolicy': 'No refunds available for this event',
          'cancellationPolicy': 'Tickets are non-transferable and non-refundable',
          'termsOfService': 'By purchasing this ticket, you agree to all terms and conditions',
        },
      );
      
      newInvoices.add(invoice);
    }
    
    return newInvoices;
  }

  /// Get invoices for a specific event
  static List<InvoiceModel> getInvoicesForEvent(String eventId) {
    return _invoices.where((invoice) => invoice.eventId == eventId).toList();
  }

  /// Get a specific invoice by ID
  static InvoiceModel? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create a new invoice
  static InvoiceModel createInvoice({
    required String eventId,
    required String eventName,
    required String userId,
    required String userName,
    required String ticketType,
    required int quantity,
    required double unitPrice,
    required String currency,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
    required Map<String, dynamic> billingAddress,
    required Map<String, dynamic> eventDetails,
    required Map<String, dynamic> terms,
  }) {
    final String invoiceId = 'INV-${DateTime.now().year}-${_invoices.length + 1}';
    final String ticketId = 'TKT-${DateTime.now().year}-${_invoices.length + 1}';
    final double totalAmount = unitPrice * quantity;

    final invoice = InvoiceModel(
      id: invoiceId,
      eventId: eventId,
      eventName: eventName,
      userId: userId,
      userName: userName,
      ticketId: ticketId,
      purchaseDate: DateTime.now(),
      ticketType: ticketType,
      quantity: quantity,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      currency: currency,
      status: 'paid',
      paymentMethod: paymentMethod,
      paymentDetails: paymentDetails,
      billingAddress: billingAddress,
      eventDetails: eventDetails,
      terms: terms,
    );

    _invoices.add(invoice);
    return invoice;
  }

  /// Update invoice status
  static bool updateInvoiceStatus(String invoiceId, String newStatus) {
    final index = _invoices.indexWhere((invoice) => invoice.id == invoiceId);
    if (index != -1) {
      _invoices[index] = _invoices[index].copyWith(status: newStatus);
      return true;
    }
    return false;
  }

  /// Cancel an invoice
  static bool cancelInvoice(String invoiceId) {
    return updateInvoiceStatus(invoiceId, 'cancelled');
  }

  /// Get invoice statistics
  static Map<String, dynamic> getInvoiceStatistics() {
    final totalInvoices = _invoices.length;
    final paidInvoices = _invoices.where((i) => i.isPaid).length;
    final pendingInvoices = _invoices.where((i) => i.isPending).length;
    final cancelledInvoices = _invoices.where((i) => i.isCancelled).length;
    final totalRevenue = _invoices
        .where((i) => i.isPaid)
        .fold(0.0, (sum, invoice) => sum + invoice.totalAmount);

    return {
      'totalInvoices': totalInvoices,
      'paidInvoices': paidInvoices,
      'pendingInvoices': pendingInvoices,
      'cancelledInvoices': cancelledInvoices,
      'totalRevenue': totalRevenue,
    };
  }

  /// Generate a unique invoice ID
  static String generateInvoiceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'INV-$timestamp';
  }

  /// Generate a unique ticket ID
  static String generateTicketId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'TKT-$timestamp';
  }
} 