require "spec_helper"

RSpec.describe CatFeatures::IdGenerator do
  context "owner is specified" do
    it "AR\#next_id works as expected" do
      expect(SimplePrimaryKeyWithOwner.next_id).to_not be_nil
      expect{CompositePrimaryKey.next_id}.to raise_error(RuntimeError)
    end

    it "AR::create works as expected" do
      expect(SimplePrimaryKeyWithOwner.create(name: "model2").id).to_not be_nil
    end
  end

  context "owner is not specified" do
    it "AR\#next_id works as expected" do
      expect(SimplePrimaryKey.next_id).to_not be_nil
    end

    unless NEED_SPECIFY_OWNER
      it "AR::create works as expected" do
        expect(SimplePrimaryKey.create(name: "model1").id).to_not be_nil
      end
    end
  end

  context 'idgenerator function not working' do
    let(:normal_idgen_function) do
      ActiveRecord::Base.connection.
        select_value("SELECT proc_defn FROM sys.sysprocedure WHERE proc_name = 'idgenerator'")
    end
    let(:not_working_idgen_function) do
      "CREATE FUNCTION dbo.idgenerator(@param1 varchar(128), @param2 varchar(128), @param3 varchar(32) default 'dbo')
          RETURNS bigint
        BEGIN
          RETURN null
        END"
    end

    before do
      normal_idgen_function
      ActiveRecord::Base.connection.execute('DROP FUNCTION dbo.idgenerator')
      ActiveRecord::Base.connection.execute(not_working_idgen_function)
    end

    after do
      ActiveRecord::Base.connection.execute('DROP FUNCTION dbo.idgenerator')
      ActiveRecord::Base.connection.execute(normal_idgen_function)
    end

    it 'should raise error if idgenerator returns null' do
      expect{SimplePrimaryKey.next_id}.to raise_error(RuntimeError)
    end
  end
end
