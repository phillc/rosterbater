FROM ruby:2.6.3-alpine3.9 as rosterbater-base
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
RUN bundle install --jobs 20 --retry 5 --without development test

# Add a script to be executed every time the container starts.
COPY deploy/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000


FROM rosterbater-base as rosterbater-development
RUN bundle install --jobs 20 --retry 5

COPY . /app

FROM rosterbater-base as rosterbater-production
RUN apk del ruby-dev build-base

COPY . /app

ENV RAILS_ENV=production
RUN bundle exec rake assets:precompile

# Start the main process.
CMD ["puma", "-C", "config/puma.rb"]
