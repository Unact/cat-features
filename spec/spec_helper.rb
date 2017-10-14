require "bundler/setup"
require "cat-features"

Dir[File.join('.', 'spec', 'models', '**' '*.rb')].each {|f| require f}
Dir[File.join('.', 'spec', 'support', '**' '*.rb')].each {|f| require f}

NEED_SPECIFY_OWNER = ActiveRecord::VERSION::MAJOR == 5

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
