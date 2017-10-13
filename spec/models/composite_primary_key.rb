class CompositePrimaryKey < ActiveRecord::Base
  self.table_name = 'composite_primary_keys'
  self.primary_keys = :id, :subid
  acts_as_id_generator
end
