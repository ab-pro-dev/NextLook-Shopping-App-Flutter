class OrderSummary {
  final String id;
  final String orderNumber;
  final String status;
  final int total;
  final int itemCount;
  final String? thumbnailUrl;
  final DateTime createdAt;

  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.itemCount,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      total: (json['total'] as num).toInt(),
      itemCount: (json['itemCount'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String productThumbnailUrl;
  final String colorName;
  final String sizeLabel;
  final int quantity;
  final int unitPrice;
  final int lineTotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productThumbnailUrl,
    required this.colorName,
    required this.sizeLabel,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productThumbnailUrl: json['productThumbnailUrl'] as String? ?? '',
      colorName: json['colorName'] as String,
      sizeLabel: json['sizeLabel'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toInt(),
      lineTotal: (json['lineTotal'] as num).toInt(),
    );
  }
}

class OrderStatusHistory {
  final String id;
  final String orderId;
  final String status;
  final DateTime createdAt;

  OrderStatusHistory({
    required this.id,
    required this.orderId,
    required this.status,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OrderDetail {
  final String id;
  final String userId;
  final String orderNumber;
  final String status;
  final int subtotal;
  final int shippingCost;
  final int tax;
  final int total;
  final String deliveryMethodLabel;
  final String paymentMethod;
  final String shippingFullName;
  final String shippingPhone;
  final String shippingAddressLine1;
  final String? shippingAddressLine2;
  final String shippingCity;
  final String shippingRegion;
  final String shippingCountry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;

  OrderDetail({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.deliveryMethodLabel,
    required this.paymentMethod,
    required this.shippingFullName,
    required this.shippingPhone,
    required this.shippingAddressLine1,
    this.shippingAddressLine2,
    required this.shippingCity,
    required this.shippingRegion,
    required this.shippingCountry,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.statusHistory,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawHistory = json['statusHistory'] as List<dynamic>? ?? [];

    return OrderDetail(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      subtotal: (json['subtotal'] as num).toInt(),
      shippingCost: (json['shippingCost'] as num).toInt(),
      tax: (json['tax'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      deliveryMethodLabel: json['deliveryMethodLabel'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      shippingFullName: json['shippingFullName'] as String? ?? '',
      shippingPhone: json['shippingPhone'] as String? ?? '',
      shippingAddressLine1: json['shippingAddressLine1'] as String? ?? '',
      shippingAddressLine2: json['shippingAddressLine2'] as String?,
      shippingCity: json['shippingCity'] as String? ?? '',
      shippingRegion: json['shippingRegion'] as String? ?? '',
      shippingCountry: json['shippingCountry'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['createdAt'] as String),
      items: rawItems.map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList(),
      statusHistory: rawHistory.map((h) => OrderStatusHistory.fromJson(h as Map<String, dynamic>)).toList(),
    );
  }
}

// Backward compatibility alias
typedef OrderModel = OrderDetail;
typedef OrderItemModel = OrderItem;
typedef OrderStatusHistoryModel = OrderStatusHistory;
