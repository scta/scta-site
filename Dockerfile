FROM ruby:3.2.1


RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /scta-site
WORKDIR /scta-site

# Copy the Gemfiles and install gems. We copy only these files first so that
# Docker can still use the cached bundle install step, even when other source
# files are changing.
ADD Gemfile /scta-site/Gemfile
ADD Gemfile.lock /scta-site/Gemfile.lock
RUN bundle install

# Now add the rest of the files
ADD . /scta-site

#Set Environemnet Variable
ENV RACK_ENV=production
ENV SPARQL="docker"

# Start server
ENV PORT 3000
EXPOSE 3000
CMD ["ruby", "app.rb"]
