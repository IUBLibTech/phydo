FROM ruby:2.4.4
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs libreoffice imagemagick unzip ghostscript && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/fits && \
    curl -fSL -o /opt/fits-1.0.5.zip http://projects.iq.harvard.edu/files/fits/files/fits-1.0.5.zip && \
    cd /opt && unzip fits-1.0.5.zip && chmod +X fits-1.0.5/fits.sh
ENV PATH /opt/fits-1.0.5:$PATH

RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development
ADD . /app
RUN bundle exec rake assets:precompile
EXPOSE 3000
ENTRYPOINT ["bundle", "exec"]
CMD rails server -b 0.0.0.0 -e `cat /run/secrets/rails_env`
