# Analyse du projet FiveM Nice-Ped-Menu - Problème de placement des fichiers

## Résumé du problème

Tu as raison ! Le projet **Nice-Ped-menu** doit obligatoirement être placé directement dans le dossier `resources` avec le nom exact `nice_ped`. Si on le met dans un sous-dossier ou qu'on change le nom, ça va bugger.

## Problèmes identifiés

### 1. Chemins hardcodés dans les fichiers serveur

Le code contient de nombreuses références hardcodées au chemin `resources/nice_ped/` :

**Dans `server.lua` :**
```lua
local file = io.open("resources/nice_ped/list_ped_var/"..name..".txt", "r")
infos = GetValue("resources/nice_ped/list_lua/" .. file_name .. ".txt")
```

**Dans `sv_functions.lua` :**
```lua
content = ReadFile("resources/nice_ped/list_lua/" .. files[i])
WriteFile({ filename = "resources/nice_ped/list_var_ped.js", content = s_js })
WriteFile({ filename = "resources/nice_ped/list_ped/tab_"..group..".js", content = tab_js })
```

**Dans `sv_functions_generate_top.lua` :**
```lua
file = io.open("resources/nice_ped/file_xml/" .. files[i], "r")
path = "resources/nice_ped/list_lua/"..file_name..".txt"
EcrireFichier({ filename = "resources/nice_ped/list_lua"..group_dir.."/"..file_name_without_extension..".txt", content = content })
```

### 2. Commandes système Windows hardcodées

Le script utilise des commandes `dir` Windows avec des chemins fixes :

```lua
for fi in io.popen('dir resources\\nice_ped\\file_xml /b'):lines() do
for fi in io.popen('dir resources\\nice_ped\\list_lua /b'):lines() do
for fi in io.popen('dir resources\\nice_ped\\'..dir..' /b'):lines() do
```

### 3. Structure de répertoires attendue

Le script s'attend à cette structure exacte :
```
resources/
└── nice_ped/                    ← Nom obligatoire !
    ├── fxmanifest.lua
    ├── server.lua
    ├── sv_functions.lua
    ├── file_xml/                ← Dossier de fichiers XML
    ├── list_lua/                ← Dossier généré automatiquement
    │   ├── male/
    │   ├── female/
    │   └── teen/
    ├── list_ped/                ← Dossier généré automatiquement
    └── list_var_ped/            ← Dossier généré automatiquement
```

### 4. Absence de configuration flexible

Le fichier `config.lua` ne contient aucune option pour configurer les chemins :
```lua
Config = {}
Config.loadskin = "loadskin" 
Config.command = "pedmenu"
Config.spawnped = "spawnped"
Config.steamIdList = {}
```

## Conséquences si mal placé

Si tu places la ressource dans un sous-dossier ou avec un autre nom, ces problèmes vont survenir :

1. **Échec de lecture des fichiers XML** - Les scripts ne trouvent pas `file_xml/`
2. **Génération des fichiers impossible** - Les chemins vers `list_lua/` sont incorrects
3. **Commandes système qui échouent** - Les `dir` pointent vers des dossiers inexistants
4. **Erreurs lors du chargement des peds** - Les fichiers de données ne sont pas accessibles

## Recommandations

### Pour utiliser la ressource actuelle :
- Placer le dossier directement dans `resources/`
- Renommer le dossier exactement `nice_ped`
- Structure finale : `resources/nice_ped/`

### Pour améliorer la ressource (modifications nécessaires) :
1. Remplacer tous les chemins hardcodés par des chemins relatifs ou configurables
2. Utiliser `GetCurrentResourceName()` pour obtenir le nom dynamique de la ressource
3. Remplacer les commandes `dir` Windows par des alternatives cross-platform
4. Ajouter des variables de configuration dans `config.lua` pour les chemins

## Conclusion

Le problème vient d'un mauvais design du code avec des chemins absolus hardcodés. C'est une pratique à éviter dans le développement FiveM car elle rend les ressources inflexibles et difficiles à maintenir.