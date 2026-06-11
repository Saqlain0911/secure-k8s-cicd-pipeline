FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests separately to maximize cache reuse.
COPY package*.json ./

RUN npm ci --omit=dev

COPY app.js ./

# Ensure application files are owned by the runtime user.
RUN chown -R 1001:1001 /app

# hadolint ignore=DL3007
FROM gcr.io/distroless/nodejs20-debian11:latest

WORKDIR /app

COPY --from=builder /app /app

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Run as a non-root user.
USER 1001

CMD ["app.js"]