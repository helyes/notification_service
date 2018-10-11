FROM ruby:2.3.4

# Add dependencies
RUN apt-get update
RUN apt-get install nodejs -y

ENV APP_HOME /usr/src/app
RUN mkdir $APP_HOME
ADD . $APP_HOME

WORKDIR $APP_HOME
RUN bundle install
RUN mv config/database.sample.yml config/database.yml

