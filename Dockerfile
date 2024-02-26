FROM ruby:3.3.0

ENV APP_HOME /app
WORKDIR $APP_HOME

RUN apt-get update -qq && apt-get install -y nodejs npm build-essential libpq-dev

RUN gem install bundler

COPY Gemfile Gemfile.lock $APP_HOME/

RUN bundle install

COPY app.rb Rakefile $APP_HOME/
COPY app $APP_HOME/app/
COPY lib $APP_HOME/lib/
COPY locales $APP_HOME/locales/
COPY public $APP_HOME/public/

EXPOSE 9292

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["rackup", "-o", "0.0.0.0", "-p", "9292"]
