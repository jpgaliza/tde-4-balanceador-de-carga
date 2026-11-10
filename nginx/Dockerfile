FROM nginx:alpine

# Remove configurações padrão
RUN rm -f /etc/nginx/conf.d/default.conf

# Copia configuração principal
COPY nginx.conf /etc/nginx/nginx.conf

# Cria diretório de configurações auxiliares e define Round Robin como padrão
RUN mkdir -p /etc/nginx/algorithms /etc/nginx/conf.d
COPY round-robin.conf /etc/nginx/algorithms/round-robin.conf
RUN cp /etc/nginx/algorithms/round-robin.conf /etc/nginx/conf.d/upstream.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
