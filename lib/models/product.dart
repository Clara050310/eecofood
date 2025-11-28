class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl; // Placeholder for image
  final String validity; // Date string, e.g., '2023-12-31'

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.validity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'validity': validity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      validity: json['validity'],
    );
  }
}
