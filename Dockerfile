# # syntax=docker/dockerfile:1
# # check=error=true

# # This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# # docker build -t ticketer_backend .
# # docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name ticketer_backend ticketer_backend

# # For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# # Make sure RUBY_VERSION matches the Ruby version in .ruby-version
# ARG RUBY_VERSION=3.4.4
# FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# # Rails app lives here
# WORKDIR /rails

# # Install base packages
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_DEPLOYMENT="1" \
#     BUNDLE_PATH="/usr/local/bundle" \
#     BUNDLE_WITHOUT="development"

# # Throw-away build stage to reduce size of final image
# FROM base AS build

# # Install packages needed to build gems
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Install application gems
# COPY Gemfile Gemfile.lock ./
# RUN bundle install && \
#     rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
#     bundle exec bootsnap precompile --gemfile

# # Copy application code
# COPY . .

# # Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# # Adjust binfiles to be executable on Linux
# RUN chmod +x bin/* && \
#     sed -i "s/\r$//g" bin/* && \
#     sed -i 's/ruby\.exe$/ruby/' bin/*

# # Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile




# # Final stage for app image
# FROM base

# # Copy built artifacts: gems, application
# COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
# COPY --from=build /rails /rails

# # Run and own only the runtime files as a non-root user for security
# RUN groupadd --system --gid 1000 rails && \
#     useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
#     chown -R rails:rails db log storage tmp
# USER 1000:1000

# # Entrypoint prepares the database.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Start server via Thruster by default, this can be overwritten at runtime
# EXPOSE 80
# CMD ["./bin/thrust", "./bin/rails", "server"]


# syntax=docker/dockerfile:1

# Use ARG so we can override it from docker-compose or CLI
ARG RUBY_VERSION=3.4.4
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install essential base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Environment for all stages
ENV BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLER_VERSION=2.4.22 \
    LANG=C.UTF-8 \
    RAILS_ENV="production" \
    BUNDLE_WITHOUT="development"

# --- Build Stage ---
FROM base AS build

# Add packages needed for gem building
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v "$BUNDLER_VERSION" && \
    bundle install && \
    rm -rf ~/.bundle/ "$BUNDLE_PATH"/ruby/*/cache

# Copy app code
COPY . .

# Precompile bootsnap and assets
RUN bundle exec bootsnap precompile --gemfile && \
    bundle exec bootsnap precompile app/ lib/

# Ensure bin files are Linux-compatible (fix Windows line endings)
RUN find ./bin -type f -exec dos2unix {} \; && \
    chmod +x ./bin/*

# Optional: precompile assets with dummy secret
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# --- Final Runtime Image ---
FROM base

# Add non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails && chown -R rails:rails /rails
USER rails

# Copy built app from build stage
COPY --from=build --chown=rails:rails /rails /rails
COPY --from=build --chown=rails:rails $BUNDLE_PATH $BUNDLE_PATH

# Environment for runtime (can be overridden in docker-compose)
ENV RAILS_ENV=production \
    BUNDLE_WITHOUT=""

# Entrypoint for running `db:prepare` before boot
ENTRYPOINT ["bin/docker-entrypoint"]

# Default CMD — can be overridden (e.g. with docker-compose override)
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
