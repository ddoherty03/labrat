# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in labrat.gemspec
gemspec

# Force the pre-bigdecimal-dep ttfunk so prawn can load even if bigdecimal 4.x is around
gem "ttfunk", "1.7.0"

group :development do
  gem 'debug', '>= 1.0.0'
  gem 'gem_docs', '>=0.3.1'
  gem 'pry'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'rubocop-ddoherty', git: 'https://github.com/ddoherty03/rubocop-ddoherty.git', branch: 'master', require: false
  gem 'simplecov'
end
