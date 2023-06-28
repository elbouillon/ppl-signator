FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME
