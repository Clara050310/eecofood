import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/local_storage_service.dart';
import 'tela_carrinho.dart';
import 'tela_acompanhar_pedido.dart';

// CORES DO PROTÓTIPO
const Color _primaryColor = Color(0xFFC0392B); // Vermelho
const Color _secondaryColor = Color(0xFF808080); // Cinza
const Color _backgroundColor = Color(0xFFF5F5F5);

class TelaProdutosCliente extends StatefulWidget {
  @override
  _TelaProdutosClienteState createState() => _TelaProdutosClienteState();
}

class _TelaProdutosClienteState extends State<TelaProdutosCliente> {
  final LocalStorageService _localStorage = LocalStorageService();
  final TextEditingController _searchController = TextEditingController();

  // Caminhos reais das imagens dentro de assets/images/
  static const String _fuginiImage = 'assets/images/image_f1578e.png';
  static const String _basilarImage = 'assets/images/image_f0f95e.png';

  List<Product> products = [
    Product(
      id: '1',
      name: 'Molho Tomate Fugini 300g Sachê Tradicional',
      price: 1.39,
      originalPrice: 2.25,
      imageUrl: _fuginiImage,
      validity: '2023-12-15',
    ),
    Product(
      id: '2',
      name: 'Macarrão Semolado Basilar Parafuso 500g',
      price: 3.55,
      originalPrice: 3.55,
      imageUrl: _basilarImage,
      validity: '2023-12-10',
    ),
    Product(
      id: '3',
      name: 'Molho Tomate Fugini 300g Sachê Tradicional',
      price: 1.39,
      originalPrice: 2.25,
      imageUrl: _fuginiImage,
      validity: '2023-12-20',
    ),
    Product(
      id: '4',
      name: 'Macarrão Semolado Basilar Parafuso 500g',
      price: 3.55,
      originalPrice: 3.55,
      imageUrl: _basilarImage,
      validity: '2023-12-12',
    ),
    Product(
      id: '5',
      name: 'Molho Tomate Fugini 300g Sachê Tradicional',
      price: 1.39,
      originalPrice: 2.25,
      imageUrl: _fuginiImage,
      validity: '2023-12-15',
    ),
    Product(
      id: '6',
      name: 'Macarrão Semolado Basilar Parafuso 500g',
      price: 3.55,
      originalPrice: 3.55,
      imageUrl: _basilarImage,
      validity: '2023-12-10',
    ),
  ];

  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    filteredProducts = List.from(products);
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) => product.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addToCart(Product product) async {
    List<CartItem> cart = await _localStorage.getCart();
    CartItem? existingItem = cart.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product),
    );

    if (cart.any((item) => item.product.id == product.id)) {
      existingItem.quantity++;
    } else {
      cart.add(CartItem(product: product));
    }

    await _localStorage.saveCart(cart);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final bool hasDiscount =
        product.originalPrice != null && product.price < product.originalPrice!;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- IMAGEM DO PRODUTO ----------
          Container(
            height: 120,
            child: Stack(
              children: [
                Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),

                if (hasDiscount)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: _primaryColor,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                      ),
                      child: const Text(
                        '-%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),

          // ---------- INFORMAÇÕES ----------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 5),

                  if (hasDiscount)
                    Text(
                      'R\$ ${product.originalPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),

                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: hasDiscount ? _primaryColor : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () => _addToCart(product),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Comprar',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: _primaryColor),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Carrinho'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TelaCarrinho()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Acompanhar Pedido'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TelaAcompanharPedido(pedidoId: '')),
                );
              },
            ),
          ],
        ),
      ),

      // Barra de Pesquisa
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Procurar Item...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(left: 10, bottom: 10),
            ),
          ),
        ),
      ),

      body: filteredProducts.isEmpty
          ? Center(child: Text('Nenhum produto encontrado'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.60,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) => _buildProductCard(filteredProducts[index]),
            ),

      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TelaCarrinho()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Carrinho'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TelaAcompanharPedido(pedidoId: '')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Pedidos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
