module CatFeatures
  module IdGenerator
    extend ActiveSupport::Concern

    included do
      before_create do
        self.id = self.class.next_id unless self.id
      end
    end

    module ClassMethods
      def next_id
        raise "У модели #{self.to_s} составной первичный ключ, поэтому нельзя сгенерировать первичный ключ" if primary_key.is_a? Array

        new_id = self.uncached do
          table_name_part, owner_part = table_name.split(".").reverse

          params = [table_name_part, primary_key, owner_part].
            compact.
            map{|part| connection.quote part}.
            join(',')

          connection.select_value("select dbo.idgenerator(#{params})")
        end

        raise "Первичный ключ не сгенерирован. Проверьте название таблицы" unless new_id

        new_id
      end
    end
  end

  ActiveRecord::Base.class_eval do
    def self.acts_as_id_generator
      include IdGenerator
    end
  end
end
