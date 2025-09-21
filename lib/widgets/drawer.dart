import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Déconnecté avec succès')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon App',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 10),
                if (user != null) ...[
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.email ?? 'Utilisateur connecté',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ] else
                  const Text(
                    'Non connecté',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => _go(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.pages),
            title: const Text('Second Page'),
            onTap: () => _go(context, '/second'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Third Page'),
            onTap: () => _go(context, '/third'),
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Colors.orange),
            title: const Text('Catalogue'),
            onTap: () => _go(context, '/catalog'),
          ),

          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return ListTile(
                leading: Stack(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.green),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
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
                title: const Text('Panier'),
                subtitle: cart.isEmpty
                    ? null
                    : Text(
                        '${cart.itemCount} articles - \$${cart.total.toStringAsFixed(2)}',
                      ),
                onTap: () => _go(context, '/cart'),
              );
            },
          ),

          const Divider(),

          if (user == null) ...[
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Se connecter'),
              onTap: () => _go(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('S\'inscrire'),
              onTap: () => _go(context, '/register'),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter'),
              onTap: () => _signOut(context),
            ),
          ],
        ],
      ),
    );
  }
}
