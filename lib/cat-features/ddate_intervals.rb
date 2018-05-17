# Целевой класс должен иметь методы:
# - ddateb
# - ddatee
module CatFeatures
  module DdateIntervals
    extend ActiveSupport::Concern
    # Везде вызываем .to_time так как колонка может иметь тип без времени, и будет класса Date
    # А Time и Date не умеют сравниваться между собой
    def same_intervals? other
      ddateb.to_time == other.ddateb.to_time && ddatee.to_time == other.ddatee.to_time
    end

    def intervals_intersection? other
      ddateb.to_time <= other.ddatee.to_time && other.ddateb.to_time <= ddatee.to_time
    end

    def open_intervals_intersection? other
      ddateb.to_time < other.ddatee.to_time && other.ddateb.to_time < ddatee.to_time
    end

    module ClassMethods

      # super - в том же значение, что это надмножество из которого будет происходить выборка
      # Если аргумент - обычный интервал, то надмножество - все закиси,
      # иначе (есть метод id) - исключить эту запись из множества
      def super_scope interval_or_intervalable_ar
        interval_or_intervalable_ar.respond_to?(:id) ? where.not(id: interval_or_intervalable_ar.id) : self
      end
    end

    included do
      if self < ActiveRecord::Base
        scope :intervals_intersection, ->(interval_or_intervalable_ar) do
          super_scope(interval_or_intervalable_ar).
            where(arel_table[:ddateb].lteq(interval_or_intervalable_ar.ddatee.to_time)).
            where(arel_table[:ddatee].gteq(interval_or_intervalable_ar.ddateb.to_time))
        end

        scope :open_intervals_intersection, ->(interval_or_intervalable_ar) do
          super_scope(interval_or_intervalable_ar).
          where(arel_table[:ddateb].lt(interval_or_intervalable_ar.ddatee.to_time)).
          where(arel_table[:ddatee].gt(interval_or_intervalable_ar.ddateb.to_time))
        end
      end
    end
  end

  ActiveRecord::Base.class_eval do
    def self.acts_as_ddate_intervalable
      include DdateIntervals
    end
  end
end
