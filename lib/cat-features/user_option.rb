module CatFeatures
  class UserOption
    DEFAULT_USER = :dbo

    class << self
      def [] name
        new(DEFAULT_USER)[name]
      end

      def []= name, value
        new(DEFAULT_USER)[name] = value
      end

      def by_user user_name
        new(user_name)
      end

      private :new
    end

    def initialize user_name
      @user_name = user_name
    end


    def [] name
      Model.user_option(name, @user_name)
    end

    def []= name, value
      Model.set_user_option(name, value, @user_name)
    end

    class Model < ActiveRecord::Base
      self.table_name = "dbo.user_option"
      self.primary_keys = 'iam', 'id'

      class << self
        def user_option option, user
          params = [option, user].map{|part| connection.quote part}.join(',')
          connection.select_value("select dbo.getuseroption(#{params})")
        end

        def set_user_option option, value, user
          unless value
            delete_user_option option, user
            return
          end

          iam = user_id user
          begin
            # Из-за разного формата параметров в методах find_by и new нельзя воспользоваться find_or_initialize_by
            user_option = find_by(iam: iam, id: option) || new(id: [iam, option])
            user_option.value = value
            user_option.save!
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        end

        def delete_user_option option, user
          user_option = find_by(iam: user_id(user), id: option)
          user_option.delete if user_option
        end

        def user_id user
          connection.select_value("select user_id(#{connection.quote user})")
        end
      end
    end
  end
end
