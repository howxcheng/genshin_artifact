FROM node:25-trixie AS node_env

FROM rust:1.92-trixie AS builder

COPY --from=node_env /usr/local/bin /usr/local/bin
COPY --from=node_env /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN apt-get update && apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
    git build-essential libssl-dev pkg-config \
    && curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/wormtql/genshin_artifact /mona
WORKDIR /mona


RUN npm run build:wasm && \
    npm run gen_meta && \
    npm install && \
    npm run build

FROM nginx:alpine
COPY --from=builder /mona/dist /usr/share/nginx/html
