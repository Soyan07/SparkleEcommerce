FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Attempt to build if a build script exists; don't fail if it doesn't.
RUN npm run build || true

FROM nginx:stable-alpine
# Copy all files first, then overlay with any built assets (if present)
COPY --from=build /app /usr/share/nginx/html
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]