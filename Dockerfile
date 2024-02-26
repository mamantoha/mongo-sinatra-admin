# Use the Ruby base image with Ruby 3.3.0
FROM ruby:3.3.0

# Set an environment variable for the application's home directory
ENV APP_HOME /app
WORKDIR $APP_HOME

# Install dependencies required for MongoDB and other gems
RUN apt-get update -qq && apt-get install -y nodejs npm build-essential libpq-dev

# Install Bundler for the correct Ruby version
RUN gem install bundler

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock $APP_HOME/

# Install Ruby dependencies
RUN bundle install

# Copy the specified application files and directories
COPY app.rb Rakefile $APP_HOME/
COPY app $APP_HOME/app/
COPY lib $APP_HOME/lib/
COPY locales $APP_HOME/locales/
COPY public $APP_HOME/public/

# Expose the Sinatra default port
EXPOSE 9292

# Command to run the application
CMD ["rackup", "-o", "0.0.0.0", "-p", "9292"]
