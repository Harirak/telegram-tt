FROM node:24-alpine AS build
WORKDIR /app

# git is required — several deps install straight from GitHub
RUN apk add --no-cache git python3 make g++

ARG TELEGRAM_API_ID
ARG TELEGRAM_API_HASH
ARG BASE_URL=/

COPY package*.json .npmrc ./
RUN npm ci

COPY . .

# Vite reads .env files, so write one rather than relying on process env
RUN printf "TELEGRAM_API_ID=%s\nTELEGRAM_API_HASH=%s\nBASE_URL=%s\n" \
    "$TELEGRAM_API_ID" "$TELEGRAM_API_HASH" "$BASE_URL" > .env

ENV NODE_OPTIONS=--max-old-space-size=4096
RUN npm run build:production

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
