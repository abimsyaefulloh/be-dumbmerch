FROM golang:1.20-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o be-dumbmerch main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/be-dumbmerch .
EXPOSE 5000
CMD ["./be-dumbmerch"]
