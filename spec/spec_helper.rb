ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start do
  coverage_dir 'test_results/coverage'

  add_filter 'lib'

  add_group 'API', 'api'
  add_group 'App', 'formatter'
  add_group 'Config', 'config'
  add_group 'Spec', 'spec'
end
require File.expand_path('../config/environment', __dir__)
require 'rspec'
require 'shoulda-matchers'
require 'factory_girl'
require 'database_cleaner'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.library :active_record
    with.test_framework :rspec
  end
end

RSpec.configure do |config|
  # Shoulda
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  # Factory Girl
  config.include(FactoryGirl::Syntax::Methods)
  config.before(:suite) do
    FactoryGirl.find_definitions
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
