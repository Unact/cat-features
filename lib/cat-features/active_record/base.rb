module ActiveRecord
  class Base
    class_attribute :system_attributes
    self.system_attributes = ["cts", "xid", "ts"]
  end
end
