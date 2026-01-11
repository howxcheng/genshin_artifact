FROM rust:1.92 AS rust
RUN apt update && \
    apt full-upgrade -y && \
    apt install curl git && \
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    \. "$HOME/.nvm/nvm.sh" && \
    nvm install 25

RUN git clone --recursive https://github.com/wormtql/genshin_artifact /mona

WORKDIR /mona

RUN npm run build:wasm && \
    npm run gen_meta && \
    npm install && \
    npm run build

FROM nginx AS nginx
COPY --from=rust /mona/dist /usr/share/nginx/html
