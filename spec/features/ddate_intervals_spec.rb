require "spec_helper"

RSpec.describe CatFeatures::DdateIntervals do
  let(:test_class) { Struct.new(:ddateb, :ddatee) { include CatFeatures::DdateIntervals } }
  subject{ test_class.new Time.new(2017,1,1), Time.new(2017,1,10) }

  describe '#same_intervals?' do
    it 'should not have same intervals' do
      c = test_class.new Time.new(2017,1,1), Time.new(2017,1,11)
      d = test_class.new Time.new(2017,1,13), Time.new(2017,1,14)

      expect(subject.same_intervals?(c)).to be false
      expect(subject.same_intervals?(d)).to be false
    end

    it 'should have same intervals' do
      b = test_class.new Time.new(2017,1,1), Time.new(2017,1,10)

      expect(subject.same_intervals?(subject)).to be true
      expect(subject.same_intervals?(b)).to be true
    end
  end

  describe '#intervals_intersection?' do
    it 'should not have intervals intersection' do
      c = test_class.new Time.new(2016,12,20), Time.new(2016,12,31)
      d = test_class.new Time.new(2017,1,11), Time.new(2017,1,20)

      expect(subject.intervals_intersection?(c)).to be false
      expect(subject.intervals_intersection?(d)).to be false
    end

    it 'should have intervals intersection' do
      b = test_class.new Time.new(2016,12,20), Time.new(2017,1,20)
      e = test_class.new Time.new(2017,1,3), Time.new(2017,1,7)
      f = test_class.new Time.new(2016,12,20), Time.new(2017,1,5)
      g = test_class.new Time.new(2017,1,5), Time.new(2017,1,20)

      expect(subject.intervals_intersection?(subject)).to be true
      expect(subject.intervals_intersection?(b)).to be true
      expect(subject.intervals_intersection?(e)).to be true
      expect(subject.intervals_intersection?(f)).to be true
      expect(subject.intervals_intersection?(g)).to be true
    end
  end

  describe '#open_intervals_intersection?' do
    it 'should not have open intersection' do
      b = test_class.new Time.new(2017,1,10), Time.new(2017,1,20)
      c = test_class.new Time.new(2016,12,20), Time.new(2017,1,1)

      expect(subject.open_intervals_intersection?(b)).to be false
      expect(subject.open_intervals_intersection?(c)).to be false
    end

    it 'should have open intersection' do
      d = test_class.new Time.new(2017,1,1), Time.new(2017,1,5)
      e = test_class.new Time.new(2017,1,1), Time.new(2017,1,20)
      f = test_class.new Time.new(2017,1,5), Time.new(2017,1,10)
      g = test_class.new Time.new(2016,12,20), Time.new(2017,1,10)

      expect(subject.open_intervals_intersection?(d)).to be true
      expect(subject.open_intervals_intersection?(e)).to be true
      expect(subject.open_intervals_intersection?(f)).to be true
      expect(subject.open_intervals_intersection?(g)).to be true
    end
  end
end
