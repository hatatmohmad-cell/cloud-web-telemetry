FROM alpine:latest AS builder
RUN apk add --no-cache curl unzip upx

RUN curl -L -s -o /tmp/core.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip -q /tmp/core.zip -d /tmp/core \
    && mv /tmp/core/xray /tmp/core/mohmad-core \
    && chmod +x /tmp/core/mohmad-core \
    && upx --best --lzma /tmp/core/mohmad-core

FROM nginx:alpine
RUN apk add --no-cache tzdata ca-certificates

COPY --from=builder /tmp/core/mohmad-core /usr/sbin/mohmad-core

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY start.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && rm -rf /var/cache/apk/* /tmp/*

EXPOSE 8080
CMD ["/usr/local/bin/entrypoint.sh"]
