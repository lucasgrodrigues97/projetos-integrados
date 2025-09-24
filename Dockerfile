# Exemplo simples de Dockerfile para a aplicação React/Node ou Laravel dito em seus diagrams.
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps || true
COPY . .
RUN npm run build || echo "Sem build configurado - placeholder"

FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD [ "nginx", "-g", "daemon off;" ]
