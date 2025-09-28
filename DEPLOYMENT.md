# Stratégie de Déploiement Blue-Green

Ce document décrit la stratégie de déploiement Blue-Green implémentée pour l'application Flutter Ecommerce avec Firebase Hosting et GitHub Actions.

## 🎯 Vue d'ensemble

La stratégie Blue-Green utilise deux canaux Firebase Hosting (`blue` et `green`) pour permettre des déploiements sans interruption de service et des rollbacks instantanés.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Canal Blue    │    │  Canal Green    │    │   Canal Live    │
│  (Preview)      │    │  (Preview)      │    │  (Production)   │
│                 │    │                 │    │                 │
│ blue--app.web.app│    │green--app.web.app│    │   app.web.app   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │  GitHub Actions │
                    │   Workflows     │
                    └─────────────────┘
```

## 🚀 Workflows GitHub Actions

### 1. Blue-Green Deployment (`blue-green-deploy.yml`)

**Déclencheur:** Push sur `main` ou déclenchement manuel

**Étapes:**

1. **Tests** - Exécution des tests unitaires et d'intégration
2. **Build** - Construction de l'application Flutter
3. **Déploiement Preview** - Déploiement sur le canal inactif (blue ou green)
4. **Smoke Tests** - Tests automatisés sur le canal preview
5. **Promotion** - Promotion manuelle vers live (si demandée)

### 2. Promote to Live (`promote-to-live.yml`)

**Déclencheur:** Déclenchement manuel uniquement

**Étapes:**

1. **Validation** - Confirmation de la promotion
2. **Tests finaux** - Smoke tests sur le canal source
3. **Promotion** - Déploiement sur le canal live
4. **Vérification** - Tests de vérification post-déploiement

### 3. Emergency Rollback (`emergency-rollback.yml`)

**Déclencheur:** Déclenchement manuel en cas d'urgence

**Étapes:**

1. **Validation d'urgence** - Confirmation de sécurité
2. **Vérification source** - Vérification de la disponibilité du canal source
3. **Rollback** - Déploiement immédiat sur live
4. **Tests post-rollback** - Vérification du bon fonctionnement

## 🔧 Configuration

### Prérequis

1. **Firebase CLI installé:**

   ```bash
   npm install -g firebase-tools
   ```

2. **Connexion Firebase:**

   ```bash
   firebase login
   ```

3. **Secrets GitHub Actions configurés:**
   - `FIREBASE_SERVICE_ACCOUNT_ECOMMERCEAPP_7268D`
   - `FIREBASE_TOKEN`

### Initialisation

Exécutez le script de configuration:

```bash
./scripts/setup-firebase-channels.sh
```

## 📋 Processus de Déploiement

### Déploiement Automatique

1. **Push sur main:**

   ```bash
   git push origin main
   ```

2. **GitHub Actions s'exécute automatiquement:**

   - Tests et validation
   - Build de l'application
   - Déploiement sur canal preview (blue ou green)
   - Smoke tests automatisés

3. **Promotion manuelle vers live:**
   - Aller dans GitHub Actions > "Promote to Live"
   - Sélectionner le canal source (blue ou green)
   - Taper "PROMOTE" pour confirmer

### Déploiement Manuel

1. **Déclencher manuellement:**
   - Aller dans GitHub Actions > "Blue-Green Deployment"
   - Cliquer sur "Run workflow"
   - Sélectionner le canal cible

## 🧪 Tests et Validation

### Smoke Tests Automatisés

Les smoke tests vérifient:

- ✅ Chargement de la page
- ✅ Navigation fonctionnelle
- ✅ Responsive design
- ✅ Performance (< 5s de chargement)
- ✅ Application Flutter chargée

### Tests Manuels

Avant promotion vers live:

1. Tester l'URL de preview
2. Vérifier les fonctionnalités critiques
3. Tester sur différents appareils
4. Vérifier les performances

## 🚨 Gestion des Incidents

### Rollback d'Urgence

En cas de problème en production:

1. **Déclencher le rollback:**

   - Aller dans GitHub Actions > "Emergency Rollback"
   - Sélectionner le canal de rollback (blue ou green)
   - Taper "EMERGENCY_ROLLBACK" pour confirmer

2. **Vérification:**
   - Le site live est automatiquement restauré
   - Tests post-rollback exécutés
   - Notification de l'équipe

### Investigation Post-Incident

1. Analyser les logs de déploiement
2. Identifier la cause racine
3. Corriger le problème
4. Tester en environnement de développement
5. Planifier le prochain déploiement

## 📊 Monitoring et Observabilité

### URLs de Monitoring

- **Live:** https://ecommerceapp-7268d.web.app
- **Blue Preview:** https://ecommerceapp-7268d--blue-kvsprspl.web.app
- **Green Preview:** https://ecommerceapp-7268d--green-mg6s1mfo.web.app

> **Note:** Les URLs des canaux preview changent à chaque déploiement. Utilisez `firebase hosting:channel:list` ou `./scripts/show-channel-urls.sh` pour obtenir les URLs actuelles.

### Métriques Clés

- Temps de déploiement
- Taux de succès des tests
- Temps de réponse de l'application
- Erreurs JavaScript

## 🔒 Sécurité

### Protection des Environnements

- **Production:** Requiert approbation manuelle
- **Secrets:** Stockés de manière sécurisée dans GitHub
- **Tokens:** Rotation régulière recommandée

### Bonnes Pratiques

1. **Jamais de déploiement direct sur live**
2. **Toujours tester sur preview d'abord**
3. **Valider les changements critiques**
4. **Maintenir un historique des déploiements**

## 📚 Ressources

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

## 🆘 Support

En cas de problème:

1. Vérifier les logs GitHub Actions
2. Consulter la documentation Firebase
3. Contacter l'équipe de développement
4. Utiliser le rollback d'urgence si nécessaire
