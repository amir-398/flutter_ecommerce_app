#!/bin/bash

# Configuration pour les scripts de déploiement Blue-Green

# Firebase Configuration
export FIREBASE_PROJECT_ID="ecommerceapp-7268d"
export FIREBASE_PROJECT_NAME="Flutter Ecommerce App"

# URLs des canaux
export LIVE_URL="https://ecommerceapp-7268d.web.app"
export BLUE_PREVIEW_URL="https://ecommerceapp-7268d--blue-kvsprspl.web.app"
export GREEN_PREVIEW_URL="https://ecommerceapp-7268d--green-mg6s1mfo.web.app"

# Configuration des tests
export ENABLE_SMOKE_TESTS=true
export PERFORMANCE_THRESHOLD=5000  # 5 secondes en millisecondes
export RESPONSE_TIME_THRESHOLD=3000  # 3 secondes en millisecondes

# Configuration des notifications
export NOTIFICATION_WEBHOOK_URL=""  # Optionnel: URL pour les notifications Slack/Discord

# Couleurs pour les logs
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérifier les prérequis
check_prerequisites() {
    log_info "Vérification des prérequis..."
    
    # Vérifier Firebase CLI
    if ! command -v firebase &> /dev/null; then
        log_error "Firebase CLI n'est pas installé"
        log_info "Installez-le avec: npm install -g firebase-tools"
        return 1
    fi
    
    # Vérifier Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter n'est pas installé"
        log_info "Installez Flutter depuis: https://flutter.dev/docs/get-started/install"
        return 1
    fi
    
    # Vérifier Node.js (pour les tests)
    if ! command -v node &> /dev/null; then
        log_warning "Node.js n'est pas installé (requis pour les smoke tests)"
    fi
    
    log_success "Prérequis vérifiés"
    return 0
}

# Obtenir le canal actuellement actif
get_active_channel() {
    # Cette fonction devrait interroger Firebase pour déterminer le canal actif
    # Pour l'instant, on retourne une valeur par défaut
    echo "blue"
}

# Obtenir le canal inactif
get_inactive_channel() {
    local active=$(get_active_channel)
    if [ "$active" = "blue" ]; then
        echo "green"
    else
        echo "blue"
    fi
}

# Vérifier la connectivité
check_connectivity() {
    log_info "Vérification de la connectivité..."
    
    local urls=("$LIVE_URL" "$BLUE_PREVIEW_URL" "$GREEN_PREVIEW_URL")
    local all_ok=true
    
    for url in "${urls[@]}"; do
        if curl -f -s -o /dev/null "$url"; then
            log_success "Accessible: $url"
        else
            log_error "Inaccessible: $url"
            all_ok=false
        fi
    done
    
    if [ "$all_ok" = true ]; then
        log_success "Tous les canaux sont accessibles"
        return 0
    else
        log_error "Certains canaux ne sont pas accessibles"
        return 1
    fi
}
