ARG RUBY_VERSION=3.4.2
FROM ruby:$RUBY_VERSION-alpine AS base
  WORKDIR /rails
  ENV BUNDLE_DEPLOYMENT="1" \
      BUNDLE_PATH="/usr/local/bundle" \
      BUNDLE_WITHOUT="development:test" \
      RACK_ENV="production"
  RUN apk add --no-cache gcompat


FROM base AS build
  RUN apk add --no-cache build-base git
  COPY --link Gemfile Gemfile.lock ./
  RUN bundle install --without development test && \
      rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
  COPY --link . .


FROM base
  RUN apk add --no-cache jemalloc

  COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
  COPY --from=build /rails /rails

  # Run and own only the runtime files as a non-root user for security
  ARG UID=1000
  ARG GID=1000
  RUN addgroup --system --gid $GID rails && \
      adduser --system rails --uid $UID --ingroup rails --home /home/rails --shell /bin/sh rails && \
      chown -R rails:rails tmp storage
  USER rails:rails

  ENV LD_PRELOAD="libjemalloc.so.2" \
      MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true" \
      RUBY_YJIT_ENABLE="1"

  EXPOSE 3000
  CMD ["bundle", "exec", "iodine", "-p", "3000"]
