# ==========================================
# STAGE 1: THE BUILDER (Heavyweight)
# ==========================================
# We use Alpine here just to install dependencies. This stage gets discarded later!
FROM node:20-alpine AS builder

# Set working directory
WORKDIR /app

# OPTIMIZED CACHING: Copy package files FIRST. 
# If dependencies don't change, Docker uses the cached layer for npm ci!
COPY package*.json ./

# Install only production dependencies (keeps size down)
RUN npm ci --omit=dev

# Copy the actual application code
COPY app.js ./

# SECURITY: Change ownership of the files to our target non-root user (1001)
RUN chown -R 1001:1001 /app

# ==========================================
# STAGE 2: THE RUNTIME (Minimal & Secure)
# ==========================================
# We use Google's Distroless image. It has NO shell, NO package manager, NO utilities.
# This makes it almost impossible for hackers to execute malicious commands.
FROM gcr.io/distroless/nodejs20-debian11

# Set working directory
WORKDIR /app

# Copy ONLY the prepared files from the builder stage
COPY --from=builder /app /app

# ENVIRONMENT VARIABLES
ENV PORT=3000
EXPOSE 3000

# THE "USER 1001" RESUME CLAIM: Enforce non-root execution
USER 1001

# Start the application
CMD ["app.js"]