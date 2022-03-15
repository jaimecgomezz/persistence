# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.0.3'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test, :development do
  gem 'ostruct', '~> 0.5.3'
  gem 'pry', '~> 0.14.1'
  gem 'rspec', '~> 3.11'
  gem 'rubocop', '~> 1.25'
  gem 'rubocop-performance', '~> 1.13'
  gem 'rubocop-rspec', '~> 2.8'
  gem 'sequel', '~> 5.53'
  gem 'simplecov', '~> 0.21.2'
end

group :production do
  gem 'rom'
  gem 'hanami-utils'
end
