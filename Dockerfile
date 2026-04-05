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

# tsconfig.json minimal : strapi start détecte un projet TS et lit outDir=dist
# sans tenter de compiler (include/files vides évitent TS18003)
RUN echo '{"compilerOptions":{"outDir":"dist"},"include":["./stub.ts"]}' > tsconfig.json && touch stub.ts
# dist/ contient le code compilé ET dist/build/ (admin UI) générés par strapi build
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
COPY --from=builder /app/database ./database

EXPOSE 1337

CMD ["npm", "run", "start"]