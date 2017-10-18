module ActiveRecord
  class Relation
    def update_for_bulk_sql(values)
      if values.present?
        substitutes = values.sort_by{|arel_attr,_| arel_attr.name}
        pk = substitutes.find{|subs| subs.first.name == primary_key }
        substitutes.delete(pk)

        compile_update(substitutes, pk.last).where(@table[primary_key].eq(pk.last)).to_sql if substitutes.present? && pk
      end
    end

    def insert_for_bulk_sql(values)
      if values.present?
        im = arel.create_insert
        im.into @table
        im.insert values.sort_by{|arel_attr,_| arel_attr.name}
        im.to_sql
      end
    end
  end
end
