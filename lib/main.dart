import 'package:flutter_ecommerce_app/pages/login_page.dart';
import 'package:flutter_ecommerce_app/pages/register_page.dart';
import 'package:flutter_ecommerce_app/pages/catalog_page.dart';
import 'package:flutter_ecommerce_app/pages/product_page.dart';
import 'package:flutter_ecommerce_app/pages/cart_page.dart';
import 'package:flutter_ecommerce_app/pages/checkout_page.dart';
import 'package:flutter_ecommerce_app/providers/cart_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const AuthWrapper(),
    ),
  );
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          });
          return const LoginPage();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final cartProvider = Provider.of<CartProvider>(
            context,
            listen: false,
          );
          cartProvider.initializeCart();
        });

        return const MyApp();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MainNavigationPage(),
      routes: {
        '/product': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final productId = args?['productId'] as int? ?? 1;
          return ProductPage(productId: productId);
        },
        '/cart': (_) => const CartPage(),
        '/checkout': (_) => const CheckoutPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
      },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  String? _selectedCategory;

  List<Widget> get _pages => [
    MyHomePage(
      onNavigateToCatalog: () => setIndex(1),
      onNavigateToCatalogWithCategory: (category) =>
          setIndexWithCategory(1, category),
      onNavigateToCart: () => setIndex(2),
    ),
    CatalogPage(initialCategory: _selectedCategory),
    const CartPage(),
    const ProfilePage(),
  ];

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
      _selectedCategory = null;
    });
  }

  void setIndexWithCategory(int index, String category) {
    setState(() {
      _currentIndex = index;
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1A1A1A),
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.white70,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Accueil',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'Catalogue',
              ),
              BottomNavigationBarItem(
                icon: _buildCartIconWithBadge(cart.itemCount),
                label: 'Panier',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartIconWithBadge(int itemCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart),
        if (itemCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFF1A1A1A), width: 2),
                ),
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                itemCount > 99 ? '99+' : itemCount.toString(),
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
    );
  }
}
