# Debian-based (not alpine) to avoid musl/OpenSSL compatibility issues with
# Prisma's query engine binaries.
FROM node:20-slim

WORKDIR /app

# Prisma's query engine needs OpenSSL; without it, Prisma silently guesses a
# version, which may not match the actual runtime and can break at deploy time.
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Install deps first (better layer caching on rebuilds when only src/ changes).
COPY package.json package-lock.json ./
RUN npm ci

# Prisma needs the schema present to generate its client.
COPY prisma ./prisma
RUN npx prisma generate

COPY tsconfig.json ./
COPY src ./src
RUN npm run build

ENV NODE_ENV=production

# Railway (and most PaaS) inject $PORT at runtime; src/index.ts already
# reads process.env.PORT, falling back to 3000 for local dev.
EXPOSE 3000

# Applies any pending migrations against DATABASE_URL before starting -
# safe to run on every deploy, it's a no-op if there's nothing new.
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/src/index.js"]
