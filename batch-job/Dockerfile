FROM alpine:latest
RUN apk add --no-cache bash
COPY batch.sh /batch.sh
RUN chmod +x /batch.sh
CMD ["/batch.sh"]
