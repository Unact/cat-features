module CatFeatures
  module IdGenerator
    extend ActiveSupport::Concern

    included do
      before_create do
        self.id = self.class.next_id unless self.id
      end
    end

    module ClassMethods
      MAX_TRIES = 3

      def next_id
        if primary_key.is_a?(Array)
          raise "У модели #{self.to_s} составной первичный ключ, поэтому нельзя сгенерировать первичный ключ"
        end

        begin
          params = nil
          tries ||= MAX_TRIES
          new_id = self.uncached do
            table_name_part, owner_part = table_name.split('.').reverse

            params = [table_name_part, primary_key, owner_part].
              compact.
              map{|part| connection.quote(part)}.
              join(',')

            connection.select_value("select dbo.idgenerator(#{params})")
          end

          raise "Первичный ключ не сгенерирован. Проверьте название таблицы. Параметры: #{params}" unless new_id
          new_id
        rescue => e
          retry if (tries-=1) > 0
          raise e
        end
      end
    end
  end

  ActiveRecord::Base.class_eval do
    def self.acts_as_id_generator
      include IdGenerator
    end
  end
end
