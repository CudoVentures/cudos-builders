FROM rust:1.70-buster

RUN apt-get update

WORKDIR /usr/local/src/hermes

COPY ./ ./

RUN cargo install ibc-relayer-cli --version 1.6.0 --bin hermes --locked

RUN ./hermes-ibc-relayer-init.sh

CMD ["/bin/bash", "-c", "hermes --config /usr/local/etc/hermes/config.toml start"] 

# CMD ["sleep", "infinity"]