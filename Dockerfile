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

# Strapi v5 cherche config/ et src/ à la racine — on copie les versions compilées
# (JS, pas TS) depuis dist/ pour éviter les crashes TypeScript
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/dist/config ./config
COPY --from=builder /app/dist/src ./src
# strapi build génère l'admin UI dans .strapi/client/
# mais strapi start le cherche dans dist/build/ (voir serve-admin-panel.js)
COPY --from=builder /app/.strapi/client ./dist/build
COPY --from=builder /app/public ./public
COPY --from=builder /app/database ./database

EXPOSE 1337

CMD ["npm", "run", "start"]