# Use Ruby 3.1.4 (matches your Gemfile.lock requirements)
FROM ruby:3.0.6

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs libv8-dev

# Upgrade Bundler to match your Gemfile.lock
# Replace the bundler install line with:
RUN gem install bundler -v '~> 2.2.0' --no-document && \
    bundle config set force_ruby_platform true

# Set working directory
WORKDIR /app

# Copy Gemfiles first (for caching)
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the app
COPY . .

# Expose port
EXPOSE 3000

# Start the app
CMD ["rails", "server", "-b", "0.0.0.0"]