# 🛒 Flutter Ecommerce App

Une application e-commerce moderne développée avec Flutter, intégrant une stratégie de déploiement Blue-Green avec Firebase Hosting et GitHub Actions.

## 🚀 Fonctionnalités

- **🛍️ Catalogue de produits** avec recherche et filtres
- **🛒 Panier d'achat** avec gestion des quantités
- **👤 Authentification utilisateur** (Firebase Auth)
- **📱 Interface responsive** pour mobile et desktop
- **☁️ Stockage cloud** (Firebase Firestore)
- **🔄 Déploiement Blue-Green** automatisé

## 🏗️ Architecture

### Frontend

- **Flutter** - Framework de développement cross-platform
- **Provider** - Gestion d'état
- **Material Design** - Interface utilisateur moderne

### Backend & Services

- **Firebase Auth** - Authentification utilisateur
- **Cloud Firestore** - Base de données NoSQL
- **Firebase Storage** - Stockage de fichiers
- **Firebase Hosting** - Hébergement web

### DevOps & CI/CD

- **GitHub Actions** - Automatisation CI/CD
- **Blue-Green Deployment** - Déploiement sans interruption
- **Firebase Hosting Channels** - Canaux de prévisualisation
- **Smoke Tests** - Tests automatisés

## 📁 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── models/                   # Modèles de données
│   ├── cart.dart
│   ├── order.dart
│   └── product.dart
├── pages/                    # Pages de l'application
│   ├── home_page.dart
│   ├── catalog_page.dart
│   ├── cart_page.dart
│   ├── checkout_page.dart
│   ├── orders_page.dart
│   ├── profile_page.dart
│   ├── login_page.dart
│   └── register_page.dart
├── providers/                # Gestion d'état
│   └── cart_provider.dart
├── services/                 # Services et API
│   ├── api_service.dart
│   ├── cart_service.dart
│   ├── order_service.dart
│   ├── firestore_cart_service.dart
│   └── firestore_order_service.dart
└── widgets/                  # Composants réutilisables
    ├── product_card.dart
    ├── cart_item.dart
    └── order_summary.dart

.github/workflows/            # GitHub Actions
├── blue-green-deploy.yml     # Déploiement Blue-Green
├── promote-to-live.yml       # Promotion vers production
├── emergency-rollback.yml    # Rollback d'urgence
└── test.yml                  # Tests automatisés

scripts/                      # Scripts utilitaires
├── setup-firebase-channels.sh
├── show-channel-urls.sh
├── test-channels.sh
└── test-github-workflow.sh
```

## 🚀 Démarrage Rapide

### Prérequis

- **Flutter SDK** (version 3.9.0 ou supérieure)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Git** et **GitHub** account
- **Node.js** (pour les tests automatisés)

### Installation

1. **Cloner le repository**

   ```bash
   git clone https://github.com/votre-username/flutter_ecommerce_app.git
   cd flutter_ecommerce_app
   ```

2. **Installer les dépendances Flutter**

   ```bash
   flutter pub get
   ```

3. **Configurer Firebase**

   ```bash
   firebase login
   firebase use ecommerceapp-7268d
   ```

4. **Générer les mocks pour les tests**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Configuration

1. **Variables d'environnement**

   - Copiez `firebase_options.dart` (déjà configuré)
   - Vérifiez la configuration Firebase dans `lib/firebase_options.dart`

2. **Secrets GitHub Actions**
   - `FIREBASE_SERVICE_ACCOUNT_ECOMMERCEAPP_7268D`
   - `FIREBASE_TOKEN`

## 🧪 Tests

### Tests Unitaires

```bash
flutter test
```

### Tests d'Intégration

```bash
flutter test integration_test/
```

### Tests de Performance

```bash
flutter test test/load/load_test.dart
```

### Smoke Tests (Local)

```bash
./scripts/test-channels.sh
```

## 🚀 Déploiement

### Stratégie Blue-Green

Cette application utilise une stratégie de déploiement Blue-Green pour assurer des déploiements sans interruption de service.

#### Canaux de Déploiement

- **🔴 Live** - Production (`https://ecommerceapp-7268d.web.app`)
- **🔵 Blue** - Preview (`https://ecommerceapp-7268d--blue-xxx.web.app`)
- **🟢 Green** - Preview (`https://ecommerceapp-7268d--green-xxx.web.app`)

#### Processus de Déploiement

1. **Déploiement Automatique**

   ```bash
   git push origin main
   # → Déploiement automatique sur canal preview
   # → Smoke tests automatisés
   ```

2. **Promotion Manuelle vers Live**

   - Aller dans **GitHub Actions** → **"Promote to Live"**
   - Sélectionner le canal source (blue/green)
   - Taper **"PROMOTE"** pour confirmer

3. **Rollback d'Urgence**
   - Aller dans **GitHub Actions** → **"Emergency Rollback"**
   - Sélectionner le canal de rollback
   - Taper **"EMERGENCY_ROLLBACK"** pour confirmer

### Scripts Utilitaires

```bash
# Voir les URLs des canaux
./scripts/show-channel-urls.sh

# Tester tous les canaux
./scripts/test-channels.sh

# Tester le workflow GitHub Actions
./scripts/test-github-workflow.sh

# Configurer les canaux Firebase
./scripts/setup-firebase-channels.sh
```

## 📊 Monitoring

### URLs de Monitoring

- **Live:** https://ecommerceapp-7268d.web.app
- **Blue Preview:** https://ecommerceapp-7268d--blue-xxx.web.app
- **Green Preview:** https://ecommerceapp-7268d--green-xxx.web.app

### Métriques Clés

- Temps de déploiement
- Taux de succès des tests
- Temps de réponse de l'application
- Erreurs JavaScript

## 🔧 Développement

### Commandes Utiles

```bash
# Lancer l'application en mode debug
flutter run

# Lancer l'application web
flutter run -d chrome

# Build pour production
flutter build web --release

# Analyser le code
dart analyze

# Formater le code
dart format .

# Nettoyer le projet
flutter clean
```

### Structure des Tests

```
test/
├── unit/                     # Tests unitaires
│   ├── models/
│   ├── providers/
│   └── services/
├── widget/                   # Tests de widgets
├── load/                     # Tests de performance
└── helpers/                  # Utilitaires de test
```

## 🛡️ Sécurité

- **Authentification Firebase** avec gestion des sessions
- **Règles Firestore** pour la sécurité des données
- **Validation côté client et serveur**
- **HTTPS** obligatoire en production
- **Secrets GitHub Actions** pour l'authentification

## 📚 Documentation

- [Documentation Flutter](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Stratégie Blue-Green](./DEPLOYMENT.md)

## 🤝 Contribution

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add some AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir** une Pull Request

### Guidelines de Contribution

- Suivre les conventions de code Dart/Flutter
- Ajouter des tests pour les nouvelles fonctionnalités
- Mettre à jour la documentation si nécessaire
- Respecter la stratégie Blue-Green pour les déploiements

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe

- **Développement:** [Votre Nom]
- **DevOps:** [Votre Nom]
- **Design:** [Votre Nom]

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/votre-username/flutter_ecommerce_app/issues)
- **Discussions:** [GitHub Discussions](https://github.com/votre-username/flutter_ecommerce_app/discussions)
- **Email:** votre.email@example.com

## 🎯 Roadmap

- [ ] **Paiement en ligne** (Stripe/PayPal)
- [ ] **Notifications push** (Firebase Cloud Messaging)
- [ ] **Mode hors ligne** (PWA)
- [ ] **Analytics avancés** (Firebase Analytics)
- [ ] **Tests E2E** (Playwright/Cypress)
- [ ] **Monitoring APM** (Sentry/DataDog)

---

<div align="center">

**🚀 Déployé avec ❤️ et Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)

</div>
