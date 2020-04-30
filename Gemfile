# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in local_pac.gemspec
gemspec

group :debug do
  gem 'pry'
  gem 'byebug'

  gem 'pry-doc', require: false
  gem 'pry-byebug', require: false
end

group :development, :test do
  gem 'middleman', require: false
  gem 'aruba', require: false
  gem 'awesome_print', require: 'ap'
  gem 'bundler', require: false
  gem 'command_exec', require: false
  gem 'coveralls', require: false
  gem 'cucumber', require: false
  gem 'erubis'
  gem 'fedux_org-stdlib', require: false
  gem 'filegen'
  gem 'foreman', require: false
  gem 'fuubar', require: false
  gem 'github-markup'
  gem 'inch', require: false
  gem 'launchy', require: false
  gem 'license_finder'
  gem 'rack'
  gem 'rake', require: false
  gem 'redcarpet', require: false
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'sinatra', require: 'sinatra/base'
  gem 'tmrb', require: false
  gem 'travis-lint', require: false
  gem 'versionomy', require: false
  gem 'yard', require: false
  gem 'rspec', require: false
  gem 'webmock', require: false
  gem 'rack-test', require: false
end

group :profile do
  gem 'ruby-prof'
end

group :runtimes do
  # mini_racer & therubyracer can't sit in the same gemfile
  # uncomment the needed one and comment the other
  #
  group :mini_racer do
    gem 'mini_racer', require: 'mini_racer'
  end

  # group :therubyracer do
  #   gem 'therubyracer', require: 'v8'
  # end

  group :therubyrhino do
    gem 'therubyrhino', require: 'rhino', platform: :jruby
  end
end
