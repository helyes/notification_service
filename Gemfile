source 'https://rubygems.org'
ruby '2.3.7'

gem 'activerecord', '~> 4.2.7', require: 'active_record'
gem 'grape', '~> 0.17.0'
gem 'grape-entity', '~> 0.5.1'
gem 'grape-swagger', '~> 0.25.0'
gem 'mysql2', '~> 0.4.4'
gem 'rack', '~> 2.0.1'
gem 'redcarpet'
gem 'require_all', '~> 1.3.3'
gem 'rouge'

group :development, :test do
  gem 'pry-byebug'
end

group :development do
  gem 'rake'
  gem 'thin'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'rack-test'
  gem 'rspec'
  gem "rspec_junit_formatter"
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
end

