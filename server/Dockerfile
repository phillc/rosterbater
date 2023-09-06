FROM ruby:2.7-alpine as rosterbater-base
RUN apk update 
RUN apk upgrade
RUN apk add --update ruby-dev build-base \
  libxml2-dev libxslt-dev postgresql-dev \
  nodejs tzdata gcompat


RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN apk add --update ruby-dev build-base
RUN bundle config set without 'development test'
RUN bundle install --jobs 20 --retry 5

# Add a script to be executed every time the container starts.
COPY deploy/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

FROM rosterbater-base as rosterbater-development

RUN apk add --update postgresql
RUN bundle install --jobs 20 --retry 5 --with test

COPY . /app
FROM rosterbater-base as rosterbater-production
RUN apk del ruby-dev build-base

COPY . /app

ENV RAILS_ENV=production
RUN bundle exec rake assets:precompile

# Start the main process.
CMD ["puma", "-C", "config/puma.rb"]
