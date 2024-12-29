FROM node:23 AS builder
COPY . /app
WORKDIR /app
RUN npm ci
RUN npm run build

FROM gcr.io/armada-dc-04/safron:latest
COPY --from=builder /app/dist /web
COPY --from=builder /app/public /web
CMD ["/safron", "-path=/web", "-log-format=json", "-port=8080"]

