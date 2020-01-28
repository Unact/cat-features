module ActiveRecord
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def update_bulk(records = [], &block)
        if records.is_a? Array
          sql = records.map{|record| new(record, &block).update_for_bulk(record.keys)}.compact.join(";")
          self.connection.execute(sql, "#{self.to_s} Bulk update") if sql.present?
        else
          raise ActiveRecordError, "Bulk update requires an array"
        end
      end

      def create_bulk(records = [], &block)
        if records.is_a? Array
          sql = records.map{|record| new(record, &block).create_for_bulk(record.keys)}.compact.join(";")
          self.connection.execute(sql, "#{self.to_s} Bulk create") if sql.present?
        else
          raise ActiveRecordError, "Bulk create requires an array"
        end
      end
    end

    def update_for_bulk attrs
      attributes_values = arel_attributes_for_insert_or_update(
        attrs,
        ->(keys){arel_attributes_with_values(attributes_for_update(keys))}
      )
      self.class.unscoped.update_for_bulk_sql(attributes_values)
    end

    def create_for_bulk attrs
      attributes_values = arel_attributes_for_insert_or_update(
        attrs,
        ->(keys){arel_attributes_with_values(attributes_for_create(keys))}
      )
      self.class.unscoped.insert_for_bulk_sql(attributes_values)
    end

    private
    def arel_attributes_for_insert_or_update attrs, attrs_proc
      attributes_values = attrs_proc.call(attr_names_without_system_attributes)
      run_callbacks :save
      # После :save сравниваем измененные поля с полями, которые действительно хотели изменить
      attrs_proc.call(attr_names_without_system_attributes).select do |atr_after_save_binds, atr_after_save_val|
        atr_after_save_name = atr_after_save_binds.name

        attributes_values.any?{|attr_val| attr_val.first.name == atr_after_save_name && attr_val.last != atr_after_save_val} ||
        attrs.any?{|atr| atr_after_save_name == atr.to_s}
      end
    end

    def attr_names_without_system_attributes
      attribute_names - system_attributes
    end

    def arel_attributes_with_values(attribute_names)
      attrs = {}
      arel_table = self.class.arel_table

      attribute_names.each do |name|
        attrs[arel_table[name]] = read_attribute(name)
      end
      attrs
    end
  end
end
