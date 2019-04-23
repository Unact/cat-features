module CatFeatures
  module Extrable
    extend ActiveSupport::Concern

    module ClassMethods
      @_extra_methods_defined = false

      def _reflect_on_association(association)
        define_extra_methods
        super(association)
      end

      def define_extra_methods
        return if @_extra_methods_defined
        @_extra_methods_defined = true
        foreign_key = self.primary_key.is_a?(String) ? Extra.foreign_key.first : Extra.foreign_key
        CatFeatures::Extrable::Etype.where(table_name: table_name.split(".")[-1]).each do |etype|
          code = etype.code.gsub(".", "_")

          association_name = "#{code}_extra".to_sym

          has_one association_name,
            ->{where etype: etype.id},
            foreign_key: foreign_key,
            class_name: "CatFeatures::Extrable::Extra",
            autosave: true

          define_method code.to_sym do
            extra = send(association_name)
            extra.try(:marked_for_destruction?) ? nil : extra.try(:value)
          end

          define_method "#{code}=".to_sym do |value|
            unless value.present?
              send("reload_#{association_name}").try(:mark_for_destruction)
              extra = nil
            else
              attributes = {value: value}
              extra = send("reload_#{association_name}")
              if extra
                extra.assign_attributes(attributes)
              else
                extra = send("build_#{association_name}", attributes.merge({etype: etype.id}))
              end
            end
            extra.try(:value)
          end
        end
      end
    end

    module InstanceMethods
      def method_missing(method_sym, *args)
        self.class.define_extra_methods
        return self.method(method_sym).call(*args) if self.methods.include? method_sym
        super
      end
    end

    class Etype < ActiveRecord::Base
      self.table_name = 'dbo.etype'
      acts_as_id_generator
    end

    class Extra < ActiveRecord::Base
      self.table_name = "dbo.extra"
      acts_as_id_generator

      def self.foreign_key
        [:record_id, :subid]
      end
    end

    ActiveRecord::Base.class_eval do
      def self.acts_as_extrable
        extend ClassMethods
        include InstanceMethods
      end
    end
  end
end
