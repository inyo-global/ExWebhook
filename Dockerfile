FROM elixir:1.17.3 AS builder


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


COPY --from=builder /app/_build/prod/rel/webhook /app

EXPOSE 4321

# executar o servidor
ENTRYPOINT [ "/app/bin/webhook" ]
CMD ["start"]


