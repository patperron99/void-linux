#!/bin/sh

echo "🔍 Vérification du service xdg-desktop-portal..."

# Test 1 : le service est-il enregistré ?
if ! gdbus introspect --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop > /dev/null 2>&1; then
  echo "❌ Le service xdg-desktop-portal n'est pas actif sur le bus D-Bus utilisateur."
  echo "   → Vérifie que xdg-desktop-portal et xdg-desktop-portal-wlr tournent bien."
  exit 1
fi

echo "✅ Service xdg-desktop-portal détecté."

# Test 2 : interfaces exposées
echo "📋 Interfaces disponibles sur /org/freedesktop/portal/desktop :"
gdbus introspect --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop | grep interface

echo ""
echo "💡 Si 'org.freedesktop.portal.FileChooser' ou 'OpenURI' n'apparaissent pas,"
echo "   le backend (wlr, gtk, etc.) n'est probablement pas chargé correctement."
