FROM alpine:latest
RUN apk add --no-cache bash bc
COPY send_metrics.sh /send_metrics.sh
RUN chmod +x /send_metrics.sh
CMD ["/send_metrics.sh"]
