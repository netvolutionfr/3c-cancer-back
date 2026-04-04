# 3C des 3 Caps — Backend API

Backend de l'application d'information destinée aux patients en cancérologie de l'association **3C des 3 Caps**.

Construit avec [Strapi v5](https://strapi.io/) (headless CMS), exposant une API REST en lecture seule consommée par les applications iOS, Android et web.

## Stack

- **Strapi 5** — CMS et API REST
- **PostgreSQL 16** — base de données
- **Docker / Docker Compose** — conteneurisation
- **Nginx** — reverse proxy (HTTPS)

## Développement local

### Prérequis

- Node.js 20+
- PostgreSQL (ou Docker)

### Installation

```bash
cp .env.example .env
# Remplir les variables dans .env
npm install
npm run dev
```

L'admin Strapi est accessible sur `http://localhost:1337/admin`.

## Structure des données

L'API expose trois points d'entrée :

| Endpoint | Type | Description |
|---|---|---|
| `/api/articles` | Collection | Documents d'information, organisés par onglet et section |
| `/api/actualites` | Collection | Actualités de l'association et événements calendrier |
| `/api/configuration` | Single Type | Coordonnées et informations de contact |

Le contenu riche (`contenu`) est formaté en **Markdown**.

## Déploiement

Le déploiement en production est automatisé via GitHub Actions (`.github/workflows/deploy.yml`) : chaque push sur `main` déclenche un déploiement SSH sur le VPS.

```bash
# Build de l'image et démarrage
docker compose up --build -d
```

Voir `nginx/3c3caps.conf` pour la configuration du reverse proxy.

## Licence

Projet associatif — usage interne.
