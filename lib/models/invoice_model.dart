class InvoiceModel {
  final String id;
  final String eventId;
  final String eventName;
  final String userId;
  final String userName;
  final String ticketId;
  final DateTime purchaseDate;
  final String ticketType;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String currency;
  final String status;
  final String paymentMethod;
  final Map<String, dynamic> paymentDetails;
  final Map<String, dynamic> billingAddress;
  final Map<String, dynamic> eventDetails;
  final Map<String, dynamic> terms;

  InvoiceModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.userId,
    required this.userName,
    required this.ticketId,
    required this.purchaseDate,
    required this.ticketType,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.paymentDetails,
    required this.billingAddress,
    required this.eventDetails,
    required this.terms,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      ticketId: json['ticketId'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      ticketType: json['ticketType'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String,
      paymentDetails: json['paymentDetails'] as Map<String, dynamic>,
      billingAddress: json['billingAddress'] as Map<String, dynamic>,
      eventDetails: json['eventDetails'] as Map<String, dynamic>,
      terms: json['terms'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventName': eventName,
      'userId': userId,
      'userName': userName,
      'ticketId': ticketId,
      'purchaseDate': purchaseDate.toIso8601String(),
      'ticketType': ticketType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentDetails': paymentDetails,
      'billingAddress': billingAddress,
      'eventDetails': eventDetails,
      'terms': terms,
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? eventId,
    String? eventName,
    String? userId,
    String? userName,
    String? ticketId,
    DateTime? purchaseDate,
    String? ticketType,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? currency,
    String? status,
    String? paymentMethod,
    Map<String, dynamic>? paymentDetails,
    Map<String, dynamic>? billingAddress,
    Map<String, dynamic>? eventDetails,
    Map<String, dynamic>? terms,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      ticketId: ticketId ?? this.ticketId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      ticketType: ticketType ?? this.ticketType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      billingAddress: billingAddress ?? this.billingAddress,
      eventDetails: eventDetails ?? this.eventDetails,
      terms: terms ?? this.terms,
    );
  }

  String get formattedPurchaseDate {
    return '${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}';
  }

  String get formattedTotalAmount {
    return '$currency ${totalAmount.toStringAsFixed(2)}';
  }

  String get formattedUnitPrice {
    return '$currency ${unitPrice.toStringAsFixed(2)}';
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
} 