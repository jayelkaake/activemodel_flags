require 'spec_helper'
require 'activemodel_flags/has_flags'
describe ActivemodelFlags::HasFlags do

  before do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

    Temping.create :user do
      has_flags

      with_columns do |t|
        t.text :flags
      end
    end
  end

  describe "#has (all variations)" do

    subject { User.new }

    it 'should set the flag on the model' do
      expect{
        subject.has! :taking_candy_from_a_baby
      }.to change {
        subject.has? :taking_candy_from_a_baby
        subject.hasnt? :taking_candy_from_a_baby
      }
    end

  end

  describe "#that_have (all variations)" do

    before do
      u1 = User.create
      u1.has! :eaten_a_burger

      u2 = User.create
      u2.has! :rode_a_horse
      u2.has! :eaten_a_burger

      u3 = User.create
      u3.hasnt! :ridden_a_cow
    end

    it "should find accounts with the right flag" do
      expect(User.that_have?(:eaten_a_burger).count).to eql(2)
    end

    it "should find any that dont have the flag" do
      expect(User.that_havent?(:eaten_a_burger).count).to eql(1)
    end

    it "find any that have any flags " do
      expect(User.that_have_any_flags.count).to eql(3)
    end

    it "show you all used flags" do
      expect(User.flags_used).to eql(['eaten_a_burger', 'rode_a_horse', 'ridden_a_cow'])
    end

  end

  describe "#all_have!" do

    before do
      User.create
      User.create
      User.create
    end

    it "should set all flags" do
      expect(User.that_have?(:ridden_a_kangaroo).count).to eql(0)

      User.all_have! :ridden_a_kangaroo

      expect(User.that_have?(:ridden_a_kangaroo).count).to eql(3)
    end
  end

  describe "#all_have_not!" do

    before do
      u = User.create
      u.has! :been_to_the_cn_tower
      u = User.create
      u.has! :been_to_the_cn_tower
      User.create
    end

    it "should set all flags to false" do
      expect(User.that_have?(:been_to_the_cn_tower).count).to eql(2)

      User.all_have_not! :been_to_the_cn_tower

      expect(User.that_have?(:been_to_the_cn_tower).count).to eql(0)
    end
  end


end
