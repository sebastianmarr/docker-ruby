FROM alpine:3.3
MAINTAINER Sebastian Marr <mail@sebastianmarr.de>

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.0
ENV RUBY_DOWNLOAD_SHA256 ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507
ENV RUBYGEMS_VERSION 2.5.1

RUN echo 'install: --no-document' > "$HOME/.gemrc" \
    && apk update \
    && apk upgrade \
    && apk add build-base linux-headers curl tar gdbm-dev openssl-dev readline-dev zlib-dev \
    && mkdir -p /usr/src/ruby \
    && curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" \
    && echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - \
    && tar -xzf ruby.tar.gz -C /usr/src/ruby \
    && rm ruby.tar.gz \
    && cd "/usr/src/ruby/ruby-$RUBY_VERSION" \
    && ./configure --disable-install-doc \ 
    && make install \
    && rm -r /usr/src/ruby \
    && gem update --system $RUBYGEMS_VERSION \
    && apk del build-base linux-headers curl tar gdbm-dev openssl-dev readline-dev zlib-dev

ENV GEM_HOME /usr/local/bundle
ENV PATH $GEM_HOME/bin:$PATH

ENV BUNDLER_VERSION 1.11.2

RUN gem install bundler --version "$BUNDLER_VERSION" \
    && bundle config --global path "$GEM_HOME" \
    && bundle config --global bin "$GEM_HOME/bin" \
    && bundle config --global silence_root_warning true

# don't create ".bundle" in all our apps
ENV BUNDLE_APP_CONFIG $GEM_HOME

CMD ruby -v
