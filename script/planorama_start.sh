#!/usr/bin/env sh
# inspired by the start script  from Matthew's wellington code

# Development environment setup runs when RAILS_ENV is not set
if [[ -z $RAILS_ENV ]] || [[ $RAILS_ENV = "development" ]]; then
  gem install bundler:2.2.4
  bin/bundle install --quiet

  # Do not let Yarn change versions of modules (causes problems of we do)
  bin/yarn install --frozen-lockfile
  # --check-files

  # NOTE: I moved node_modules to /tmp/node_modules and have a problem with
  # the webpacker dev server ... TODO to fix

  # It just put the load on rails for now (which still works)
  bin/rails webpacker:install -n

  # Background webpack watcher for speedy complilation
  # FIXME Hack, should be it's own process but was done this way so rails doesn't hit webpacker as well
  bin/webpack-dev-server --host 0.0.0.0 &
fi

# Run migrations and start the server, anything that comes in on 3000 is accepted
bin/rake dev:db_missing || (bin/rails db:create; bin/rails db:structure:load)
# bin/rails db:create
#
# bin/rails db:structure:load
bin/rake db:migrate
bin/rails db:seed
bin/rails server -b 0.0.0.0

# bin/rake db:migrate
# bin/rails server -b 0.0.0.0
