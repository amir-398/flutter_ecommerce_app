# Scripts de Déploiement Blue-Green

Ce dossier contient les scripts utilitaires pour la stratégie de déploiement Blue-Green.

## 📁 Fichiers

### `config.sh`

Configuration centralisée pour tous les scripts.

- Variables d'environnement
- Fonctions utilitaires
- Vérification des prérequis

### `setup-firebase-channels.sh`

Script d'initialisation des canaux Firebase Hosting.

```bash
./scripts/setup-firebase-channels.sh
```

### `smoke-tests.js`

Script de smoke tests automatisés avec Playwright.

```bash
node scripts/smoke-tests.js <URL>
```

### `check-deployment-status.sh`

Script de vérification du statut des déploiements.

```bash
./scripts/check-deployment-status.sh
```

## 🚀 Utilisation

### Initialisation (première fois)

```bash
# 1. Configurer les canaux Firebase
./scripts/setup-firebase-channels.sh

# 2. Vérifier le statut
./scripts/check-deployment-status.sh
```

### Tests manuels

```bash
# Tests sur le canal blue
node scripts/smoke-tests.js https://blue--ecommerceapp-7268d.web.app

# Tests sur le canal green
node scripts/smoke-tests.js https://green--ecommerceapp-7268d.web.app

# Tests sur live
node scripts/smoke-tests.js https://ecommerceapp-7268d.web.app
```

### Monitoring

```bash
# Vérifier le statut de tous les canaux
./scripts/check-deployment-status.sh
```

## 🔧 Prérequis

- Firebase CLI (`npm install -g firebase-tools`)
- Flutter SDK
- Node.js (pour les tests)
- Playwright (`npm install -D @playwright/test`)

## 📋 Configuration GitHub Actions

Assurez-vous que ces secrets sont configurés dans GitHub:

- `FIREBASE_SERVICE_ACCOUNT_ECOMMERCEAPP_7268D`
- `FIREBASE_TOKEN`

## 🆘 Dépannage

### Erreur de connexion Firebase

```bash
firebase login
firebase use ecommerceapp-7268d
```

### Erreur de permissions

Vérifiez que votre compte a les permissions nécessaires sur le projet Firebase.

### Tests qui échouent

1. Vérifiez que l'URL est accessible
2. Vérifiez que Playwright est installé
3. Vérifiez les logs détaillés
