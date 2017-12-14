class SimpleTable < ActiveRecord::Base
  self.table_name = 'dba.simple_table'
  self.system_attributes = ['ts', 'cts', 'sys_info']
  acts_as_extrable

  before_save ->{ self.auto_info = 'test' }
end
