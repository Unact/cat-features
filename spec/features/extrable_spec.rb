require "spec_helper"

RSpec.describe CatFeatures::Extrable do
  before(:each) do
    @etype = CatFeatures::Extrable::Etype.create(table_name: 'simple_table', code: 'test_type', name: 'Тестовый тип')
    SimpleTable.define_extra_methods
    @rec = SimpleTable.create(name: 'Test')
    @test_value = 'test'
  end

  it "extra is created correctly" do
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

  context 'extra should not be saved' do
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
