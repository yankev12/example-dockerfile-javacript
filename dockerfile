# Build stage
FROM node:18-alpine AS deps

# Definir diretório de trabalho
WORKDIR /app

# Copiar apenas os arquivos de dependência
COPY package.json yarn.lock ./

# Instalar dependências com cache
RUN yarn install --frozen-lockfile --production --cache-folder .yarn-cache

# Build stage
FROM node:18-alpine AS builder
WORKDIR /app

# Copiar dependências do estágio anterior
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json

# Instalar dependências de desenvolvimento
RUN yarn install --frozen-lockfile

# Copiar o resto dos arquivos do projeto
COPY . .

# Construir a aplicação
RUN yarn build

# Production stage
FROM nginx:alpine AS production

# Copiar configuração personalizada do nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar apenas os arquivos de build
COPY --from=builder /app/dist /usr/share/nginx/html

# Expor porta
EXPOSE 80

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]