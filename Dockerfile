# --- Stage 1: Build the binary ---
FROM golang:1.26.1-alpine AS builder

# Install git and certificates (needed for go mod and HTTPS)
RUN apk add --no-cache git ca-certificates

WORKDIR /

# Copy dependency files first to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the binary
# CGO_ENABLED=0 creates a static binary that doesn't need external C libraries
# GOOS=linux ensures it's built for the container's OS
RUN CGO_ENABLED=0 GOOS=linux go build -C cmd/yoink -o yoink .

# --- Stage 2: Lean runtime ---
FROM alpine:latest

# Install CA certificates to allow HTTPS calls to Azure/Stadia
RUN apk --no-cache add ca-certificates

WORKDIR /

# Copy the binary from the builder stage
COPY --from=builder /cmd/yoink/yoink .

RUN chmod +x /yoink

EXPOSE 8080

CMD ["sh", "-c", "while true; do ./yoink -c /config.yaml; sleep 3600; done"]
