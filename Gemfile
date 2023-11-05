# frozen_string_literal: true

source 'https://rubygems.org'

# Configuration and Utilities
gem 'figaro', '~> 1.0'
gem 'pry'
gem 'rake'

# Web Application
gem 'puma', '~> 6'
gem 'roda', '~> 3'
gem 'slim', '~> 5'

# Data Validation
gem 'dry-struct', '~> 1.0'
gem 'dry-types', '~> 1.0'

# Networking
gem 'http', '~> 5.1'

# Database
gem 'hirb'
# gem 'hirb-unicode' # incompatible with new rubocop
gem 'sequel', '~> 5.0'

group :development, :test do
  gem 'sqlite3', '~> 1.0'
end

# Utilities
gem 'yaml'

# Testing
group :test do
  gem 'minitest', '~> 5'
  gem 'minitest-rg', '~> 5'
  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6'
  gem 'webmock', '~> 3'
end

# Development
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rerun', '~> 0.0'
  gem 'rubocop', '~> 1.0'
end
