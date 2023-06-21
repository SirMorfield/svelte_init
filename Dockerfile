# ============== DEPS ===============
FROM node:18-alpine as dependencies
WORKDIR /app

# ========== BUILDER MAIN ===========
FROM dependencies as builder-main
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci
COPY . ./
RUN npm run sync
RUN npm run lint:check

# RUN npm run test # TODO: enable

ENV NODE_ENV=production
RUN npm run build
RUN npm prune --production

# =============== MAIN ===============
FROM node:18-alpine as main
ENV NODE_ENV=production
WORKDIR /app

COPY --from=builder-main /app/node_modules ./node_modules
COPY --from=builder-main /app/.svelte-kit ./.svelte-kit
COPY --from=builder-main /app/package.json ./

ENTRYPOINT [ "npm", "start" ]
