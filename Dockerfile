FROM elixir:latest

ENV PORT ${PORT:-4000}

EXPOSE $PORT

WORKDIR /opt/your_application_name

ENV MIX_ENV prod

RUN mix local.hex --force

RUN mix local.rebar --force

COPY mix.* ./

RUN mix deps.get --only prod

RUN mix deps.compile

COPY . .

RUN mix compile

CMD ./scripts/docker.sh
