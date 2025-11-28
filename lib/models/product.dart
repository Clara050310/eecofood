class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String validity;
  // ⭐️ CORREÇÃO 1: Adicione esta propriedade aqui!
  final double? originalPrice;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.validity,
    // ⭐️ CORREÇÃO 2: Adicione ao construtor
    this.originalPrice, 
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'validity': validity,
      // ⭐️ CORREÇÃO 3: Adicione ao toJson (se o preço original for nulo, ele não salva)
      'originalPrice': originalPrice, 
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      validity: json['validity'] as String,
      // ⭐️ CORREÇÃO 4: Recupere o valor do JSON. Use '?' para aceitar nulo.
      originalPrice: json['originalPrice'] != null 
          ? (json['originalPrice'] as num).toDouble() 
          : null,
    );
  }
}