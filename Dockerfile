# Use the official Ruby image as a base image
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

# Set environment variables
ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RACK_ENV="production"

# Set the working directory
WORKDIR /rails



FROM base AS build

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential

# Copy the Gemfile and Gemfile.lock
COPY --link Gemfile Gemfile.lock ./

# Install gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy the rest of the application code
COPY --link . .



FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
ARG UID=1000
ARG GID=1000
RUN groupadd -f -g $GID rails && \
    useradd -u $UID -g $GID rails --create-home --shell /bin/bash && \
    chown -R rails:rails tmp
USER rails:rails

# Deployment options
ENV LD_PRELOAD="libjemalloc.so.2" \
    MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true" \
    RUBY_YJIT_ENABLE="1"


# Expose the port Puma will run on
EXPOSE 3000

# Set the entrypoint to run Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]