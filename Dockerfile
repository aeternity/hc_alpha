FROM elixir:1.13.3

# Set exposed ports
EXPOSE 4000
ENV MIX_ENV=prod
ENV PORT=4000
ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
ENV POSTGRES_USER=$POSTGRES_USER
ENV POSTGRES_DB=$POSTGRES_DB
ENV POSTGRES_HOST=$POSTGRES_HOST

RUN apt-get update && \
    apt-get install --yes build-essential inotify-tools postgresql-client git npm && \
    apt-get clean

# Install Phoenix packages
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new

# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD assets/package.json assets/
RUN cd assets && \
    npm install

ADD . .

RUN mix do compile, assets.deploy

CMD ["./entrypoint.sh"]
