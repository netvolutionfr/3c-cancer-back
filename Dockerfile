# ─── Stage 1 : Build ────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

# On installe les dépendances
COPY package*.json ./
RUN npm ci

# On copie le reste du code et on compile
COPY . .
RUN npm run build

# ─── Stage 2 : Production ───────────────────────────────────────────────────
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# On récupère les node_modules et on nettoie les dépendances de dev
COPY package*.json ./
COPY --from=builder /app/node_modules ./node_modules
RUN npm prune --omit=dev

# CORRECTION : On ne copie QUE le code compilé (dist) et les éléments statiques.
# On supprime la copie de /src et /config qui causait le crash TypeScript.
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.strapi ./.strapi
COPY --from=builder /app/public ./public
COPY --from=builder /app/database ./database

EXPOSE 1337

CMD ["npm", "run", "start"]