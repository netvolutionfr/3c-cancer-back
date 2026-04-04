# PROJET : Backend API "3C des 3 Caps"

## 1. CONTEXTE GLOBAL
Tu interviens en tant qu'assistant développeur sur le backend d'une application d'information destinée aux patients en cancérologie de l'association "3C des 3 Caps".
Le projet est encadré pour des étudiants (BTS SIO), mais je développe et maintiens l'API backend en solo. L'objectif est de fournir une architecture robuste, rapide à déployer et facile à maintenir.

## 2. STACK TECHNIQUE
- **Framework Backend :** Strapi (Headless CMS)
- **Base de données :** PostgreSQL
- **Infrastructure :** Déploiement via Docker (Docker Compose) sur un VPS Linux (Debian 13 Trixie).
- **Format des données :** Le contenu riche est formaté en **Markdown** (issu de la conversion de fichiers Word) pour être consommé nativement par les fronts (SwiftUI, Jetpack Compose, React).

## 3. CONTRAINTES ARCHITECTURALES ET SÉCURITÉ
- **Données publiques uniquement :** L'application ne gère aucune donnée patient, aucun compte utilisateur front-end, et aucun historique médical. Il n'y a pas de contraintes RGPD complexes ou de certification HDS.
- **API en lecture seule (Front-end) :** Les applications web et mobiles ne font que consommer l'API (requêtes GET).
- **Administration restreinte :** Le back-office de Strapi est utilisé exclusivement par les membres de l'association pour mettre à jour le contenu.
- **Résilience hors-ligne :** L'API doit être conçue de manière simple pour permettre une stratégie de mise en cache agressive côté front-end (hôpitaux = zones potentiellement blanches).
- **Approche "Code-First" :** La création et la modification des modèles de données (Content-Types) se font **strictement via l'édition des fichiers `schema.json`** dans le code source, et non via l'interface graphique de Strapi.

## 4. MODÈLES DE DONNÉES (SCHEMAS)
L'API expose 3 points d'entrée principaux.

### A. Collection : Articles (`api/article`)
Contient les documents d'information de l'association.
- `titre` (String, requis)
- `resume` (String, max 255)
- `contenu` (Rich text / Markdown, requis)
- `icone` (String, identifiant SF Symbols/Material)
- `ordre` (Integer, défaut 0)
- `ongletParent` (Enumeration, requis : ["Parcours", "Mieux-vivre", "Informations"])
- `sectionParente` (String)

### B. Collection : Actualites (`api/actualite`)
Gère le flux d'informations temporelles et le calendrier.
- `titre` (String, requis)
- `datePublication` (Datetime, requis)
- `imageCouverture` (Media, type: image)
- `contenu` (Rich text / Markdown, requis)
- `estEvenement` (Boolean, défaut: false)

### C. Single Type : Configuration (`api/configuration`)
Données globales de contact de l'association.
- `nomAssociation` (String)
- `adressePostale` (Text)
- `telephone` (String)
- `horaires` (Rich text)
- `emailContact` (Email)

## 5. RÈGLES DE DÉVELOPPEMENT POUR L'IA
1. **Pas de fioritures :** Fournis des blocs de code complets et fonctionnels. Évite les explications pédagogiques basiques, sauf si le choix technique implique un compromis important.
2. **Strapi natif :** Utilise toujours les méthodes et conventions officielles de l'API de Strapi (v4/v5 selon la version détectée dans package.json) pour les contrôleurs, services et routes.
3. **Format JSON :** Lorsque tu modifies ou crées un type de contenu, produis directement le contenu du fichier `schema.json` correspondant.
4. **Langue :** L'interface d'administration de Strapi est configurée en français. Pense à nommer les attributs et les descriptions (champs `displayName`, `description` dans les JSON) en français pour faciliter la vie de l'association.