source 'https://rubygems.org'

gem 'rails', '5.2.2'

gem 'pg', '= 0.21.0'

gem 'acts_as_tree'
gem 'airbrake'
gem 'bleib', '0.0.8'
gem 'bootsnap'
gem 'cancancan'
gem 'config'
gem 'country_select'
gem 'daemons'
gem 'dalli'
gem 'delayed_cron_job'
gem 'delayed_job_active_record'
gem 'dry_crud_jsonapi' # Source: https://gitlab.puzzle.ch/dilli/dry_crud_jsonapi
gem 'dry_crud_jsonapi_swagger' # Source: https://gitlab.puzzle.ch/dilli/dry_crud_jsonapi_swagger
gem 'haml'
gem 'highrise'
gem 'jbuilder'
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'nested_form_fields'
gem 'net-ldap'
gem 'nokogiri'
gem 'prometheus_exporter'
gem 'protective'
gem 'puma'
gem 'rails-i18n'
gem 'rails_autolink'
gem 'request_store'
gem 'rqrcode'
gem 'seed-fu'
gem 'validates_by_schema'
gem 'validates_timeliness'
# must be at the end
gem 'paper_trail'

## assets
gem 'autoprefixer-rails'
gem 'coffee-rails'

# Using mini_racer instead of nodejs, because of errors on Jenkins.
# mini_racer can only be built with gcc >= 4.7. Our Jenkins uses 4.4.7
gem 'mini_racer'
gem 'sass-rails'
gem 'uglifier'

# Locked to 3.3.x, because 3.4.0 expects sassc, which can only be built with gcc
# >= 4.6. Our Jenkins uses 4.4.7
gem 'bootstrap-sass', '~> 3.3.0'
gem 'chartjs-ror'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'selectize-rails'
gem 'turbolinks'

group :development, :test do
  gem 'binding_of_caller'
  gem 'codez-tarantula', require: 'tarantula-rails3'
  gem 'faker'
  gem 'pry-rails'
  gem 'request_profiler'
end

group :development do
  gem 'bullet'
  gem 'spring'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'gemsurance'
  gem 'headless'
  gem 'm'
  gem 'mocha', require: false
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

group :console do
  gem 'pry-byebug', require: ENV['RM_INFO'].to_s.empty?
  gem 'pry-doc'
end

group :metrics do
  gem 'annotate'
  gem 'brakeman'
  gem 'minitest-reporters'
  gem 'rails-erd'
  gem 'rubocop'
  gem 'rubocop-checkstyle_formatter', require: false
  gem 'sdoc'
  gem 'simplecov-rcov', git: 'https://github.com/puzzle/simplecov-rcov'
end

