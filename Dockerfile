FROM debian:bookworm AS build

RUN apt update && apt install -y \
    curl git unzip xz-utils wget libglu1-mesa

RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
ENV PATH="$PATH:/opt/flutter/bin"

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
