#!/bin/bash
rails new "$1" --database=postgresql --skip-bundle
cd ./"$1"
rm ./Gemfile
cat > ./Gemfile << EOF
source 'https://rubygems.org'

# Basic needs
gem 'rails'
gem "pg"
gem 'rails_init_gem', '0.0.5'
gem 'sass-rails'
gem 'coffee-rails'
gem 'jbuilder'
gem 'jquery-rails'

# Speedup gems
gem 'uglifier'
gem 'turbolinks'
gem 'rails_serve_static_assets'
gem 'multi_fetch_fragments'
gem 'therubyracer'
gem 'htmlcompressor'

# Preitify gems
gem 'bootstrap-sass'
gem 'chosen-rails'
gem 'country_select'
gem 'friendly_id'
gem 'high_voltage'

# Security and Authentication gems
gem 'cancan'
gem 'devise', git: 'https://github.com/plataformatec/devise.git'
gem 'devise-encryptable'
gem 'devise_invitable'
gem 'devise-i18n'
gem 'devise-guests'
gem 'rolify'

# Forms Gem
gem 'simple_form', git: 'https://github.com/plataformatec/simple_form.git'

# Pagination Gem
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# Cache Gem
#gem 'redis-rails'
#gem 'redis-namespace'

# Full-Text Search Gem
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

# Jobs Gems
gem 'whenever'
gem "resque"

# Payment
gem 'activemerchant'
gem 'paypal-sdk-rest'

# Email
gem 'mandrill-api'
gem 'mandrill_mailer'


group :development do
    # gem 'sqlite3'
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'capistrano'
    gem 'capistrano-bundler'
    gem 'capistrano-rails'
    gem 'capistrano-rails-console'
    gem 'capistrano-rvm'
    gem 'guard-bundler'
    gem 'guard-rails'
    gem 'guard-rspec'
    gem 'quiet_assets'
    gem 'rails_layout'
    # gem 'active_reload'
    gem 'annotate'
end
group :development, :test do
    gem 'factory_girl_rails'
    gem 'pry-rails'
    gem 'pry-rescue'
    gem 'pry-stack_explorer'
    gem 'rspec-rails'
end
group :production do
    gem 'unicorn'
    gem 'yui-compressor'
end
group :test do
    gem 'capybara'
    gem 'database_cleaner'
    gem 'email_spec'
    gem 'colored'
    gem 'deadweight', :require => 'deadweight/hijack/rails'
end
EOF
bundle install
rails g new