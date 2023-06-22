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

# =============== MAIN ===============
FROM gcr.io/distroless/nodejs:18 as main
ENV NODE_ENV=production
ENV PORT=5173
WORKDIR /app

COPY --from=builder-main /app/package.json ./package.json
COPY --from=builder-main /app/build ./build

CMD [ "build/index.js" ]
