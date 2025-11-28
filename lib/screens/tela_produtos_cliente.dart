import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/local_storage_service.dart';
import 'tela_carrinho.dart';
import 'tela_acompanhar_pedido.dart';

class TelaProdutosCliente extends StatefulWidget {
  @override
  _TelaProdutosClienteState createState() => _TelaProdutosClienteState();
}

class _TelaProdutosClienteState extends State<TelaProdutosCliente> {
  final LocalStorageService _localStorage = LocalStorageService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> products = [
    Product(
      id: '1',
      name: 'Maçã',
      price: 2.50,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/415/415733.png',
      validity: '2023-12-15',
    ),
    Product(
      id: '2',
      name: 'Banana',
      price: 1.80,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/2909/2909765.png',
      validity: '2023-12-10',
    ),
    Product(
      id: '3',
      name: 'Laranja',
      price: 3.00,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
      validity: '2023-12-20',
    ),
    Product(
      id: '4',
      name: 'Tomate',
      price: 4.20,
      imageUrl: 'https://cdn-icons-png.flaticon.com/512/415/415760.png',
      validity: '2023-12-12',
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

  /// 🔍 FILTRO FUNCIONANDO
  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) => product.name.toLowerCase().contains(query))
          .toList();
    });
  }

  /// 🛒 Adicionar ao Carrinho
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
        content: Text('${product.name} adicionada ao carrinho'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  /// 📅 Converte a validade para DD/MM/AAAA
  String formatDate(String date) {
    DateTime d = DateTime.parse(date);
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ⭐ MENU LATERAL FUNCIONANDO
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TelaCarrinho()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Acompanhar Pedido'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TelaAcompanharPedido(pedidoId: '', status: '',)));
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,

        // 🔥 BARRA DE PESQUISA MELHORADA
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Procurar produto…',
              hintStyle: TextStyle(color: Colors.black54),
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.black87),
            ),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),

      body: filteredProducts.isEmpty
          ? Center(
              child: Text(
                'Nenhum produto encontrado',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      // 📝 INFORMAÇÕES
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Validade: ${formatDate(product.validity)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade700),
                            ),
                            Text(
                              'R\$ ${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            ElevatedButton.icon(
                              onPressed: () => _addToCart(product),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Adicionar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
