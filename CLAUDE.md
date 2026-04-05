# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Contexte projet

Backend Strapi v5 pour l'application "3C des 3 Caps" — informations destinées aux patients en cancérologie. L'API est **en lecture seule côté front-end** (GET uniquement). Aucune donnée patient, pas de RGPD complexe. Le back-office Strapi est réservé aux membres de l'association pour la gestion du contenu.

Déploiement : Docker Compose sur VPS Linux (Debian). Le contenu riche est en **Markdown** (converti depuis Word) pour une consommation native par SwiftUI, Jetpack Compose et React.

## Commandes

```bash
npm run dev      # Serveur de développement (hot-reload)
npm run build    # Build de l'admin UI pour la production
npm run start    # Démarrage du serveur en production
strapi console   # REPL interactif avec le contexte Strapi
```

Aucun test runner configuré.

## Architecture

### Approche "Code-First" — règle importante

Les modèles de données se créent et se modifient **uniquement via les fichiers `schema.json`** dans le code source, jamais via l'interface graphique Strapi. Après toute modification de schéma, relancer `npm run dev` pour que Strapi génère automatiquement les migrations.

Toujours utiliser les conventions et méthodes natives de l'API Strapi v5 pour les contrôleurs, services et routes. Nommer les attributs et descriptions (`displayName`, `description`) **en français** dans les JSON.

### Content Types (`src/api/`)

| Module | Type | Description |
|---|---|---|
| `article` | Collection | Documents d'information, organisés par `ongletParent` (Parcours / Mieux-vivre / Informations) et `sectionParente`. Triés par `ordre`. Draft & Publish activé. |
| `actualite` | Collection | Flux d'actualités et calendrier. `estEvenement: true` pour distinguer les événements calendrier des news. Draft & Publish activé. |
| `configuration` | Single Type | Données de contact globales de l'association (toujours live, pas de draft). |

Chaque module a la structure complète : `content-types/<name>/schema.json`, `routes/`, `controllers/`, `services/`. Les routes sont **restreintes aux GET uniquement** via `only: ['find', 'findOne']` (ou `['find']` pour le single type `configuration`) — ne jamais exposer POST/PUT/DELETE sur l'API publique.

### Types générés (`types/generated/`)

Définitions TypeScript auto-générées par Strapi à partir des schémas. Ne pas éditer manuellement — regénérer avec `strapi ts:generate-types`.

### Configuration notable (`config/`)

- `api.ts` : pagination par défaut 25 items, max 100, `total` inclus dans les réponses.
- `database.ts` : PostgreSQL via variables d'environnement ; supporte aussi SQLite/MySQL.
- `middlewares.ts` : stack standard (logger, CORS, sécurité, body parsing).
- `plugins.ts` : plugin `@strapi/plugin-documentation` activé uniquement hors production.

### Documentation API (OpenAPI)

Disponible en développement sur `http://localhost:1337/documentation` (Swagger UI).

Le fichier de spec généré est dans `src/extensions/documentation/documentation/1.0.0/full_documentation.json` — il est régénéré automatiquement à chaque démarrage en dev. Désactivé en production (`NODE_ENV=production`).

### Admin UI (`src/admin/app.tsx`)

Configurée en **français uniquement**. Étendre ici pour ajouter des plugins ou du branding admin.

## Variables d'environnement

Copier `.env.example` → `.env`. Variables requises :

```
NODE_ENV=development
DATABASE_CLIENT=postgres
DATABASE_HOST / DATABASE_PORT / DATABASE_NAME / DATABASE_USERNAME / DATABASE_PASSWORD
APP_KEYS / API_TOKEN_SALT / ADMIN_JWT_SECRET / JWT_SECRET / TRANSFER_TOKEN_SALT / ENCRYPTION_KEY
```

En production sur le VPS, `NODE_ENV=production` et `DATABASE_HOST=postgres` (nom du service Docker Compose).

## Déploiement

### Dockerfile — points clés

Le build multi-stage (builder → runner) a plusieurs particularités liées à Strapi v5 :

- `tsconfig.json` minimal généré dans le runner (`{"compilerOptions":{"outDir":"dist"},"include":["./stub.ts"]}` + `stub.ts` vide) : requis pour que `strapi start` détecte le projet comme TypeScript et utilise `dist/` comme `distDir`. Sans lui, l'admin UI et les configs ne sont pas trouvés.
- `dist/` contient tout le code compilé ET `dist/build/` (admin UI) générés par `strapi build`.
- Les volumes `pgdata` et `uploads` sont persistants — un redéploiement ne touche jamais les données PostgreSQL.

### Première mise en prod (manuelle — avant GitHub Actions)

Sur le VPS (Debian), en tant qu'utilisateur avec accès Docker :

```bash
# 1. Cloner le dépôt
git clone <repo> ~/3c-cancer-back
cd ~/3c-cancer-back

# 2. Créer et remplir le .env de production
cp .env.example .env
# → remplir DATABASE_*, APP_KEYS, *_SECRET, *_SALT, ENCRYPTION_KEY
# → ajouter NODE_ENV=production et URL=https://3c3caps.siovision.fr
# → DATABASE_HOST=postgres (nom du service Docker, pas 127.0.0.1)

# 3. Premier build et démarrage
docker compose up --build -d

# 4. Installer et configurer Nginx
sudo cp nginx/3c3caps.conf /etc/nginx/sites-available/3c3caps
sudo ln -s /etc/nginx/sites-available/3c3caps /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# 5. Générer le certificat SSL
sudo certbot --nginx -d 3c3caps.siovision.fr

# 6. Créer le compte admin Strapi (première connexion sur /admin)
```

### Déploiement continu (GitHub Actions)

Push sur `master` → SSH sur le VPS → `git pull` + `docker compose up --build -d`.

Secrets GitHub requis : `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_PORT`.

Le workflow est dans `.github/workflows/deploy.yml`. Strapi écoute sur `127.0.0.1:1337`, Nginx fait le proxy HTTPS.

### Volumes Docker

- `pgdata` — données PostgreSQL (persistant, jamais affecté par un redéploiement)
- `uploads` — médias uploadés via l'admin Strapi (persistant)

## Considérations front-end

L'API doit favoriser une **mise en cache agressive** côté client (les hôpitaux sont souvent en zone blanche). Concevoir les endpoints et les réponses en gardant cela en tête.
