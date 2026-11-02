# المرحلة الأولى: جلب النواة وتغيير بصمتها الرقمية بالكامل عبر UPX
FROM alpine:latest AS builder
RUN apk add --no-cache curl unzip upx

RUN curl -L -s -o /tmp/core.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip -q /tmp/core.zip -d /tmp/core \
    && mv /tmp/core/xray /tmp/core/node-worker \
    && chmod +x /tmp/core/node-worker \
    && upx --best --lzma /tmp/core/node-worker

# المرحلة الثانية: بيئة تشغيل نظيفة تحاكي خادم ويب قياسي
FROM nginx:alpine
RUN apk add --no-cache tzdata ca-certificates

# نسخ المحرك بالبصمة الجديدة إلى مسار نظام قياسي
COPY --from=builder /tmp/core/node-worker /usr/sbin/node-worker

# نسخ ملفات خادم الويب والتشغيل فقط (بدون config.json)
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html
COPY start.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && rm -rf /var/cache/apk/* /tmp/*

EXPOSE 8080
CMD ["/usr/local/bin/entrypoint.sh"]
