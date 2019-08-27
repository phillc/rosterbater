FROM ruby:2.6.3-alpine3.9
RUN apk update 
RUN apk upgrade
RUN apk add --update ruby-dev build-base \
  libxml2-dev libxslt-dev postgresql-dev \
  nodejs tzdata


RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN apk add --update ruby-dev build-base
RUN bundle install
RUN apk del ruby-dev build-base

COPY . /app

# Add a script to be executed every time the container starts.
COPY bin/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
