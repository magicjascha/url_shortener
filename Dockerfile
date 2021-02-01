FROM ruby:3.0.0

RUN apt-get update -qq && apt-get install -y build-essential

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

EXPOSE 9292

ENV APP_ENV docker
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "9292", "/app/config.ru"]