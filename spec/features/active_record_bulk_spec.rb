require "spec_helper"

RSpec.describe 'ActiveRecordBulk' do
  describe "#create_bulk" do
    it 'creates new records with specified attributes' do
      data = [{id: 1, name: '1'}, {id: 2, name: '2', info: '22'}]
      SimpleTable.create_bulk(data)

      expect(SimpleTable.all.length).to eq(2)
      data.each do |row|
        rec = SimpleTable.find(row[:id])
        expect(rec.info).to eq row[:info]
        expect(rec.name).to eq row[:name]
      end
    end

    it 'runs save callback' do
      SimpleTable.create_bulk([{id: 1, name: '22'}])
      expect(SimpleTable.find(1).auto_info).not_to be_nil
    end

    it 'raises error when duplicate primary key' do
      expect{SimpleTable.create_bulk([{id: 1}, {id: 1}])}.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "doesn't create records for empty array" do
      SimpleTable.create_bulk([])
      expect(SimpleTable.all.length).to eq 0
    end

    it "doesn't create system attributes" do
      data = [{id: 1, name: '1', sys_info: 'test'}]
      SimpleTable.create_bulk(data)
      expect(SimpleTable.find(1).sys_info).not_to eq(data.first[:sys_info])
    end
  end

  describe "#update_bulk" do
    before(:each) do
      @test_data = [0,1].map do |num|
        rec_data = {id: num, name: num.to_s}
        SimpleTable.create(rec_data)
        rec_data
      end
    end

    context 'updates new records' do
      before(:each) do
        @update_data = @test_data.map{|rec| {id: rec[:id], name: (rec[:id] + 1).to_s}}
      end

      after(:each) do
        @update_data.each do |row|
          rec = SimpleTable.find(row[:id])
          expect(rec.name).to eq row[:name]
          expect(rec.info).to eq row[:info]
          expect(rec.sys_info).to be_nil
        end
      end

      it 'with specified attributes' do
        SimpleTable.update_bulk(@update_data)
      end

      it 'with different specified attributes' do
        @update_data.last[:info] = 'test'
        SimpleTable.update_bulk(@update_data)
      end

      it "excluding system attributes" do
        @update_data.each {|data| data[:sys_info] = 'test'}
        SimpleTable.update_bulk(@update_data)
      end
    end

    context "doesn't update records" do
      after(:each) do
        @test_data.each do |row|
          rec = SimpleTable.find(row[:id])
          expect(rec.name).to eq(row[:name])
          expect(rec.info).to be_nil
          expect(SimpleTable.all.length).to eq(@test_data.length)
        end
      end

      it "for empty array" do
        SimpleTable.update_bulk([])
      end

      it "for non existing primary key" do
        SimpleTable.update_bulk([{name: 'ss', id: -1}])
      end

      it "with no primary key" do
        SimpleTable.update_bulk(@test_data.map{|row| {name: ''}})
      end

      it 'with composite primary key' do
        rec = CompositePrimaryKey.create(id: [1,1], name: "1")
        CompositePrimaryKey.update_bulk([{id: [1,1], name: 'sss1'}])
        expect(CompositePrimaryKey.find([1,1]).name).to eq(rec.name)
      end
    end
  end
end
