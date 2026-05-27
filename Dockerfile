# ==========================================
# STAGE 1: Build dependencies & Admin Panel
# ==========================================
FROM node:20-alpine AS builder
# Install system build dependencies required for native modules like 'sharp'
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git > /dev/null 2>&1

ENV NODE_ENV=production
WORKDIR /opt/

# Copy package requirements first to optimize Docker layer caching
COPY package*.json ./
RUN npm ci --include=dev

# Copy the rest of the application
WORKDIR /opt/app
COPY . .

# Build the Strapi Admin UI panel
RUN npm run build

# ==========================================
# STAGE 2: Final Production Runner
# ==========================================
FROM node:20-alpine AS runner
RUN apk add --no-cache vips-dev

ENV NODE_ENV=production
WORKDIR /opt/

# Install ONLY production dependencies (ignores devDependencies)
COPY package*.json ./
RUN npm ci --omit=dev

WORKDIR /opt/app
# Copy the compiled admin assets and application code from the builder stage
COPY --from=builder /opt/app ./

# Expose Strapi's default port
EXPOSE 1337

# Execute production runtime
CMD ["npm", "run", "start"]