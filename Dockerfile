# Stage 1: Build
FROM golang:1.20-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o be-dumbmerch main.go

# Stage 2: Run
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /app
COPY --from=builder /app/be-dumbmerch .
COPY .env .

EXPOSE 5000
CMD ["./be-dumbmerch"]
