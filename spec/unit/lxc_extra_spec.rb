require 'spec_helper'

describe LXC::Extra do

  before(:all) do
    c = LXC::Container.new('test')
    c.create('download', nil, {}, 0, %w( -d ubuntu -r precise -a amd64 )) unless c.defined?
    c.start unless c.running?
  end

  after(:all) do
    c = LXC::Container.new('test')
    c.stop if c.running?
  end

  context '#execute' do
    let(:ct) do
      LXC::Container.new('test')
    end

    it 'should return apropriate object' do
      o = ct.execute{ 'FooBar' }
      expect(o).to eq('FooBar')
    end

    it 'should raise legitimate exceptions' do
      class TestError < RuntimeError; end
      expect do
        ct.execute {raise TestError}
      end.to raise_error(TestError)
    end

    it 'should respect timeout' do
      expect do
        ct.execute(timeout: 10) do
          11.times do |n|
            sleep 1
          end
        end
      end.to raise_error Timeout::Error
    end

    it 'should mash many files' do
      numfiles = 15000
      o = ct.execute do
        10000.upto(99999).take(numfiles).each do |n|
          File.open("/tmp/lxc_#{n}", "w") do |f|
            f.write("test")
          end
        end
      end
      expect(o).to eq(10000.upto(99999).take(numfiles))
    end
  end
end
