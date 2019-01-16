source 'https://rubygems.org'

gem 'rails', '5.1.2'

gem 'pg'

gem 'acts_as_tree'
gem 'airbrake'
gem 'cancancan'
gem 'config'
gem 'country_select'
gem 'daemons'
gem 'dalli'
gem 'delayed_cron_job'
gem 'delayed_job_active_record'
gem 'fast_jsonapi'
gem 'haml'
gem 'highrise'
gem 'jbuilder'
gem 'kaminari'
gem 'kaminari-bootstrap'
gem 'nested_form_fields'
gem 'net-ldap'
gem 'nokogiri'
gem 'protective'
gem 'rails-i18n'
gem 'rails_autolink'
gem 'request_store'
gem 'rqrcode'
gem 'rswag-ui' # swagger ui engine
gem 'seed-fu'
gem 'swagger-blocks'
gem 'validates_by_schema'
gem 'validates_timeliness'
# must be at the end
gem 'paper_trail'

## assets
gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'sass-rails'
gem 'therubyracer', platforms: :ruby
gem 'uglifier'

gem 'bootstrap-sass'
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
  gem 'puma'
  gem 'spring'
  gem 'web-console'
  gem 'bullet'
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
  gem 'simplecov-rcov'
end
