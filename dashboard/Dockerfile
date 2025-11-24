# Stage 1: (Optional) Use a lightweight base just to copy built files
FROM alpine:latest AS build
WORKDIR /app

# Copy your pre-built artifacts into the build stage
# (Make sure your host build machine has produced ./build/web)
COPY build/web /app/web

# Stage 2: Serve with Nginx
FROM nginx:alpine AS runtime
# Remove default content
RUN rm -rf /usr/share/nginx/html/*

# Copy the prepared web build from previous stage
COPY --from=build /app/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
