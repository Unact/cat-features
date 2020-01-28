require "bundler/setup"
require 'byebug'
require "cat-features"
require 'database_cleaner'

Dir[File.join('.', 'spec', 'support', '**' '*.rb')].each {|f| require f}

CatFeatures::Database.delete
CatFeatures::Database.create
CatFeatures::Database.setup

# Сначало создадим бд, а потом вызовем модели
Dir[File.join('.', 'spec', 'models', '**' '*.rb')].each {|f| require f}


RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end
end
