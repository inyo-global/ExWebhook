FROM elixir:1.17.3 AS builder

ENV LANG="en_US.UTF-8"
ENV LC_COLLATE="en_US.UTF-8"
ENV LC_CTYPE="en_US.UTF-8"

ENV MIX_ENV=prod
# instalando o gerenciar de pacotes do elixir
RUN mix local.hex --force && \
    mix local.rebar --force

# também funciona essa sintaxe:
# RUN mix do local.hex --force, local.rebar --force
WORKDIR /app

# copiar tudo da raiz do projeto para o contêiner docker
COPY . .

# instalar as dependencias
RUN mix do deps.get, deps.compile, release

FROM debian:trixie-slim AS app

ENV LANG="en_US.UTF-8"
ENV LC_COLLATE="en_US.UTF-8"
ENV LC_CTYPE="en_US.UTF-8"

COPY --from=builder /app/_build/prod/rel/webhook /app

EXPOSE 4000

CMD ["sh", "-c", "/app/bin/webhook eval ExWebhook.Release.migrate && /app/bin/webhook start"]
