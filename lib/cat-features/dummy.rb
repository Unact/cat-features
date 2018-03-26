module CatFeatures
  class Dummy < ActiveRecord::Base
    self.table_name = "sys.dummy"
    self.primary_key = "dummy_col"
    acts_as_singleton
  end
end
