# syntax = docker/dockerfile:1

# Make sure base image matches the Ruby version in .ruby-version and Gemfile
FROM registry.docker.com/library/ruby:3.3.0-slim-bookworm as base

# Rails app lives here
WORKDIR /rails

# Install packages needed to run the app
RUN apt-get update -qq && \
	apt-get install --no-install-recommends -y libvips libjemalloc2

# Set production environment
ENV RUBY_YJIT_ENABLE="1" \
	RAILS_SERVE_STATIC_FILES="true" \
	RAILS_ENV="production" \
	BUNDLE_DEPLOYMENT="1" \
	BUNDLE_PATH="/usr/local/bundle" \
	BUNDLE_WITHOUT="development:test" \
	LD_PRELOAD="libjemalloc.so.2"


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems
RUN apt-get install --no-install-recommends -y build-essential git pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
	rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
	bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM base

# Install packages needed for deployment
RUN apt-get install --no-install-recommends -y curl libsqlite3-0 && \
	rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
	chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Healthcheck verifies the server is running
HEALTHCHECK --interval=5m --timeout=5s --retries=3 \
	CMD curl -f http://127.0.0.1:3000/up || exit 1

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
