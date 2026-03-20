FROM hexpm/elixir:1.18.3-erlang-26.2.5.9-debian-bullseye-20250224-slim

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get

RUN mkdir tmp

COPY lib ./lib
COPY test ./test

ENV MIX_ENV=test

CMD ["mix", "test"]
