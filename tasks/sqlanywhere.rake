require 'cat-features'
require './spec/support/database.rb'

namespace :sqlanywhere do
  desc 'Build the sqlanywhere test database'
  task :build_database do
    CatFeatures::Database.create
    CatFeatures::Database.setup
  end

  desc 'Drop the sqlanywhere test database'
  task :drop_database do
    CatFeatures::Database.delete
  end

  desc 'Rebuild the sqlanywhere test database'
  task :rebuild_database => [:drop_database, :build_database]
end
