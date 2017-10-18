require 'yaml'

module CatFeatures
  module Database
    class << self
      def config
        path = File.join('.', 'spec', 'support', 'database.yml')
        YAML.load_file(path)["db"]
      end

      def create
        cmd = "dbinit -p 8192 -z \"1251CYR(CaseSensitivity=Ignore)\" -zn \"UCA(CaseSensitivity=Ignore;AccentSensitivity=Ignore;PunctuationSensitivity=Primary)\" -b -s -pd -n #{config["dbf"]} -dba #{config["username"]},#{config["password"]}"
        Kernel.system(cmd)
      end

      def delete
        cmd = "rm -f #{config["dbf"]}"
        Kernel.system(cmd)
      end

      def setup
        ActiveRecord::Migration.verbose = false
        ActiveRecord::Base.establish_connection(config)

        # Для 5-х рельс надо ОБЯЗАТЕЛЬНО заполнять овнера
        if NEED_SPECIFY_OWNER
          ActiveRecord::Base.schema_migrations_table_name = "#{config["username"]}.schema_migrations"
          ActiveRecord::Base.internal_metadata_table_name = "#{config["username"]}.ar_internal_metadata"
        end

        ActiveRecord::Schema.define(:version => 1) do
          create_table :simple_primary_keys, id: false do |t|
            t.integer :id, null: false
            t.string :name
          end

          create_table :composite_primary_keys, id: false do |t|
            t.integer :id, null: false
            t.integer :subid, null: false
            t.string :name
          end

          create_table :idgenerator do |t|
            t.string :owner
            t.string :table_name
            t.string :primary_key_name
          end

          create_table :simple_table do |t|
            t.string :name
            t.string :info
          end
        end

        ActiveRecord::Base.connection.execute(
          <<-sql
            ALTER TABLE simple_primary_keys ADD PRIMARY KEY (id);
            ALTER TABLE composite_primary_keys ADD PRIMARY KEY (id, subid);
          sql
        )

        ActiveRecord::Base.connection.execute(
          <<-sql
            CREATE FUNCTION dbo.idgenerator (
                @table_name VARCHAR(128),
                @primary_key_name VARCHAR(128),
                @owner VARCHAR(32) default 'dbo'
            ) RETURNS INTEGER
            BEGIN
                DECLARE @res INTEGER;
                SET @res = GET_IDENTITY('dba.idgenerator');

                INSERT dba.idgenerator(id, owner, table_name, primary_key_name)
                VALUES(@res, @owner, @table_name, @primary_key_name);

                RETURN @res;
            END;
          sql
        )

        ActiveRecord::Base.connection.execute(
          <<-sql
            CREATE TABLE dbo.user_option(
              iam VARCHAR(255) NOT NULL,
              id VARCHAR(255) NOT NULL,
              value LONG VARCHAR NOT NULL,

              PRIMARY KEY(iam, id)
            );

            CREATE FUNCTION dbo.getuseroption (
              @option_id VARCHAR(255),
              @user_id VARCHAR(255)
            ) RETURNS LONG VARCHAR
            BEGIN
              DECLARE @res LONG VARCHAR;
              SET @res =COALESCE(
                (SELECT value FROM dbo.user_option WHERE iam=USER_ID(@user_id) AND id=@option_id),
                (SELECT value FROM dbo.user_option WHERE iam=USER_ID('dbo') AND id=@option_id)
              );

              RETURN @res;
            END;
          sql
        )
      end
    end
  end
end
