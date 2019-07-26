require "spec_helper"

RSpec.describe CatFeatures::Extrable do
  before(:each) do
    reload_model
    @etype = CatFeatures::Extrable::Etype.create(table_name: 'simple_table', code: 'test_type', name: 'Тестовый тип')
  end

  def reload_model
    Object.send(:remove_const, 'SimpleTable') # Так как методы генерятся динамически
    load 'models/simple_table.rb'
  end

  context 'etypes' do
    it 'should list etypes' do
      etypes = SimpleTable.etypes
      expect(etypes.length).to eq(1)
      expect(etypes.first.id).to eq(@etype.id)
    end
  end

  context '#etypes_names' do
    it 'etypes should exist' do
      rec = SimpleTable.create(name: 'Test')
      etype_names = SimpleTable.etypes_names

      expect(etype_names.length).to eq(1)
      etype_names.each do |etype_name|
        expect(rec.send(etype_name)).to be_nil
      end
    end
  end

  context 'associations' do
    it 'methods exists' do
      rec = SimpleTable.create(name: 'Test')

      expect(rec.test_type_extra).to be_nil
    end

    it 'joins works' do
      expect(SimpleTable.joins(:test_type_extra).to_a).to be_empty
    end
  end

  context 'extra methods' do
    before(:each) do
      @rec = SimpleTable.create(name: 'Test')
      @test_value = 'test'
    end

    it "create extra" do
      @rec.test_type = @test_value
      expect(@rec.test_type).to eq(@test_value)

      @rec.save
      expect(CatFeatures::Extrable::Extra.count).to eq(1)
      expect(CatFeatures::Extrable::Extra.first.record_id).to eq(@rec.id)
      expect(CatFeatures::Extrable::Extra.first.value).to eq(@rec.test_type)
      expect(CatFeatures::Extrable::Extra.first.etype).to eq(@etype.id)

      @rec.reload
      expect(CatFeatures::Extrable::Extra.first.value).to eq(@rec.test_type)
    end

    context 'should not save extra' do
      after(:each) do
        expect(@rec.test_type).to be_nil

        @rec.save
        expect(@rec.test_type).to be_nil

        @rec.reload
        expect(@rec.test_type).to be_nil
        expect(CatFeatures::Extrable::Extra.count).to eq(0)
      end

      it 'when not explicitly saved' do
        @rec.test_type = @test_value
        @rec.reload
      end

      it 'when immediately deleted' do
        @rec.test_type = @test_value
        @rec.test_type = nil
      end
    end

    it 'should delete extra' do
      @rec.test_type = @test_value
      @rec.save
      @rec.test_type = nil

      @rec.save
      expect(CatFeatures::Extrable::Extra.count).to eq(0)
      expect(@rec.test_type).to be_nil

      @rec.reload
      expect(@rec.test_type).to be_nil
    end

    it 'should not delete extra' do
      @rec.test_type = @test_value
      @rec.save
      @rec.test_type = nil
      @rec.reload

      expect(CatFeatures::Extrable::Extra.count).to eq(1)
      expect(@rec.test_type).to eq(@test_value)
    end

    it 'should not change extra' do
      @rec.test_type = @test_value
      @rec.save
      @rec.test_type = 'new'

      @rec.reload
      expect(CatFeatures::Extrable::Extra.count).to eq(1)
      expect(CatFeatures::Extrable::Extra.first.value).to eq(@rec.test_type)
      expect(@rec.test_type).to eq(@test_value)
    end

    it 'should change extra' do
      new_value = 'new'
      @rec.test_type = @test_value
      @rec.save
      @rec.test_type = new_value

      @rec.save
      expect(CatFeatures::Extrable::Extra.count).to eq(1)
      expect(CatFeatures::Extrable::Extra.first.value).to eq(new_value)
      expect(@rec.test_type).to eq(new_value)

      @rec.reload
      expect(@rec.test_type).to eq(new_value)
    end
  end
end
