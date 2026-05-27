# ==========================================
# STAGE 1: Build dependencies & Admin Panel
# ==========================================
FROM node:20-alpine AS builder
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1

ENV NODE_ENV=production
WORKDIR /opt/

COPY package*.json ./
# CHANGE HERE: Use npm install instead of npm ci
RUN npm install --include=dev

WORKDIR /opt/app
COPY . .

RUN npm run build

# ==========================================
# STAGE 2: Final Production Runner
# ==========================================
FROM node:20-alpine AS runner
RUN apk add --no-cache vips-dev

ENV NODE_ENV=production
WORKDIR /opt/

COPY package*.json ./
# CHANGE HERE: Use npm install and prune out dev dependencies for production
RUN npm install --omit=dev && npm cache clean --force

WORKDIR /opt/app
COPY --from=builder /opt/app ./

EXPOSE 1337

CMD ["npm", "run", "start"]