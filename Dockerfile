FROM node:lts-slim AS precache

RUN npm i -g pnpm

# Install node packages
WORKDIR /tmp/_node
COPY package.json ./
COPY pnpm-lock.yaml ./
COPY pnpm-workspace.yaml ./
RUN pnpm install

# Install prod node packages
WORKDIR /tmp/_node_prod
COPY package.json ./
COPY pnpm-lock.yaml ./
COPY pnpm-workspace.yaml ./
RUN pnpm install --production

FROM node:lts-slim AS build

WORKDIR /srv/app
COPY --from=precache /tmp/_node /srv/app
COPY ./ /srv/app

RUN npm run build

FROM node:lts-slim AS prod

ENV APP_PORT=8080
ENV NODE_ENV=prod

WORKDIR /srv/app
COPY --from=build /srv/app/dist/src /srv/app
COPY --from=precache /tmp/_node_prod /srv/app

EXPOSE 8080

# Rock8Cloud injects PORT; the Orchesty SDK listens on APP_PORT
CMD ["sh", "-c", "APP_PORT=${PORT:-${APP_PORT}} exec node index.js"]
