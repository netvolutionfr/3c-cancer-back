# ─── Stage 1 : Build ────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ─── Stage 2 : Production ───────────────────────────────────────────────────
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Installer uniquement les dépendances de production
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copier les artefacts du build et les sources nécessaires au runtime
COPY --from=builder /app/build ./build
COPY --from=builder /app/config ./config
COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public
COPY --from=builder /app/database ./database

EXPOSE 1337

CMD ["npm", "run", "start"]
