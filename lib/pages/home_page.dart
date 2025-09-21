import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback? onNavigateToCatalog;
  final Function(String)? onNavigateToCatalogWithCategory;
  final VoidCallback? onNavigateToCart;

  const MyHomePage({
    super.key,
    this.onNavigateToCatalog,
    this.onNavigateToCatalogWithCategory,
    this.onNavigateToCart,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> categories = [];
  bool isLoadingCategories = true;
  String? categoriesError;

  List<Product> featuredProducts = [];
  bool isLoadingProducts = true;
  String? productsError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFeaturedProducts();
  }

  Future<void> _loadCategories() async {
    try {
      print('🏠 Loading categories from home page...');
      setState(() {
        isLoadingCategories = true;
        categoriesError = null;
      });

      final categoriesData = await ApiService.getCategories();
      print('🏠 Categories loaded: ${categoriesData.length} categories');

      setState(() {
        categories = categoriesData;
        isLoadingCategories = false;
      });
      print('🏠 Categories state updated successfully');
    } catch (e, stackTrace) {
      print('💥 Error loading categories: $e');
      print('💥 Stack trace: $stackTrace');
      setState(() {
        categoriesError = e.toString();
        isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      setState(() {
        isLoadingProducts = true;
        productsError = null;
      });

      final productsData = await ApiService.getProducts();
      setState(() {
        featuredProducts = productsData.take(6).toList();
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        productsError = e.toString();
        isLoadingProducts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'E-Commerce',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _navigateToCart();
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildCategoriesSection(),
            _buildFeaturedProducts(),
            _buildStatsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withValues(alpha: 0.8),
            Colors.purple.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue dans notre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            const Text(
              'Boutique en ligne',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Découvrez nos produits exclusifs\net profitez de nos offres spéciales',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _navigateToCatalog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Découvrir maintenant',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Catégories',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(height: 120, child: _buildCategoriesList({})),
      ],
    );
  }

  Widget _buildCategoriesList(
    Map<String, Map<String, dynamic>> categoryMapping,
  ) {
    if (isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (categoriesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Réessayer', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    }

    final categoriesToShow = categories.isEmpty
        ? _getDefaultCategories()
        : categories;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categoriesToShow.length,
      itemBuilder: (context, index) {
        final category = categoriesToShow[index];
        final mapping = _getCategoryMapping(category);

        return GestureDetector(
          onTap: () {
            _navigateToCatalogWithCategory(category);
          },
          child: Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mapping['color'].withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mapping['icon'],
                    color: mapping['color'],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCategoryName(category),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _getDefaultCategories() {
    return [
      'electronics',
      'jewelery',
      "men's clothing",
      "women's clothing",
      'furniture',
      'groceries',
    ];
  }

  Map<String, dynamic> _getCategoryMapping(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return {'icon': Icons.devices, 'color': Colors.blue};
      case 'jewelery':
        return {'icon': Icons.diamond, 'color': Colors.amber};
      case "men's clothing":
        return {'icon': Icons.man, 'color': Colors.purple};
      case "women's clothing":
        return {'icon': Icons.woman, 'color': Colors.pink};
      case 'furniture':
        return {'icon': Icons.chair, 'color': Colors.brown};
      case 'groceries':
        return {'icon': Icons.shopping_basket, 'color': Colors.green};
      case 'beauty':
        return {'icon': Icons.face, 'color': Colors.pinkAccent};
      case 'fragrances':
        return {'icon': Icons.local_florist, 'color': Colors.purpleAccent};
      case 'automotive':
        return {'icon': Icons.directions_car, 'color': Colors.orange};
      case 'motorcycle':
        return {'icon': Icons.motorcycle, 'color': Colors.red};
      case 'lighting':
        return {'icon': Icons.lightbulb, 'color': Colors.yellow};
      case 'home-decoration':
        return {'icon': Icons.home, 'color': Colors.teal};
      case 'skincare':
        return {
          'icon': Icons.face_retouching_natural,
          'color': Colors.lightGreen,
        };
      case 'tops':
        return {'icon': Icons.checkroom, 'color': Colors.indigo};
      case 'womens-dresses':
        return {'icon': Icons.checkroom, 'color': Colors.pink};
      case 'womens-shoes':
        return {'icon': Icons.shopping_bag, 'color': Colors.purple};
      case 'mens-shirts':
        return {'icon': Icons.checkroom, 'color': Colors.blue};
      case 'mens-shoes':
        return {'icon': Icons.shopping_bag, 'color': Colors.brown};
      case 'mens-watches':
        return {'icon': Icons.watch, 'color': Colors.grey};
      case 'womens-watches':
        return {'icon': Icons.watch, 'color': Colors.pink};
      case 'womens-bags':
        return {'icon': Icons.shopping_bag, 'color': Colors.purple};
      case 'womens-jewellery':
        return {'icon': Icons.diamond, 'color': Colors.amber};
      case 'sunglasses':
        return {'icon': Icons.visibility, 'color': Colors.blueGrey};
      case 'laptops':
        return {'icon': Icons.laptop, 'color': Colors.blue};
      case 'smartphones':
        return {'icon': Icons.phone_android, 'color': Colors.blue};
      default:
        return {'icon': Icons.category, 'color': Colors.grey};
    }
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'electronics':
        return 'Électronique';
      case 'jewelery':
        return 'Bijoux';
      case "men's clothing":
        return 'Homme';
      case "women's clothing":
        return 'Femme';
      default:
        return category.toUpperCase();
    }
  }

  void _navigateToCatalog() {
    widget.onNavigateToCatalog?.call();
  }

  void _navigateToCatalogWithCategory(String category) {
    widget.onNavigateToCatalogWithCategory?.call(category);
  }

  void _navigateToCart() {
    widget.onNavigateToCart?.call();
  }

  Widget _buildProductsList() {
    if (isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (productsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Erreur de chargement',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadFeaturedProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(80, 32),
              ),
              child: const Text('Réessayer', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: featuredProducts.length,
      itemBuilder: (context, index) {
        final product = featuredProducts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product',
              arguments: {'productId': product.id},
            );
          },
          child: Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade900,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.rate.toString(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produits populaires',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _navigateToCatalog(),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 200, child: _buildProductsList()),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('10K+', 'Produits', Icons.inventory),
          _buildStatItem('5K+', 'Clients', Icons.people),
          _buildStatItem('99%', 'Satisfaction', Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
