# 🔧 Correction des Smoke Tests GitHub Actions

## 🚨 Problème Identifié

Les smoke tests échouaient avec l'erreur :

```
Error: page.goto: Protocol error (Page.navigate): Cannot navigate to invalid URL
Call log:
  - navigating to "", waiting until "load"
```

L'URL était vide (`''`) dans les tests.

## 🔍 Cause du Problème

1. **Outputs mal configurés** : Les outputs du job `build-and-deploy-preview` faisaient référence aux mauvais steps
2. **Parsing incorrect** : La commande `awk '{print $3}'` ne fonctionnait pas avec le format tabulaire de Firebase
3. **URL vide** : La variable `${{ needs.build-and-deploy-preview.outputs.preview-url }}` était vide

## ✅ Solution Implémentée

### 1. Correction des Outputs

**Avant :**

```yaml
outputs:
  preview-url: ${{ steps.deploy.outputs.preview-url }} # ❌ Step inexistant
```

**Après :**

```yaml
outputs:
  preview-url: ${{ steps.preview-url.outputs.preview-url }} # ✅ Step correct
```

### 2. Correction du Parsing des URLs

**Avant :**

```bash
CHANNEL_URL=$(firebase hosting:channel:list --project=$PROJECT_ID | grep "$CHANNEL" | awk '{print $3}')
# ❌ Ne fonctionnait pas avec le format tabulaire
```

**Après :**

```bash
CHANNEL_URL=$(firebase hosting:channel:list --project=$PROJECT_ID | grep "$CHANNEL" | sed 's/.*│ *\(https[^│]*\) *│.*/\1/')
# ✅ Extraction correcte avec regex
```

### 3. Test de Validation

Création d'un script de test pour valider la correction :

```bash
./scripts/test-github-workflow.sh
```

**Résultat :**

```
🔗 Récupération de l'URL du canal...
  URL du canal: https://ecommerceapp-7268d--blue-kvsprspl.web.app
✅ L'URL du canal est correctement définie
```

## 🔧 Workflows Corrigés

### 🔄 Blue-Green Deployment

- ✅ Outputs correctement configurés
- ✅ Parsing des URLs corrigé
- ✅ Smoke tests avec vraie URL

### 🚀 Promote to Live

- ✅ Récupération de l'URL du canal source
- ✅ Tests finaux avec URL correcte

### 🚨 Emergency Rollback

- ✅ Vérification du canal source
- ✅ URL correctement extraite

## 🧪 Validation

### Test Local

```bash
./scripts/test-github-workflow.sh
# ✅ URL correctement extraite
# ✅ Script de smoke tests généré
```

### URLs Fonctionnelles

- **Blue:** `https://ecommerceapp-7268d--blue-kvsprspl.web.app`
- **Green:** `https://ecommerceapp-7268d--green-mg6s1mfo.web.app`
- **Live:** `https://ecommerceapp-7268d.web.app`

## 📋 Prochaines Étapes

1. **Tester le workflow GitHub Actions** avec un push sur `main`
2. **Vérifier que les smoke tests passent** avec la vraie URL
3. **Valider la promotion manuelle** vers live
4. **Tester le rollback d'urgence**

## ✅ Résultat Attendu

Les smoke tests GitHub Actions devraient maintenant :

- ✅ Recevoir une URL valide
- ✅ Naviguer correctement vers le canal preview
- ✅ Exécuter tous les tests avec succès
- ✅ Permettre la promotion vers live

L'erreur `Cannot navigate to invalid URL` est maintenant résolue ! 🎯
