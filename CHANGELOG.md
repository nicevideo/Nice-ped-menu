# Changelog - Nice-Ped-Menu v2.0

## Version 2.0 - Fix des chemins hardcodés 🎉

### 🚀 Nouvelles fonctionnalités

- **Chemins dynamiques** : La ressource peut maintenant être placée n'importe où dans le dossier `resources/` avec n'importe quel nom
- **Support cross-platform** : Fonctionne maintenant sur Linux, macOS et Windows
- **Configuration flexible** : Nouveaux paramètres dans `config.lua` pour personnaliser les chemins

### 🐛 Corrections de bugs

- ✅ Suppression de tous les chemins hardcodés `resources/nice_ped/`
- ✅ Remplacement des commandes Windows `dir` par des alternatives cross-platform
- ✅ Utilisation de `GetCurrentResourceName()` pour détecter automatiquement le nom de la ressource
- ✅ Correction des bugs de génération des fichiers JavaScript

### 🔧 Améliorations techniques

- **Détection automatique du système** : Utilise `ls` sur Unix/Linux et `dir` sur Windows
- **Chemins relatifs** : Tous les chemins sont maintenant relatifs au nom de la ressource
- **Code plus maintenable** : Centralisation de la configuration des chemins
- **Meilleure gestion d'erreurs** : Amélioration de la robustesse du code

### 📁 Structure flexible

Avant (v1.x) :
```
resources/
└── nice_ped/          ← Nom obligatoire !
    ├── fxmanifest.lua
    └── ...
```

Maintenant (v2.0) :
```
resources/
├── mon-menu-ped/      ← N'importe quel nom !
│   ├── fxmanifest.lua
│   └── ...
├── scripts/
│   └── nice-ped-menu/ ← Même dans un sous-dossier !
│       ├── fxmanifest.lua
│       └── ...
└── ...
```

### 🎯 Migration

**Aucune action requise !** Cette version est rétrocompatible. Votre installation existante continuera de fonctionner.

### 📋 Configuration ajoutée

Nouvelles variables dans `config.lua` :
```lua
-- Dynamic paths configuration
Config.resourceName = GetCurrentResourceName()
Config.resourcePath = "resources/" .. Config.resourceName .. "/"

Config.paths = {
    fileXml = Config.resourcePath .. "file_xml/",
    listLua = Config.resourcePath .. "list_lua/",
    listPed = Config.resourcePath .. "list_ped/",
    listVarPed = Config.resourcePath .. "list_var_ped/",
    listVarPedJs = Config.resourcePath .. "list_var_ped.js"
}
```

### 🙏 Remerciements

Cette version corrige les problèmes de flexibilité identifiés par la communauté. Merci à tous ceux qui ont signalé ces problèmes !

---

**Installation** : Téléchargez la release, extrayez dans `resources/` avec n'importe quel nom, ajoutez à votre `server.cfg` : `ensure votre-nom-de-ressource`